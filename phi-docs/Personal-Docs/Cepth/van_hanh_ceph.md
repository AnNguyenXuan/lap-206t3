# 1. Dashboard và monitoring

# 2. Cân PGs

## **2.1. Nguyên tắc điều chỉnh PGs khi đã có dữ liệu:**

### **Không thể giảm PGs, chỉ có thể tăng:**

- `pg_num`: Số PGs mục tiêu
    
- `pgp_num`: Số PGs cho placement (luôn ≤ `pg_num`)
    
- Luôn tăng từng bước, không tăng đột ngột
    

## **2.2 Lộ trình điều chỉnh an toàn:**

### **Bước 1: Kiểm tra hiện trạng**

```zsh
# Xem chi tiết các pool hiện tại
ceph osd pool ls detail
ceph osd df tree
ceph pg dump pools
```

### **Bước 2: Tăng PGs từng bước nhỏ (2-3 lần tăng)**

```zsh
# Ví dụ cho s3.ssd.data từ 200 → 256
ceph osd pool set s3.ssd.data pg_num 224
ceph osd pool set s3.ssd.data pgp_num 224
```

```zsh
# Chờ 100% active+clean (có thể vài giờ)
watch ceph -s
# Hoặc theo dõi chi tiết hơn
ceph pg ls-by-pool s3.ssd.data | awk '{print $1,$2}' | sort -k2
```

### **Bước 3: Tiếp tục tăng đến mục tiêu**

```zsh
ceph osd pool set s3.ssd.data pg_num 256
ceph osd pool set s3.ssd.data pgp_num 256
```

### **Bước 4: Lặp lại cho các pool khác**

```zsh
# s3.ssd.index 50 → 128 (nên qua 64 trước)
ceph osd pool set s3.ssd.index pg_num 64
ceph osd pool set s3.ssd.index pgp_num 64

# Chờ ổn định
ceph osd pool set s3.ssd.index pg_num 128
ceph osd pool set s3.ssd.index pgp_num 128

# s3.hdd.data 450 → 512
ceph osd pool set s3.hdd.data pg_num 512
ceph osd pool set s3.hdd.data pgp_num 512

# s3.hdd.index 50 → 128
ceph osd pool set s3.hdd.index pg_num 64
ceph osd pool set s3.hdd.index pgp_num 64
ceph osd pool set s3.hdd.index pg_num 128
ceph osd pool set s3.hdd.index pgp_num 128
```


## **2.3. Tối ưu hóa quá trình PG Splitting:**

### **Giảm tải cho cluster trong quá trình điều chỉnh:**

```zsh
# Tạm thời giới hạn recovery/backfill
ceph config set global osd_max_backfills 2
ceph config set global osd_recovery_max_active 3
ceph config set global osd_recovery_sleep 0.1

# Giới hạn throughput nếu cần
ceph config set osd osd_recovery_max_single_start 1
```

### **Sau khi hoàn thành, khôi phục mặc định:**

```zsh
ceph config rm global osd_max_backfills
ceph config rm global osd_recovery_max_active
ceph config rm global osd_recovery_sleep
ceph config rm osd osd_recovery_max_single_start
```

## **4. Chiến lược PGs cho mở rộng tương lai:**

### **Scenario 1: Thêm OSD vào node hiện có**

Giả sử từ 6 SSD → 12 SSD, 9 HDD → 18 HDD:
```zsh
# Tính toán lại PGs khi mở rộng gấp đôi OSD
# Công thức: (Tổng OSD × 100) / Replication Factor × %phân bổ

# SSD: (12 × 100) / 2 = 600 PGs tổng
#   data: 512 PGs (2^9), index: 256 PGs (2^8)

# HDD: (18 × 100) / 2 = 900 PGs tổng  
#   data: 512 PGs (2^9), index: 256 PGs (2^8)
```

### **Scenario 2: Thêm node mới**

Giả sử thêm 3 node nữa → tổng 6 node, mỗi node 2 SSD + 3 HDD:

```zsh
# Tổng: 12 SSD, 18 HDD (giống Scenario 1)
# PGs giữ nguyên nếu đã tính trước
# Chỉ cần rebalance tự động khi thêm OSD
```

### **Scenario 3: Mở rộng tối đa (3 node → 9 node)**

