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