### Tổng hợp các lệnh Ceph
#### Các lệnh tạo pool
ceph osd pool create <pool_name> <pg_num> <pgp_num>
ceph osd pool create images 256 256

<pg_num>, viết tắt của Placement Group Number
PG là một tập hợp các đối tượng (objects) được Ceph gộp lại để phân phối trên các OSD. Số lượng PG ảnh hưởng trực tiếp đến hiệu suất và khả năng cân bằng dữ liệu của cluster

<pgp_num>, viết tắt của Placement Group for Placement Number
Về cơ bản, pgp_num phải bằng hoặc lớn hơn pg_num

pg_num = Số lượng PG đã tạo.
pgp_num = Số lượng PG đang được sử dụng để lưu trữ dữ liệu.

rbd pool init volumes : khởi tạo metadata cho pool

#### Kiểm tra quyền bảo mật cephx authenticatio
ceph config get mon auth_cluster_required
ceph config get mon auth_service_required
ceph config get mon auth_client_required

Trong đó 
- auth_cluster_required : yêu cầu xác thực khi các monitor giao tiếp trong cụm Ceph
- auth_service_required : yêu cầu xác thực khi các service giao tiếp trong cụm Ceph
- auth_client_required : yêu cầu xác thực khi các client giao tiếp với cụm Ceph

#### Kiểm tra trạng thái cụm
ceph health detail
ceph osd tree
ceph osd df tree
ceph tell osd.* bench
ceph daemon osd.<id> perf dump | jq '.bluestore'

#### Xử lý dữ liệu OSD
ceph orch device zap openstack-node-2 /dev/sdc --force

#### Các lệnh về Object Storage
 

