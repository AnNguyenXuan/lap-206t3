# Tài liệu triển khai kolla-ansible
## Chuẩn bị môi trường
### 1. Yêu cầu
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
- Đảm bảo cài đặt chrony, ufw , sudo tại tất cả các node setup
```
- apt install -y chrony ufw
```
### 2. Tạo môi trường ảo để tránh xung đột
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
### 3. Clone mã nguồn, thiết lập nhánh triển khai
```
Cài mã nguồn về máy, cài bản theo nhu cầu
- source <tên_môi_trường>/bin/activate
- git clone https://opendev.org/openstack/kolla-ansible.git
- cd kolla-ansible
- git branch -a
- git checkout stable/2025.1
- pip install .
- kolla-ansible --version
Tạo thư mục cấu hình
- mkdir -p /etc/kolla
- chown $USER:$USER /etc/kolla
Copy các file cấu hình mẫu vào thư mục cấu hình
- cp -r /path/to/venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
- cp /path/to/venv/share/kolla-ansible/ansible/inventory/all-in-one .
Cài đặt một số thư viện cần thiết
- kolla-ansible install-deps
```
## Giới thiệu Openstack, kiến trúc triển khai
### 1. Cấu trúc dịch vụ
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

### 2. Kiến trúc triển khai (trong lab này)
```
Hệ thống bao gồm 9 node, trong đó có :
- 2 node controller : 10.10.210.14-15
- 2 node computer : 10.10.210.16-17
- 3 node ceph : 10.10.210.18-20
- 1 node database : 10.10.210.13
- 1 node deploy : 10.10.210.10

Thiết kế mạng mô phỏng sẽ là
- ens192 : MGMT
- ens224 : public
- ens256 : giao tiếp bên ngoài cụm openstack
- ens161 : giao tiếp nội bộ giữa các máy ảo


VLAN 210 → 10.10.210.0/24 (mgmt/internet)

VLAN 30 → 10.10.30.0/24 (internal/LB backend)

VLAN 240 → 10.10.240.0/24 (public/VIP)
```

## Cấu hình Kolla-ansible với cụm Ceph, yêu cầu đã có cụm Ceph
### 1. Copy các thông tin cần thiết từ cụm Ceph về node deploy

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
Truy cập cấu hình và xóa khoảng trắng
nano /etc/ceph/ceph.conf

ssh 10.10.210.10 sudo tee /etc/kolla/config/cinder/cinder-volume/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.10 sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.10 sudo tee /etc/kolla/config/nova/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.10 sudo tee /etc/kolla/config/glance/ceph.conf < /etc/ceph/ceph.conf
```

Tạo key cho user Openstack ứng với mỗi RDB Ceph để xác thực CephX trên node Mon
```
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images'
ceph auth get-or-create client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups, allow rwx pool=volumes'
ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images'
ceph auth caps client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups, allow rx pool=volumes'
```

Copy key sang node deploy
```
ceph auth get-or-create client.cinder | sed 's/^[[:space:]]\+//' | ssh -T 10.10.210.10 'sudo tee /etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring >/dev/null'
ceph auth get-or-create client.cinder-backup | sed 's/^[[:space:]]\+//' | ssh -T 10.10.210.10 'sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder-backup.keyring >/dev/null'
ceph auth get-or-create client.cinder | sed 's/^[[:space:]]\+//' | ssh -T 10.10.210.10 'sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder.keyring >/dev/null'
ceph auth get-or-create client.cinder | sed 's/^[[:space:]]\+//' | ssh -T 10.10.210.10 'sudo tee /etc/kolla/config/nova/ceph.client.cinder.keyring >/dev/null'
ceph auth get-or-create client.glance | sed 's/^[[:space:]]\+//' | ssh -T 10.10.210.10 'sudo tee /etc/kolla/config/glance/ceph.client.glance.keyring >/dev/null'
ceph auth get-key client.cinder | ssh 10.10.210.10 sudo tee /etc/kolla/config/nova/client.cinder.key
```

Kích hoạt tính năng exclusive-lock (nghiên cứu sau)
```
ceph auth caps client.ID mon 'allow r, allow command "osd blacklist"' osd 'EXISTING_OSD_USER_CAPS'
```

### 2. Cấu hình dịch vụ Openstack tại node deploy

Cài đặt rbd cho toàn cụm
```
apt install python3-rbd
apt install ceph-common
apt install uuid-runtime
```

Tạo uuid tại node deploy chạy và gán pass 
```
uuidgen
uuidgen
1ddabc08-4694-48ad-86e7-65dc24049829
ffac422c-130a-494c-a716-db71935bfd43
kolla-genpwd
rbd_secret_uuid: 1ddabc08-4694-48ad-86e7-65dc24049829
cinder_rbd_secret_uuid: ffac422c-130a-494c-a716-db71935bfd43
```

Cấu hình cinder.conf
```
nano /etc/kolla/config/cinder/cinder-volume.conf
[DEFAULT]
enabled_backends = ceph
glance_api_version = 2

