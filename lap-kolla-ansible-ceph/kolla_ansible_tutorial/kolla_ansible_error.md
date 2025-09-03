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
- Task này của tôi lỗi do lưu SSL cũ tích hợp với IP khác, do đó trong quá trình build San file cert đã trỏ nhầm
- Xóa toàn bộ key cũ và build lại key mới

4. RUNNING HANDLER [mariadb : Wait for first MariaDB service to sync WSREP]
- Task này tùy thuộc vào error trả về sẽ có 2 phương án xử lý
- Nếu database chưa kịp khởi động thành công, thì deploy lại là xong
- Nếu lỗi không check được Mariadb, kiểm tra xem đã khai báo trong inventory biến Mariadb tại Group common chưa

5. TASK [service-ks-register : keystone | Creating/deleting services] :
Could not find versioned identity endpoints when attempting to authenticate. Please check that your auth_url is correct. SSL exception connecting to https://10.10.210.9:5000: HTTPSConnectionPool(host='10.10.210.9', port=5000): Max retries exceeded with url: / (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:992)')))\n", "module_stdout": "", "msg": "MODULE FAILURE: No start of json char found\nSee stdout/stderr for the exact error", "rc": 1}


### Lỗi sau khi đã triển khai
1. Lỗi SSL/TLS
- Lỗi không đúng đường dẫn SSL của Debian, kiểm tra các file login và đổi lại đường dẫn export OS_CACERT=/etc/ssl/certs/ca-certificates.crt

