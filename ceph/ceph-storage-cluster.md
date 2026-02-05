## Kiến trúc
```
Cơ chế lưu trữ : Obj -> PG -> OSD -> Drive
Lưu trữ dưới dạng flat namespace, mỗi đối tượng sẽ được định danh, metadata có dạng key-value.
Cả Ceph client và Ceph OSD đều sử dụng thuật toán CRUSH để tính toán vị trí lưu trữ đối tượng thay vì một bảng lưu trữ tập trung.

Cơ chế Daemon thông minh
Vấn đề của các cụm lưu trữ truyền thống là có một lớp trung tâm quản lý và điều phối, do đó nó là nút thắt.
Ceph giải quyết vấn đề này bằng cách tạo một cơ chế nhận biết cụm ở cả Ceph Client và OSD thông qua map lấy từ MON.

Đặc điểm kiến trúc
1. Client kết nối thẳng đến OSD cần thiết, giảm nghẽn, tăng thông lượng và sức chứa
2. Cơ chế quản lý OSD thông qua các OSD hàng xóm, không cần MON kiểm tra liên tục
3. Data Scrubbing là một cơ chế kiểm tra lỗi âm thầm thông qua việc so sánh các PG.
Cơ chế bao gồm Light scrub dùng để so metadata/kích thước/thuộc tính giữa các replicate
Deep scrub dùng bit-by-bit theo checksum để tìm bad sector mà Light scrub không thấy
4. Cơ chế Replication và Subops, Client sử dụng CRUSH để xác định Obj thuộc pool/PG nào và primary OSD của PG đó.
Sau đó, Client sẽ ghi vào primary OSD, primary OSD dùng CRUSH để chọn secondary OSD, gửi các thao tác nhân bản sang đó rồi mới trả về OK cho Client (Subops) 

Giao thức
Ceph sử dụng librados làm giao thức tập trung cho các kết nối từ phía Client để tương tác với cụm Ceph.

Cơ chế Data Striping
Ceph phân mảnh dữ liệu ra các Object, các Obj này lưu trên nhiều PG và OSD cải thiện khả năng đọc ghi song song từ đó tăng thông lượng giống với cơ chế RAID 0.
Các Client (RDB, CephFS, RGW) đảm nhiệm vai trò strip dữ liệu lên nhiều Object, còn khi dữ liệu đã vào cụm OSD thì sẽ không bị strip nữa.
Các tham số ảnh hưởng đến Striping bao gồm Object size, Strip unit, Strip count.
Trong cơ chế triển khai cơ bản, Strip unit = 1, lúc này có thể hiểu dữ liệu sẽ được phân mảnh và lưu đầy vào 1 Object, sau đó chuyển sang Object khác, lần lượt như thế đến hết.
Với cơ chế tăng Strip unit, lúc này dữ liệu được phân mảnh sẽ lưu lần lượt vào số lượng Object = Strip count, kích thước = Strip unit cho đến khi đầy cả cụm Object thì sẽ chuyển qua cụm tiếp theo.
```

## Cơ chế cache phía client và phía cluster trong Ceph RBD để tăng hiệu năng

## 1. Cache phía client trên compute node

Client ở đây thường là QEMU dùng librbd, chạy trên compute node OpenStack.

### 1.1 RAM cache của librbd rbd_cache

Mục tiêu
Giảm số lần phải đi xuống cluster, gom nhiều thao tác nhỏ thành ít thao tác lớn hơn

Cơ chế đọc
VM đọc block
librbd kiểm tra dữ liệu có nằm trong RAM cache không
Nếu có thì trả ngay
Nếu không thì đọc từ Ceph cluster rồi có thể giữ lại trong cache để lần sau đọc nhanh hơn

Cơ chế ghi
Tùy cấu hình write through hoặc write back
Write through
Ghi sẽ được đẩy xuống cluster ngay
Write back
Ghi có thể vào RAM cache trước rồi flush xuống cluster theo ngưỡng

Đặc tính
Nhanh vì dùng RAM
Không bền
Nếu process chết hoặc host reboot thì cache mất

---

### 1.2 Persistent read only cache cho parent image

Mục tiêu
Tăng tốc đọc khi nhiều VM clone từ cùng một base image
Đặc biệt hiệu quả lúc boot storm

