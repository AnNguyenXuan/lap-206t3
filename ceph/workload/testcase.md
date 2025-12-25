## Tổng hợp các TH test S3 đã public ra Internet
```
1. Connectivity & Basic Function
Mục tiêu: Endpoint truy cập ổn từ Internet, tương thích S3 API cơ bản.
Công cụ : AWS CLI, s3cmd, rclone, mc

2. Authentication & Authorization
Mục tiêu: Mỗi khách là 1 tenant/user, không ai đọc/ghi nhầm sang ai.
Công cụ : AWS CLI, s3cmd, radosgw-admin

3. Data Integrity & Consistency
Mục tiêu: Khách thuê quan tâm nhất là mất dữ liệu / hỏng file / upload fail giữa chừng
Công cụ : rclone, AWS CLI multipart

4. Performance & Load Test
Mục tiêu: kiểm tra mỗi tenant được bao nhiêu throughput/ops, và cụm chịu tổng bao nhiêu trước khi error/latency xấu.
Công cụ : s5cmd, rclone, warp, COSBench

5. Resilience & Failure Test
Mục tiêu: Khi hỏng 1 thành phần, dịch vụ vẫn sống; khi degrade, phải có cảnh báo; khách không mất dữ liệu
Công cụ : systemctl / docker restart, tc netem, iptables

6. Security & Abuse Test
Mục tiêu: Không biến thành “kho chứa rác”, không bị scan khai thác, không lộ bucket/object.
Công cụ : testssl.sh hoặc sslyze (TLS scan), nmap, curl, wrk/k6/hey
```