```zsh
# Giả định mỗi node: 2 SSD + 3 HDD
# Tổng: 18 SSD, 27 HDD

# SSD: (18 × 100) / 2 = 900 PGs tổng
#   data: 512 PGs (2^9) hoặc 1024 (2^10) nếu nhiều object
#   index: 256 PGs (2^8)

# HDD: (27 × 100) / 2 = 1350 PGs tổng
#   data: 1024 PGs (2^10)
#   index: 256 PGs (2^8)
```

## **5. Kịch bản điều chỉnh PGs khi mở rộng:**

### **Khi thêm OSD mới:**

```zsh
# 1. Thêm OSD vào cluster
ceph osd create
ceph-deploy osd create nodeX:/path/to/device

# 2. Kiểm tra PGs per OSD
ceph osd df tree | grep -A5 "SSD\|HDD"

# 3. Nếu PGs/OSD > 200, cần tăng PGs
ceph osd pool set s3.ssd.data pg_num 512
ceph osd pool set s3.ssd.data pgp_num 512

# 4. Chờ rebalance hoàn tất
```

### **Công cụ tính toán tự động:**

```zsh
#!/bin/bash
# calc-pgs.sh - Tính PGs tự động
POOL_NAME=$1
CURRENT_PGS=$(ceph osd pool get $POOL_NAME pg_num | awk '{print $2}')
CURRENT_OSDS=$(ceph osd df tree | grep -c "ssd\|hdd")  # Cần điều chỉnh theo class

# Tính PGs mới theo lũy thừa 2 gần nhất
NEW_PGS=$(python3 -c "
import math
current = $CURRENT_PGS
osds = $CURRENT_OSDS
target = (osds * 100) // 2
# Lũy thừa 2 gần nhất
exp = math.ceil(math.log2(target))
new_pgs = 2**exp
print(new_pgs)
")

echo "Pool: $POOL_NAME"
echo "Current PGs: $CURRENT_PGS"
echo "Recommended PGs: $NEW_PGS"
```

## **6. Best Practices cho Production:**

### **A. Monitoring trong quá trình thay đổi:**

```zsh
# Giám sát real-time
ceph -w  # Theo dõi events
ceph pg stat  # Trạng thái PGs
ceph osd perf  # Performance OSDs
```
# Script tự động kiểm tra
```zsh
while true; do
  UNHEALTHY=$(ceph health detail | grep -c "unclean\|inactive\|stale")
  if [ $UNHEALTHY -gt 0 ]; then
    echo "WARNING: $UNHEALTHY PGs unhealthy"
    ceph health detail
  fi
  sleep 30
done
```

### **B. Thời điểm thực hiện:**

- Thực hiện vào giờ thấp điểm (đêm, cuối tuần)
    
- Thông báo trước cho người dùng về maintenance
    
- Backup config trước khi thay đổi
    

### **C. Rollback plan:**

```zsh
# Không có rollback cho PGs đã tăng
# Chỉ có thể:
# 1. Tạo pool mới với PGs đúng
# 2. Di chuyển dữ liệu (rất tốn thời gian)
# 3. Xóa pool cũ
```
## **7. Lời khuyên cụ thể cho hệ thống của bạn:**

Với 6 SSD + 9 HDD, replication=2:

```zsh
# PGs hiện tại OK nhưng chưa tối ưu
# Đề xuất điều chỉnh từ từ:
# Tuần 1: SSD pools 200→256, 50→128
# Tuần 2: HDD pools 450→512, 50→128

# Chuẩn bị cho mở rộng (nếu dự kiến thêm node):
# Nên set PGs cao ngay từ đầu để tránh phải điều chỉnh nhiều lần:
# SSD data: 512 (thay vì 256)
# HDD data: 512 (giữ nguyên)
# Index pools: 128 (đủ cho đến 24 OSD)
```

### **Command tổng hợp an toàn:**

```zsh
# Tăng từ từ với monitoring
for pool in s3.ssd.data s3.ssd.index s3.hdd.data s3.hdd.index; do
  current=$(ceph osd pool get $pool pg_num | awk '{print $2}')
  target=$(( (current * 12) / 10 ))  # Tăng 20% mỗi lần
  
  echo "Tăng $pool từ $current lên $target"
  ceph osd pool set $pool pg_num $target
  ceph osd pool set $pool pgp_num $target
  
  # Chờ ít nhất 30 phút hoặc đến khi healthy
  while ! cph health | grep -q "HEALTH_OK\|HEALTH_WARN"; do
    sleep 300
  done
done
```
