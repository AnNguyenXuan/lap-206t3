### Cài đặt Block Storage Ceph
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

Cấu hình OSD
ceph orch device ls
apt -y install ceph-volume

Nếu thích cấu hình nhanh
ceph orch daemon add osd openstack-data-1:data_devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,db_devices=/dev/sdb,/dev/sdc
ceph orch daemon add osd openstack-data-2:data_devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,db_devices=/dev/sdb,/dev/sdc
ceph orch daemon add osd openstack-data-3:data_devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,db_devices=/dev/sdb,/dev/sdc

Cấu hình chuẩn docs
cephadm shell --

Kiểm tra nhanh
cephadm shell -- ceph -s
cephadm shell -- ceph orch host ls
cephadm shell -- ceph orch ps
```