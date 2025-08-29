## Document này cài bản Ceph Pacific

```
Chạy lệnh tạo môi trường ảo của python

python3 -m venv ceph-env

source ceph-ven/bin/activate

Thoát môi trường ảo

deactivate

cd ceph-ven

git clone https://github.com/ceph/ceph-ansible.git

cd ceph-ansible

git branch -a

git checkout stable-6.0

git pull

pip install -r requirements.txt

ansible-galaxy install -r requirements.yml
```

Các thư mục cần forcus

```
- inventory (tự tạo, định nghĩa cluster).
- group_vars/ (chỉnh cấu hình cluster, OSD, MON, MGR, RGW...).
- site.yml (copy từ sample, là playbook chính để chạy).
- roles/ (nơi ansible lấy task để triển khai, chỉ đọc tham khảo).
```

Các dịch vụ cấu hình

```
- mons : monitor, giám sát cụm
- osds : Ceph OSD Daemons, quản lý ổ đĩa
- mdss : Ceph Metadata Servers, dùng cho CephFS (filesystem phân tán)
- rgws : RADOS Gateway, cung cấp giao diện S3, tương thích Amazon S3 hoặc OpenStack Swift, thường triển khai khi dùng Ceph như một object storage cluster
- nfss : NFS Gateway, xuất CephFS hoặc RADOS Object Gateway ra ngoài qua NFS protocol
- rbdmirrors : RBD Mirror Daemon, dùng cho replication giữa hai cluster Ceph, cho phép block device (RBD image) được đồng bộ (asynchronous replication), thường dùng trong kịch bản DR (Disaster Recovery)
- clients : 
- iscsigws : iSCSI Gateway, 
- mgrs : Ceph Managers, bổ sung cho MON, cung cấp API, plugin và dashboard
- monitoring : Không phải dịch vụ gốc của Ceph, mà là nhóm chứa stack monitoring đi kèm (Prometheus, Grafana, Alertmanager)
```

Các dịch vụ chính

```
mons, mgrs, osds
- Bổ sung
mdss → nếu dùng CephFS.
rgws → nếu muốn S3/Swift.
nfss → nếu muốn NFS.
rbdmirrors → nếu replication sang cluster khác.
iscsigws → nếu cần iSCSI.
monitoring → nếu cần Prometheus/Grafana.
clients → để test hoặc mount Ceph trực tiếp.
```

