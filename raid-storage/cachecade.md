## Tính năng cache cho cụm HDD
```
Trong RAID có tính năng Cachecade, tuy nhiên yêu cầu cần card RAID hỗ trợ

Trong TH card RAID không hỗ trợ, có một số phần mềm có thể cải thiện
 
bcache : Block layer cache (kernel)

Ưu điểm : Tốt cho cả read & write cache; hỗ trợ writeback / writethrough

Nhược điểm : Phải format disk trước; phức tạp hơn

dm-cache : Device-mapper cache

Ưu điểm : Hỗ trợ nhiều cache policy; tích hợp LVM

Nhược điểm : Cần metadata device & mapping
```
## Cài đặt bcache
```
# Cài đặt 
apt update && apt install -y bcache-tools
modprobe bcache 

# Dọn cấu hình cũ
umount /dev/sdb* 2>/dev/null
sgdisk --zap-all /dev/sdb
sgdisk --zap-all /dev/sdc
wipefs -a /dev/sdb
wipefs -a /dev/sdc

# Tạo cấu hình bcache
make-bcache -B /dev/sdb
make-bcache -C /dev/sdc

# Nếu chưa được register thì bổ sung, còn nếu lsblk -f đã thấy bcache thì bỏ qua
echo /dev/sdb > /sys/fs/bcache/register
echo /dev/sdc > /sys/fs/bcache/register

# Lấy CSET-UUID (UUID của cache set)
ls /sys/fs/bcache/
echo <CSET-UUID> > /sys/block/bcache0/bcache/attach
echo b65ded94-e5ab-4d3e-8b20-5a49298a0f8c > /sys/block/bcache0/bcache/attach

# Xem cấu hình
cat /sys/block/bcache0/bcache/state (trạng thái của cahe hiện tại : no cache, clean, dirty, inconsistent)
cat /sys/block/bcache0/bcache/cache_mode

# Cấu hình cache mode (dùng writeback nếu có cơ chế bảo vệ dữ liệu khi mất điện PLP hoặc nguồn dự phòng UPS)
echo writethrough > /sys/block/bcache0/bcache/cache_mode
echo writeback > /sys/block/bcache0/bcache/cache_mode

# Cấu hình cutoff
echo 4M > /sys/block/bcache0/bcache/sequential_cutoff
echo 0 > /sys/block/bcache0/bcache/sequential_cutoff

# Tạo file system nếu chưa có
mkfs.ext4 -f /dev/bcache0

# Tạo thư mục và mount
mkdir -p /data
mount /dev/bcache0 /data
```

## Cấu hình writeback cho bcache
```
# Mục tiêu của cấu hình là kiểm soát dirty data nằm trong ssd
# Để xem có bao nhiêu data chưa xả xuống ssd, kiểm tra trạng thái
cat /sys/block/bcache0/bcache/dirty_data
cat /sys/block/bcache0/bcache/state

# Để xem dữ liệu delay bao nhiêu giây trước khi xả
cat /sys/block/bcache0/bcache/writeback_delay

# Để xem tỉ lệ dirty data được setpoint trong ssd khi xả
# Ví dụ nếu tỉ lệ dirty data đang là 30%, trong khi setpoint là 10%
# Độ lệch 20% khiến bcache tăng tốc xả để giảm dirty về ~10%, nhưng tốc độ xả thực tế còn phụ thuộc writeback_rate và backing
cat /sys/block/bcache0/bcache/writeback_percent

# Để xem số sector/s được xả (1 sector = 512 bytes), bcache thường sẽ tự điều chỉnh
cat /sys/block/bcache0/bcache/writeback_rate

# Xem thông số readahead
cat /sys/block/bcache0/queue/read_ahead_kb
cat /sys/block/sdb/queue/read_ahead_kb

# Lợi ích: bcache writeback có lợi vì nó hấp thụ random write vào SSD, rồi khi xả xuống backing nó xả theo kiểu tuần tự, từ đó cải thiện hiệu năng ghi ngẫu nhiên
# Điểm lợi nhất là dùng với RAID5/6 bị write penalty vì phải cập nhật parity; với ghi nhỏ/partial write dễ rơi vào chu kỳ kiểu read-modify-write nên chậm
# Ghi lớn/tuần tự: bcache thường ít hiệu quả (thậm chí cố tình bỏ qua)
```