Ý tưởng
Các clone hay đọc dữ liệu giống nhau từ parent image vốn là read only
Ta cache các object của parent xuống SSD local của compute node

Cơ chế đọc
VM đọc block
librbd xác định block này nằm ở clone hay phải đọc từ parent
Nếu cần đọc từ parent
librbd gọi plugin parent cache
Plugin trao đổi với daemon immutable object cache qua socket
Daemon kiểm tra object có sẵn trong SSD local chưa
Nếu có thì trả từ SSD local
Nếu không thì kéo object từ cluster về, lưu vào SSD local, rồi trả dữ liệu

Cơ chế ghi
Không áp dụng vì cache này chỉ phục vụ đọc từ parent

Đặc tính
Rất hợp cho mô hình base image và clone nhiều VM
Cache nằm trên SSD local nên bền hơn RAM cache

---

### 1.3 Persistent write log cache PWL

Mục tiêu
Giảm độ trễ ghi đặc biệt với ghi nhỏ và ghi ngẫu nhiên
Dùng SSD local để nhận ghi nhanh rồi đẩy xuống Ceph sau

Ý tưởng
Ghi vào cluster có thể chậm vì network, replication, và HDD backend
PWL tạo một write log bền trên SSD local của compute node

Cơ chế ghi
VM ghi
librbd cần giành exclusive lock trên image để đảm bảo một luồng ghi logic
Dữ liệu ghi được append vào write log trên SSD local
librbd trả ACK cho VM sớm vì dữ liệu đã nằm trên SSD local
Sau đó background flusher gom log và gửi xuống Ceph cluster
Khi OSD commit xong thì entry log được đánh dấu sạch và có thể giải phóng

Cơ chế đọc
Khi VM đọc
librbd phải kết hợp dữ liệu đã flush nằm trên cluster với dữ liệu chưa flush nằm trong write log
Nếu đọc vào vùng vừa ghi mà chưa flush thì đọc từ log

Đặc tính
Bền hơn RAM cache vì log nằm trên SSD local
Cuối cùng vẫn phải flush xuống Ceph để có độ bền ở mức cluster
Tốn SSD local theo số image đang active và theo cấu hình kích thước cache mỗi image

---

## 2. Cache phía cluster trên OSD

Phía cluster là OSD BlueStore và RocksDB, ảnh hưởng đến tất cả client.

### 2.1 RocksDB cache và metadata

Mục tiêu
Tăng tốc xử lý metadata của object, omap, map nội bộ
Giảm đọc ngẫu nhiên xuống thiết bị lưu trữ

Cơ chế
OSD tra metadata trong RocksDB
RocksDB có block cache trong RAM để giảm I O xuống device
Dù ta tách DB và WAL ra SSD nên phần metadata nhanh hơn đáng kể
Nhưng vẫn cần RAM cache để giảm random read và giảm latency

---

### 2.2 BlueStore data buffers và cache nội bộ

Mục tiêu
Giảm đọc ghi đĩa HDD backend
Tối ưu pipeline ghi và các buffer trong OSD

Cơ chế đọc
OSD nhận request đọc
Tra metadata rồi xác định vị trí data
Đọc từ HDD hoặc từ buffer cache nếu còn
Trả về client

Cơ chế ghi
OSD tạo transaction
Ghi metadata vào RocksDB trên SSD DB WAL
Ghi data xuống HDD
Với replica 2 thì primary phối hợp replica và ACK theo điều kiện commit

---

### 2.3 Cơ chế giới hạn và tự chia RAM của OSD

osd_memory_target_autotune
OSD tự chọn ngân sách RAM mục tiêu dựa trên RAM node và số OSD

bluestore_cache_autotune
Trong ngân sách đó BlueStore tự chia cho các phần cache nội bộ như RocksDB cache, buffers, và các cache liên quan

---

## 3. Hai phía hỗ trợ nhau như thế nào

Client cache giúp VM cảm giác nhanh hơn vì giảm round trip xuống cluster
OSD cache giúp cluster xử lý nhanh hơn vì giảm I O xuống SSD DB và HDD data

Ví dụ boot storm
Parent read only cache giảm tải đọc từ cluster nên OSD nhẹ hơn

Ví dụ random write
PWL giảm latency ghi thấy từ VM
Nhưng nếu backend chậm thì backlog flush tăng và SSD local có thể đầy nếu sizing không đủ
