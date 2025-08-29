### Tổng hợp các lệnh Ceph
#### Các lệnh tạo pool
ceph osd pool create <pool_name> <pg_num> <pgp_num>
ceph osd pool create images 256 256

rbd pool init volumes : khởi tạo metadata cho pool