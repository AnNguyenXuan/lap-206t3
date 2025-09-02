Cinder cần một coordination backend khi triển khai multi-node để

Quản lý distributed locks: tránh hai node cùng lúc thao tác một volume hoặc snapshot.

Quản lý leader election: chọn node chính khi có nhiều node cinder-volume.

Quản lý cluster state: cập nhật trạng thái volume, backup, snapshot trong thời gian thực.

Vì sao Ceph backend bắt buộc coordination backend

Khi dùng Ceph RBD, các volume được chia sẻ giữa nhiều node

Nếu không có coordination backend, có thể xảy ra:

Race condition: Hai node cùng thao tác một volume → lỗi hoặc corrupt dữ liệu.

Inconsistent state: Một node nghĩ volume đang attach, node khác nghĩ đã detach.

Coordination backend (Redis hoặc etcd) giúp các node chia sẻ lock và trạng thái volume an toàn, chính xác.