[ceph]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = ceph
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
rbd_user = cinder
rbd_secret_uuid = 1ddabc08-4694-48ad-86e7-65dc24049829

nano /etc/kolla/config/cinder/cinder-backup.conf
[DEFAULT]
backup_driver = cinder.backup.drivers.ceph
backup_ceph_conf = /etc/ceph/ceph.conf
backup_ceph_user = cinder-backup
backup_ceph_chunk_size = 134217728
backup_ceph_pool = backups
backup_ceph_stripe_unit = 0
backup_ceph_stripe_count = 0
restore_discard_excess_bytes = true
```

Cấu hình glance.conf
```
nano /etc/kolla/config/glance/glance-api.conf
[DEFAULT]
show_image_direct_url = True

[glance_store]
default_store = rbd
stores = rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8

[cors]
allowed_origin = https://10.10.210.9
```

Cấu hình nova.conf
```
nano /etc/kolla/config/nova/nova.conf 
[libvirt]
images_type = rbd
images_rbd_pool = vms
images_rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_user = cinder
rbd_secret_uuid = 1ddabc08-4694-48ad-86e7-65dc24049829
disk_cachemodes="network=writeback"
inject_password = false
inject_key = false
inject_partition = -2
live_migration_flag="VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST,VIR_MIGRATE_TUNNELLED"
hw_disk_discard = unmap
```

Cấu hình nova với ceph.conf
```
nano /etc/kolla/config/nova/ceph.conf
[client]
rbd cache = true
rbd cache writethrough until flush = true
rbd concurrent management ops = 20
admin socket = /var/run/ceph/guests/$cluster-$type.$id.$pid.$cctid.asok
log file = /var/log/ceph/qemu-guest-$pid.log
```

Cấu hình neutron
```
nano /etc/kolla/config/neutron/dnsmasq.conf 
dhcp-option-force=26,1450

nano /etc/kolla/config/neutron/ml2_conf.ini
[ml2_type_vlan]
network_vlan_ranges = physnet1

nano /etc/kolla/config/neutron/dhcp_agent.ini
[DEFAULT]
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true
interface_driver = openvswitch
```

### 3. Cấu hình cho Kolla-Ansible
```
Ta cần cấu hình 2 file globals.yml và multinode
Chi tiết cấu hình xem 2 file globals.md và inventory.md
```

### 4. Lệnh tạo, kiểm tra, tái cấu hình dự án
```
kolla-ansible certificates -i multinode
kolla-ansible bootstrap-servers -i multinode
kolla-ansible prechecks -i multinode
kolla-ansible deploy -i multinode
kolla-ansible post-deploy -i multinode

Sau đó truy cập sửa dòng
nano /etc/kolla/admin-openrc.sh
export OS_CACERT='/etc/kolla/certificates/ca/root.crt'
```


