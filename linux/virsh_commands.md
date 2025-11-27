# Tổng hợp các lệnh và tham số để điều khiển máy ảo
```
virsh reboot <tên_hoặc_UUID_VM> : khởi động lại mềm
virsh start <tên_hoặc_UUID_VM> : khởi chạy
virsh shutdown <tên_hoặc_UUID_VM> : tắt máy
virsh destroy <tên_hoặc_UUID_VM> : tắt ngắt nguồn ngay lập tức
virsh reset <tên_hoặc_UUID_VM> : khởi động lại cứng                
virsh domstate <tên_hoặc_UUID_VM> : xem trạng thái
virsh dominfo <tên_hoặc_UUID_VM> : xem thông tin
virsh console <tên_hoặc_UUID_VM> : xem console máy ảo
```
### Một số lệnh hữu ích
```
setsid <task> > <file_logs> 2>&1 & : tạo 1 phiên chạy nền
ps aux | grep <name> : lọc phiên theo tên
kill -TERM <pid> : xóa phiên theo pid (TERM : 9 "kill cứng" 15 "dừng bình thường")
tail -n <số dòng> <file>: xem 50 dòng cuối 1 file
tail -f <file> : theo dõi file
du -sh * : xem dung lượng tệp tin và thư mục
df -h : xem dung lượng phân vùng
screen -S rsync_backup : tạo 1 shell độc lập để chạy tiến trình
ps aux | egrep 'litespeed|lshttpd'
pkill -f litespeed
pkill -f lshttpd
ssh -J annx-t66 -N -f -L 2000:172.16.0.205:80 nguyenxuanan@172.16.0.205
systemctl --failed
arp -a :
systemd-resolve --flush-caches (Linux) : xóa cache dns
grep -vE '^\s*(#|$)' <tên_file> : lấy các dòng không có dấu #, xuống dòng
```
### Các tools check device
```
- ipmitools
```
## Tổng hợp các lệnh
```
sudo dmidecode -t baseboard 
```
## GlusterFS
```
mount -t glusterfs 172,16,255,1:/home /home

GlusterFS cung cấp một giải pháp lưu trữ phân tán và khả năng mở rộng.
```