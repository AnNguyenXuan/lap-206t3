### Cài đặt và cấu hình ban đầu
```
Môi trường triển khai Debian12 , đấu nối cụm Ceph với Openstack kolla-ansible triển khai container trên distro Debian12
Trước khi triển khai cần kiểm tra version 
https://docs.openstack.org/kolla/2025.2/support_matrix
https://docs.ceph.com/en/latest/releases/#active-releases

Yêu cầu môi trường, cài docker, curl, lvm2 trên tất cả các node

Tại node đầu tiên, cài cephadm

CEPH_RELEASE=19.2.3
curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm
chmod +x cephadm

sudo ./cephadm add-repo --version $CEPH_RELEASE
sudo apt update
sudo ./cephadm install
which cephadm
cephadm install ceph-common

Xem cấu hình
cephadm bootstrap -h

Tạo key riêng cho cephadm (khuyến nghị)
ssh-keygen -t ed25519 -f /root/.ssh/cephadm_id -N ""

Copy public key sang 2 node kia (dùng IP public)
ssh-copy-id -i /root/.ssh/cephadm_id.pub root@10.10.210.19
ssh-copy-id -i /root/.ssh/cephadm_id.pub root@10.10.210.20

Tạo file cấu hình cluster : nano ceph-cluster.yaml

---
service_type: host
hostname: openstack-data-1
addr: 10.10.210.18
labels:
  - _admin
  - mon
  - mgr
  - osd
---
service_type: host
hostname: openstack-data-2
addr: 10.10.210.19
labels:
  - _admin
  - mon
  - mgr
  - osd
---
service_type: host
hostname: openstack-data-3
addr: 10.10.210.20
labels:
  - _admin
  - mon
  - osd
---
service_type: mon
placement:
  label: "mon"

Chạy bootstrap 
cephadm bootstrap \
  --mon-ip 10.10.210.18 \
  --cluster-network 10.10.20.0/24 \
  --apply-spec /root/ceph-cluster.yaml \
  --ssh-private-key /root/.ssh/cephadm_id \
  --ssh-public-key /root/.ssh/cephadm_id.pub \
  --initial-dashboard-user admin \
  --initial-dashboard-password 'Ohm_p2)6T3'

Nếu đã có cấu hình
cephadm shell --mount /root/ceph-cluster.yaml:/tmp/spec.yml:ro -- ceph orch apply -i /tmp/spec.yml --dry-run
cephadm shell --mount /root/ceph-cluster.yaml:/tmp/spec.yml:ro -- ceph orch apply -i /tmp/spec.yml

Cấu hình rõ public network
cephadm shell -- ceph config set global public_network 10.10.210.0/24

Kích hoạt module prometheus
ceph mgr module enable prometheus

Cấu hình OSD
ceph orch device ls
apt -y install ceph-volume

Dọn data trong ổ trước
sgdisk --zap-all /dev/sdb || true
wipefs -a /dev/sdb || true
ceph orch device ls --refresh

Nếu cấu hình DB/WAL ra các ổ riêng, tốt nhất cần chạy RAID 1 cho cụm SSD đó

Nếu thích cấu hình nhanh
ceph orch daemon add osd openstack-data-1:data_devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,db_devices=/dev/sdb,/dev/sdc
ceph orch daemon add osd openstack-data-2:data_devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,db_devices=/dev/sdb,/dev/sdc
ceph orch daemon add osd openstack-data-3:data_devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,db_devices=/dev/sdb,/dev/sdc

Cấu hình chuẩn docs
vgcreate ceph-block-0 /dev/sdb
vgcreate ceph-block-1 /dev/sde
vgcreate ceph-block-2 /dev/sdf
vgcreate ceph-block-3 /dev/sdg
lvcreate -l 100%FREE -n block-0 ceph-block-0
lvcreate -l 100%FREE -n block-1 ceph-block-1
lvcreate -l 100%FREE -n block-2 ceph-block-2
lvcreate -l 100%FREE -n block-3 ceph-block-3
vgcreate ceph-db-0 /dev/sdc
vgcreate ceph-db-1 /dev/sdd
lvcreate -l 50%VG -n db-0 ceph-db-0
lvcreate -l 50%VG -n db-1 ceph-db-0
lvcreate -l 50%VG -n db-2 ceph-db-1
lvcreate -l 50%VG -n db-3 ceph-db-1

ceph-volume lvm create --bluestore --data ceph-block-0/block-0 --block.db ceph-db-0/db-0
ceph-volume lvm create --bluestore --data ceph-block-1/block-1 --block.db ceph-db-0/db-1
ceph-volume lvm create --bluestore --data ceph-block-2/block-2 --block.db ceph-db-0/db-2
ceph-volume lvm create --bluestore --data ceph-block-3/block-3 --block.db ceph-db-0/db-3

Kiểm tra nhanh
cephadm shell -- ceph -s
cephadm shell -- ceph orch host ls
cephadm shell -- ceph orch ps
```