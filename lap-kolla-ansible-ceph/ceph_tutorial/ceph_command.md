### Tổng hợp các lệnh Ceph
#### Các lệnh tạo pool
ceph osd pool create <pool_name> <pg_num> <pgp_num>
ceph osd pool create images 256 256

rbd pool init volumes : khởi tạo metadata cho pool

#### Kiểm tra quyền bảo mật cephx authenticatio
ceph config get mon auth_cluster_required
ceph config get mon auth_service_required
ceph config get mon auth_client_required

Trong đó 
- auth_cluster_required : yêu cầu xác thực khi các monitor giao tiếp trong cụm Ceph
- auth_service_required : yêu cầu xác thực khi các service giao tiếp trong cụm Ceph
- auth_client_required : yêu cầu xác thực khi các client giao tiếp với cụm Ceph