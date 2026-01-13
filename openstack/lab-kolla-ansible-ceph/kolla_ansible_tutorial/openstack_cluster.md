### Tài liệu tổng hợp kiến trúc Openstack
1. Redis hoặc Etcd trong kiến trúc Cinder multi-node
```
Cinder cần một coordination backend khi triển khai multi-node để:
- Quản lý distributed locks: tránh hai node cùng lúc thao tác một volume hoặc snapshot.
- Quản lý leader election: chọn node chính khi có nhiều node cinder-volume.
- Quản lý cluster state: cập nhật trạng thái volume, backup, snapshot trong thời gian thực.

Ceph backend bắt buộc cần Redis hoặc Etcd vì khi dùng Ceph RBD, các volume được chia sẻ giữa nhiều node. Nếu không có thể xảy ra:
- Race condition: Hai node cùng thao tác một volume lỗi hoặc corrupt dữ liệu.
- Inconsistent state: Một node nghĩ volume đang attach, node khác nghĩ đã detach.
```
