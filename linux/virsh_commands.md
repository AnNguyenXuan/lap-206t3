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
kill -TERM <pid> : xóa phiên theo pid
tail -n <số dòng> <file>: xem 50 dòng cuối 1 file
tail -f <file> : theo dõi file
du -sh * : xem dung lượng tệp tin và thư mục
df -h : xem dung lượng phân vùng
```