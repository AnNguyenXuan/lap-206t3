Yêu cầu môi trường, cài docker, curl trên tất cả các node

Chuẩn bị cài cephadm 
CEPH_RELEASE=19.2.3
curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm
chmod +x cephadm
./cephadm add-repo --release squid
apt-get update
./cephadm install


Lệnh triển khai trên node monitor ceph
cephadm bootstrap --mon-ip 10.10.210.20 --cluster-network 10.10.210.0/24 --initial-dashboard-user admin --initial-dashboard-password Ohm_HN2506@

cephadm add-repo --release squid
cephadm install ceph-common


Orchestrator (ceph orch …) cần SSH không mật khẩu để deploy container sang các host mới
ssh-copy-id -f -i /etc/ceph/ceph.pub root@10.10.210.18
ssh-copy-id -f -i /etc/ceph/ceph.pub root@10.10.210.19


Lệnh này sẽ yêu cầu orch không tự động chọn node monitor, ta sẽ chọn thủ công
ceph orch apply mon --unmanaged


Add các node còn lại vào cluster
ceph orch host add openstack-data-1 10.10.210.18
ceph orch host add openstack-data-2 10.10.210.19

ceph orch host ls

Add label admin
ceph orch host label add openstack-data-1 _admin
ceph orch host label add openstack-data-2 _admin

Add 2 node mon còn lại
ceph orch daemon add mon openstack-data-1:10.10.210.18
ceph orch daemon add mon openstack-data-1:10.10.210.19
ceph orch apply mon --placement="openstack-data-1,openstack-data-2" --dry-run
ceph orch apply mon --placement="openstack-data-1,openstack-data-2"

ceph orch ls --service_type=mon --format yaml

Tạo OSD quản lý các ổ cứng
ceph orch host label add openstack-data-1 osd
ceph orch host label add openstack-data-2 osd
ceph orch host label add openstack-data-3 osd

Xem danh sách thiết bị
ceph orch device ls


Add từng ổ 
ceph orch daemon add osd openstack-data-1:/dev/sdb  
ceph orch daemon add osd openstack-data-1:/dev/sdc  
ceph orch daemon add osd openstack-data-1:/dev/sdd  
ceph orch daemon add osd openstack-data-2:/dev/sdb  
ceph orch daemon add osd openstack-data-2:/dev/sdc  
ceph orch daemon add osd openstack-data-2:/dev/sdd    
ceph orch daemon add osd openstack-data-3:/dev/sdb  
ceph orch daemon add osd openstack-data-3:/dev/sdc  
ceph orch daemon add osd openstack-data-3:/dev/sdd   


Bỏ auto scale
ceph config set global osd_pool_default_pg_autoscale_mode off

Bỏ cân bằng tải cụm
ceph balancer off

Set default pool size
ceph config set global osd_pool_default_size 2
ceph config set global osd_pool_default_min_size 1

Set min osd ratio
ceph config set global mon_osd_min_in_ratio 0.5

Disable memory autotune
ceph config set osd osd_memory_target_autotune false

Tạo pool cho OPS
ceph osd pool create volumes 64 64
ceph osd pool create images 16 16
ceph osd pool create backups 16 16
rbd pool init volumes
rbd pool init images
rbd pool init backups

Truy cập /etc/ceph/ceph.conf và xóa khoảng trắng

ceph osd pool create <pool_name> <pg_num> <pgp_num>

<pg_num>, viết tắt của Placement Group Number
PG là một tập hợp các đối tượng (objects) được Ceph gộp lại để phân phối trên các OSD. Số lượng PG ảnh hưởng trực tiếp đến hiệu suất và khả năng cân bằng dữ liệu của cluster

<pgp_num>, viết tắt của Placement Group for Placement Number
Về cơ bản, pgp_num phải bằng hoặc lớn hơn pg_num

pg_num = Số lượng PG đã tạo.
pgp_num = Số lượng PG đang được sử dụng để lưu trữ dữ liệu.

Ceph yêu cầu ổ cứng sạch, nếu trong quá trình cài ổ cứng có dữ liệu, rất dễ bị lỗi khi ceph sẽ đọc được bảng phân vùng gpt

Ceph yêu cầu key docker sạch nên cần xóa bỏ key docker cũ, trong quá trình cài đặt nếu thấy docker thì ansible sẽ tự động xóa 
rm /etc/apt/sources.list.d/docker.list 

Bật 
#containerized_deployment: True

osd_auto_discovery



