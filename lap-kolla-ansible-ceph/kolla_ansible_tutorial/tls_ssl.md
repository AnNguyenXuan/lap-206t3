### Tài liệu SSL/TLS cấu hinh nội bộ
#### Giới thiệu TLS/SSL
```
- Chứng chỉ SSL được thiết kế để bảo mật web
- Nó có 3 file quan trọng:
+ crt : tổ chức chứng thực
+ cert : public key
+ key : private key
```
1. SAN (Subject Alternative Name)
```
- Trước đây, chứng chỉ SSL chỉ có một trường duy nhất để xác định tên miền, đó là trường Common Name (CN). Tuy nhiên, điều này gây ra nhiều bất tiện.
+ Nếu bạn có một website cần bảo vệ cả tên miền chính (ví dụ: yourdomain.com) và tên miền phụ (ví dụ: www.yourdomain.com), bạn sẽ cần hai chứng chỉ riêng biệt hoặc sử dụng các giải pháp phức tạp.
+ Nếu bạn có nhiều tên miền khác nhau trên cùng một máy chủ (multi-domain), việc quản lý chứng chỉ trở nên rất rắc rố
- SAN được tạo ra để giải quyết vấn đề đó. Nó cho phép bạn liệt kê nhiều tên miền, địa chỉ IP hoặc URI khác nhau trong cùng một chứng chỉ. Khi trình duyệt kiểm tra chứng chỉ, nó sẽ ưu tiên kiểm tra SAN trước, nếu không có SAN thì mới kiểm tra CN
- Để kiểm tra nội dung cert có SAN không
openssl x509 -in /etc/kolla/certificates/mariadb-cert.pem -noout -text
```
2. Kiểm tra với Curl
- curl -vk https://10.10.210.9:5000/v3