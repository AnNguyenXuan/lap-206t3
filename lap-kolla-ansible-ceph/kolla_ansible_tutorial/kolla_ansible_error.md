### Tổng hợp các lỗi task khi bootstrap-servers
1. TASK [openstack.kolla.etc_hosts : Ensure hostname does not point to 127.0.1.1 in /etc/hosts]
- task này do việc cấu hình tên host trong multinode sai tên
- Để fix, ta thêm tên node deploy vào /etc/hosts, đồng thời phải trùng với tên cấu hình trong multinode

### Tổng hợp các lỗi task khi prechecks
1. Check if cinder_cluster_name is configured for HA configurations
- task này fail khi chưa set tên cho cluster HA khi ta chạy multi-node, với 2 node storage hoặc controller trở lên
- Để fix, ta cần cấu hình tên cluster trong globals.yml : cinder_cluster_name = "name"

2. AttributeError: \\'DockerFactsWorker\\' object has no attribute \\'module\\'\\n'"}
- task này fail do chưa cài đủ các module cần thiết
- Để fix, ta cần cài đặt các module cần thiết trên node triển khai, tuy nhiên điểm lạ là thường thì khi chạy bootstrap-servers thì đáng lý quá trình phải cài rồi
- Trong TH của tôi, có vẻ do tôi cài đè lên cụm Ceph, do đó module Docker của kolla-ansible không nhận diện đc
- Giải pháp là build 1 node database riêng

### Tổng hợp các lỗi task khi delpoy
1. Internal Server Error (\"Get \"https://10.10.210.14:4000/v2/\": dial tcp 10.10.210.14:4000: connect: connection refused\")\\n'"}
- Lỗi này do registry server của Docker chưa có image, hoặc sai. Trong trường hợp của tôi thì do chưa có image nhưng lại cấu hình registry local.
- Đơn giản chỉ cần bỏ tham số registry Docker trong globals.yml là xong

2. Lỗi cert khi cấu hình Mariadb TLS/SSL
- Lỗi này nhiều khả năng có cấu hình TLS/SSL nhưng chưa chạy lệnh khởi tạo cho các node
- Thử fix bằng lệnh kolla-ansible certificates -i <inventory>
- Ngoài ra, cần kiểm tra [tls-backend] trong inventory đã khai báo mariadb chưa

3. [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: 
IP address mismatch, certificate is not valid for '10.10.210.11
- Lỗi này do SSL certificate không hợp lệ với IP