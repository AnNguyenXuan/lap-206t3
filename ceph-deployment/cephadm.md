Lệnh triển khai trên node monitor ceph
cephadm bootstrap --mon-ip 10.10.240.36 --cluster-network 10.10.240.0/24 --initial-dashboard-user admin --initial-dashboard-password 'Ohm_Hn20@)'

cephadm add-repo --release squid
cephadm install ceph-common


Orchestrator (ceph orch …) cần SSH không mật khẩu để deploy container sang các host mới
ssh-copy-id -f -i /etc/ceph/ceph.pub root@<another_node>
ssh-copy-id -f -i /etc/ceph/ceph.pub root@<another_node>


Lệnh này sẽ yêu cầu orch không tự động chọn node monitor, ta sẽ chọn thủ công
ceph orch apply mon --unmanaged


Add các node còn lại vào cluster
ceph orch host add CEPH-MON-VNPT-02 172.10.10.82
ceph orch host add CEPH-MON-VNPT-03 172.10.10.83

Add label admin
ceph orch host label add CEPH-MON-VNPT-02 _admin
ceph orch host label add CEPH-MON-VNPT-03 _admin

Add 2 node mon còn lại
ceph orch daemon add mon CEPH-MON-VNPT-02:172.10.10.82
ceph orch daemon add mon CEPH-MON-VNPT-03:172.10.10.83


Tạo OSD quản lý các ổ cứng
ceph orch host label add CEPH-DATA-VNPT-01 osd
ceph orch host label add CEPH-DATA-VNPT-02 osd


Xem danh sách thiết bị
ceph orch device ls


Add từng ổ 
ceph orch daemon add osd CEPH-DATA-VNPT-03:/dev/nvme0n1
ceph orch daemon add osd CEPH-DATA-VNPT-01:/dev/nvme1n1


Lấy tham số cấu hình osd
ceph config get mon osd_pool_default_pg_autoscale_mode

Xem website hoạt động
ceph mgr services


kiểm tra user
ceph dashboard ac-user-show admin

đổi mk 
echo "MatKhauMoi123" > /tmp/newpass.txt
ceph dashboard ac-user-set-password admin -i /tmp/newpass.txt

Xem danh sách trạng thái ổ
ceph osd tree


Khởi động lại ổ OSD
systemctl restart ceph-osd@<osd_id>.service
systemctl restart ceph-ea155a7c-7daf-11f0-b365-005056acf0cc@osd.0.


Kiểm tra tình trạng cụm ceph
ceph -s
ceph health detail

Tắt balancer cụm ceph, tức tự động cân bằng dữ liệu
ceph balancer off


Thiết lập tham số pool và min size, default là 3, 0
ceph config set global osd_pool_default_size 2
ceph config set global osd_pool_default_min_size 1


Thiết lập tham số để ceph dừng ghi dữ liệu
ceph config set global mon_osd_min_in_ratio 0.5

Thiết lập cho phép xóa pool
ceph config set mon mon_allow_pool_delete true

Force xóa pg
ceph osd pool rm volumes volumes --yes-i-really-really-mean-it


Xem địa chi node
ceph mon dump

Xem tất cả
ceph orch ps

Xóa toàn bộ
ceph orch host drain <hostname>

Xóa một dịch vụ
ceph orch daemon rm <daemon-name> --force

Loại bỏ host
ceph orch host drain *<host>*

