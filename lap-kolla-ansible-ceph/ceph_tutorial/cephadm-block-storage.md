### Các khai niệm về Block Storage Ceph
```
Ceph Object Gateway (còn gọi là RADOS Gateway hay RGW) là một thành phần trong hệ thống lưu trữ phân tán Ceph, dùng để cung cấp giao diện object storage (lưu trữ đối tượng) tương tự như Amazon S3 hoặc OpenStack Swift.

Để xây dựng 
```
### Cài đặt Block Storage Ceph
```
Yêu cầu môi trường, cài docker, curl, lvm2 trên tất cả các node

Tại node đầu tiên, cài cephadm 

curl --silent --remote-name --location \
https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
sudo ./cephadm add-repo --release squid
sudo apt update
sudo ./cephadm install

Tạo node monitor đầu tiên
cephadm bootstrap --mon-ip 10.10.210.20 --cluster-network 10.10.210.0/24 --initial-dashboard-user admin --initial-dashboard-password 'Ohm_p2)6T3'
cephadm install ceph-common

Orchestrator (ceph orch …) cần SSH không mật khẩu để deploy container sang các host mới từ node monitor hiện tại
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
ceph orch daemon add mon openstack-data-2:10.10.210.19
ceph orch apply mon --placement="openstack-data-1,openstack-data-2" --dry-run
ceph orch apply mon --placement="openstack-data-1,openstack-data-2"

ceph orch ls --service_type=mon --format yaml

Tạo OSD quản lý các ổ cứng
ceph orch host label add openstack-data-1 osd
ceph orch host label add openstack-data-2 osd
ceph orch host label add openstack-mon-1 osd
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
ceph orch daemon add osd openstack-mon-1:/dev/sdb  
ceph orch daemon add osd openstack-mon-1:/dev/sdc  
ceph orch daemon add osd openstack-mon-1:/dev/sdd 
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
ceph osd pool create vms 32 32
rbd pool init volumes
rbd pool init images
rbd pool init backups
rbd pool init vms

Truy cập /etc/ceph/ceph.conf và xóa khoảng trắng
```


