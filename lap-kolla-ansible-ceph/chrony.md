### Cấu hình đồng bộ chrony
1. Cài đặt chrony tại tất cả các node | apt install chrony
2. Triển khai cấu hình tại 1 node bạn chọn làm admin
```
- echo "allow 10.10.210.0/24" >> /etc/chrony/chrony.conf
- systemctl restart chrony
```
3. Các node còn lại
```
- Truy cập tệp chrony.conf, tìm dòng pool iburst sửa lại thành : pool 10.10.210.20 iburst
- systemctl restart chrony
```
### Tổng hợp lệnh Chrony
- chronyc sources : kiểm tra trạng thái đồng bộ thời gian node
