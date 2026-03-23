## Tổng hợp một số mẹo quản trị Window

### Các thư mục quan  trọng

![alt text](image.png)

### Một số lệnh hữu ích
```
manage-bde -status
manage-bde -protectors -disable C:

Xóa cache dns
ipconfig /flushdns (Windows)
```

### Cách tắt tiếng chuông khi ấn tab trên terminal
```
Tạo thư mục profile
New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force

Tạo profile
New-Item -ItemType File -Path $PROFILE -Force

Truy cập
notepad $PROFILE

Thêm dòng
Set-PSReadLineOption -BellStyle None
```
### Kiểm tra bản ghi dns
```
nslookup dcjourneys.com dnssec1.pavietnam.vn
nslookup dcjourneys.com dnssec2.pavietnam.vn
nslookup dcjourneys.com dnssecbak.pavietnam.net
```

### Cấp quyền chạy script ở mức độ user
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Một số lệnh chạy policy
```
rsop.msc : load cấu hình chính sách máy window hiện tại
gpresult /r
```