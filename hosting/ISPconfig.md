## Hướng dẫn triển khai ISPconfig
```
# Để tìm hiểu về docs, có thể truy cập website
https://www.ispconfig.org/ispconfig/download/

# Chuẩn bị
sudo apt update && sudo apt upgrade -y
sudo hostnamectl set-hostname server.yourdomain.com

# Cài đặt ISPconfig chạy Apache2 server
wget -O - https://get.ispconfig.org | sh -s -- --use-ftp-ports=40110-40210 --unattended-upgrades

# Cài đặt ISPconfig chạy Nginx server
wget -O - https://get.ispconfig.org | sh -s -- --use-nginx --use-ftp-ports=40110-40210 --unattended-upgrades

# Chạy lệnh hỗ trợ 
wget -O - https://get.ispconfig.org | sh -s -- --help

# Khi có logs báo như kiểu này là ok
[INFO] Your ISPConfig admin password is: dRkZvHZhV7aQXbA
[INFO] Your MySQL root password is: uKmJyBKssjbzaGf7JbJv
[INFO] Warning: Please delete the log files in /root/ispconfig-install-log/setup-* once you don't need them anymore because they contain your passwords!
```

## Hướng dẫn sử dụng

Đối với quản trị viên (admin)
---
### Cấu hình trang System
#### 1. Hướng dẫn cấu hình firewall mở port 
```
Tích chọn add firewall port

Mục Server ấn chọn trang web mà mình muốn cấu hình

Cấu hình TCP ports cho các dịch vụ cơ bản

21 : FTP – cổng điều khiển (command control) cho giao thức FTP, để upload/download file. 
25 : SMTP không mã hóa — dùng để gửi mail giữa các mail server hoặc mail submission (nếu server mail bật). 
53 (+UDP) : DNS — dịch vụ chuyển tên miền ↔ IP (nếu server bạn cũng chạy DNS). 
110 : POP3 (mail) không mã hóa — để người dùng “kéo mail” từ server xuống máy client qua POP3. 
143 : IMAP (mail) không mã hóa — để người dùng truy cập hộp thư, duyệt mail server kiểu IMAP. 
465 : SMTP over SSL/TLS (SMTPS) — gửi mail mã hóa, bảo mật. 
587 : SMTP submission (mail) với STARTTLS/TLS — gửi mail từ client tới server (submission), thường dùng khi người dùng gửi mail từ mail client. 
993 : IMAPS — IMAP qua SSL/TLS (mail), đọc mail mã hóa. 
995 : POP3S — POP3 qua SSL/TLS (mail), lấy mail mã hóa. 
40110:40210 (dải port/passive FTP) : Dải port passive FTP — dùng khi client FTP kết nối ở chế độ passive: sau khi kết nối control (port 21), dữ liệu được truyền qua một port ngẫu nhiên trong dải này. 
```

#### 2. CP users 
```
Trang này dùng để quản lý thông tin cho users
```

#### 3. Remote users
```
Trang này dùng để tạo các tài khoản remote / API user — tức user mà các ứng dụng bên ngoài (script, hệ thống quản lý khác, plugin, phần mềm reseller, hệ thống tự động…) có thể dùng để tương tác với ISPConfig thông qua API (SOAP, remote API), không phải login thủ công vào giao diện web admin
```

#### 4. Extension
```
Hiện nay ISPconfig cung cấp 2 công cụ mở rộng chính 
1. isppscan : Dùng để bảo mật, quét mã độc thư mục 
2. sourceguardian : Dùng để mã hóa source code trước khi đẩy lên product
```

### Quản lý users
#### Cấu hình tạo users
```

```

Đối với users
---
### 
#### 1. 