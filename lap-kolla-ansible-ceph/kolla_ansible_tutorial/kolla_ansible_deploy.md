### Tài liệu triển khai kolla-ansible
#### Chuẩn bị môi trường
1. Yêu cầu
- Cần có 1 cụm Ceph trước, xem tài liệu triển khai Ceph
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
2. Tạo môi trường ảo để tránh xung đột
```
- python3 -m venv <tên_môi_trường>
Truy cập môi trường ảo
- source <tên_môi_trường>/bin/activate
Để thoát môi trường ảo
- deactivate
Lưu ý, bất kì khi nào làm việc với kolla-ansible, ta cần truy cập môi trường ảo
```
3. Clone mã nguồn, thiết lập nhánh triển khai
```
- git clone https://github.com/ceph/ceph-ansible.git
- git branch -a
Chuyển sang nhánh mong muốn và cài đặt các dependency
- git checkout <tên-nhánh>
- pip install -r requirements.txt
- ansible-galaxy install -r requirements.yml
```

Đảm bảo đã tạo 4 pool trên cụm Ceph
ceph osd pool create volumes
ceph osd pool create images
ceph osd pool create backups
ceph osd pool create vms

Kích hoạt rbd cho các pool
rbd pool init volumes
rbd pool init images
rbd pool init backups
rbd pool init vms

Copy file cấu hình cụm Ceph tới node deploy
ssh 10.10.210.32 sudo tee /etc/kolla/config/cinder/cinder-volume/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.32 sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.32 sudo tee /etc/kolla/config/nova/ceph.conf < /etc/ceph/ceph.conf
ssh 10.10.210.32 sudo tee /etc/kolla/config/glance/ceph.conf < /etc/ceph/ceph.conf

Tạo key cho user Openstack ứng với mỗi RDB Ceph để xác thực CephX
ceph auth get-or-create client.glance mon 'profile rbd' osd 'profile rbd pool=images' mgr 'profile rbd pool=images'
ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images' mgr 'profile rbd pool=volumes, profile rbd pool=vms'
ceph auth get-or-create client.cinder-backup mon 'profile rbd' osd 'profile rbd pool=backups' mgr 'profile rbd pool=backups'

Copy key sang node deploy
ceph auth get-or-create client.cinder | ssh 10.10.240.32 sudo tee /etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring
ceph auth get-or-create client.cinder | ssh 10.10.240.32 sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder.keyring
ceph auth get-or-create client.cinder-backup | ssh 10.10.240.32 sudo tee /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder-backup.keyring
ceph auth get-or-create client.cinder | ssh 10.10.240.32 sudo tee /etc/kolla/config/nova/ceph.client.cinder.keyring
ceph auth get-or-create client.glance | ssh 10.10.240.32 sudo tee /etc/kolla/config/glance/ceph.client.glance.keyring
