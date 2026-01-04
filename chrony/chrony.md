### Cấu hình đồng bộ chrony
1. Cài đặt chrony tại tất cả các node | apt install chrony
2. Triển khai cấu hình tại 1 node bạn chọn làm admin
```
echo "allow 10.10.210.0/24" >> /etc/chrony/chrony.conf
systemctl restart chrony
timedatectl set-timezone Asia/Ho_Chi_Minh
timedatectl status
apt update
```
3. Các node còn lại
```
- Truy cập tệp chrony.conf, tìm dòng pool iburst sửa lại thành : pool 10.10.210.10 iburst
- systemctl restart chrony
```

### Tổng hợp lệnh Chrony
```
chronyc sources : kiểm tra trạng thái đồng bộ thời gian node, kết quả hiển thị như đây là ok
``^* 10.10.210.10 4 6 17 3    -29us[-1119us] +/-   24ms``

chronyc tracking : kiểm tra nguồn
chronyc makestep : ép đồng bộ

# Setup timezone
timedatectl set-timezone Asia/Ho_Chi_Minh
timedatectl status
apt update
```