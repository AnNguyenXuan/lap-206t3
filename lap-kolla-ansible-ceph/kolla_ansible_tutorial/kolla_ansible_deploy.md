### Tài liệu triển khai kolla-ansible
#### Chuẩn bị môi trường
1. Yêu cầu
- Chuẩn bị một node deploy cài kolla-ansible, các node còn lại được gọi là node setup. Sử dụng quyền root tại node deploy, đảm bảo /etc/hosts có nội dung sau:
```
<tên_node_setup> < ip_node_setup>
<tên_node_setup> < ip_node_setup>
<tên_node_setup> < ip_node_setup>
```
- Sau đó thực hiện copy-ssh key cho các node setup
```
- ssh-keygen
- ssh-copy-id root@<tên_node_setup>
```
- Đảm bảo cài đặt chrony, ufw tại tất cả các node setup
```
- apt install -y chrony ufw
```
2. Tạo môi trường ảo để tránh xung đột
```
Cài đặt một số thư viện cần thiết
- apt update
- apt install git python3-dev libffi-dev gcc libssl-dev libdbus-glib-1-dev
- python3 -m venv <tên_môi_trường>
Truy cập môi trường ảo
- source <tên_môi_trường>/bin/activate
- pip install -U pip
Để thoát môi trường ảo
- deactivate
Lưu ý, bất kì khi nào làm việc với kolla-ansible, ta cần truy cập môi trường ảo
```
3. Clone mã nguồn, thiết lập nhánh triển khai
```
Cài mã nguồn về máy
- pip install git+https://opendev.org/openstack/kolla-ansible@master
Tạo thư mục cấu hình
- mkdir -p /etc/kolla
- chown $USER:$USER /etc/kolla
Copy các file cấu hình mẫu vào thư mục cấu hình
- cp -r /path/to/venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
- cp /path/to/venv/share/kolla-ansible/ansible/inventory/all-in-one .
Cài đặt một số thư viện cần thiết
- kolla-ansible install-deps
```
#### Giới thiệu Openstack, kiến trúc triển khai
1. Cấu trúc dịch vụ
```
Trong kiến trúc build của kolla-ansible, mặc định sẽ có các dịch vụ của Openstack sau :
1. Keystone : dịch vụ xác thực danh tính
2. Glance : dịch vụ quản lý image
3. Nova : dịch vụ quản lý máy ảo
4. Placement : dịch vụ quản lý tài nguyên máy ảo
5. Horizon : giao diện
6. Cinder : quản lý ổ đĩa ảo

Ngoài ra, ta còn cần một số dịch vụ : 
1. Database : lưu trữ dữ liệu
2. Memcached : lưu trữ dữ liệu tạm thời, giảm tải truy vấn tới Database
3. Rabbitmq : giao tiêp hàng đợi, trung gian giúp phân phối quá trình liên lạc giữa các dịch vụ của Openstack
```

2. Kiến trúc triển khai
```
Hệ thống bao gồm 9 node, trong đó có :
- 2 node controller
- 2 node computer
- 3 node ceph
- 1 node database
- 1 node deploy

Thiết kế mạng mô phỏng sẽ là
- ens192 : giao tiếp bên ngoài cụm ceph
- ens224 : giao tiếp nội bộ cụm
- ens256 : giao tiếp bên ngoài cụm openstack
```

#### Cấu hình Kolla-ansible với cụm Ceph, yêu cầu đã có cụm Ceph
1. Cấu hình inventory file

2. Copy các thông tin cần thiết từ cụm Ceph về node deploy

Đảm bảo đã tạo 4 pool trên cụm Ceph
```
ceph osd pool create volumes
ceph osd pool create images
ceph osd pool create backups
ceph osd pool create vms
```
Kích hoạt rbd cho các pool
```
rbd pool init volumes
rbd pool init images
rbd pool init backups
rbd pool init vms
```
Copy file cấu hình cụm Ceph tới node deploy
```
ssh 10.10.210.32 sudo tee /etc/kolla/config/cinder/cinder-volume/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.32 sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.32 sudo tee /etc/kolla/config/nova/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.32 sudo tee /etc/kolla/config/glance/ceph.conf < /etc/ceph/ceph.conf
```
Tạo key cho user Openstack ứng với mỗi RDB Ceph để xác thực CephX
```
ceph auth get-or-create client.glance mon 'profile rbd' osd 'profile rbd pool=images' mgr 'profile rbd pool=images'
ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images' mgr 'profile rbd pool=volumes, profile rbd pool=vms'
ceph auth get-or-create client.cinder-backup mon 'profile rbd' osd 'profile rbd pool=backups' mgr 'profile rbd pool=backups'
```
Copy key sang node deploy
```
ceph auth get-or-create client.cinder | ssh 10.10.240.32 sudo tee /etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring
ceph auth get-or-create client.cinder | ssh 10.10.240.32 sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder.keyring
ceph auth get-or-create client.cinder-backup | ssh 10.10.240.32 sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder-backup.keyring
ceph auth get-or-create client.cinder | ssh 10.10.240.32 sudo tee /etc/kolla/config/nova/ceph.client.cinder.keyring
ceph auth get-or-create client.glance | ssh 10.10.240.32 sudo tee /etc/kolla/config/glance/ceph.client.glance.keyring
```
3. Cấu hình dịch vụ Openstack tại node deploy

Cấu hình glance.conf
```
nano /etc/kolla/config/glance/glance-api.conf
[DEFAULT]
show_image_direct_url = True

[glance_store]
default_store = rbd
stores = file,http,rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8
```
Cấu hình cinder
```
nano /etc/kolla/config/cinder/cinder-volume.conf
[DEFAULT]
...
enabled_backends = ceph
glance_api_version = 2
...
[ceph]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = ceph
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1

nano /etc/kolla/config/cinder/cinder-backup.conf
[ceph]
backup_driver = cinder.backup.drivers.ceph
backup_ceph_conf = /etc/ceph/ceph.conf
backup_ceph_user = cinder-backup
backup_ceph_chunk_size = 134217728
backup_ceph_pool = backups
backup_ceph_stripe_unit = 0
backup_ceph_stripe_count = 0
restore_discard_excess_bytes = true
```
#### Khởi tạo dự án
- kolla-ansible certificates -i multinode
- kolla-ansible bootstrap-servers -i multinode
- kolla-ansible prechecks -i multinode
- kolla-ansible deploy -i multinode
- kolla-ansible post-deploy -i multinode
- kolla-ansible reconfigure -i multinode --tags neutron

