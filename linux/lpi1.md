## LPI1
### Chủ đề 1 : Kiến trúc hệ thống
```
lspci : Xem danh sách các thiết bị pci kết nối
lspci -s <id> -v : Thông tin chi tiết về thiết bị 
lspci -s <id> -k : Thông tin chi tiết kernel thiết bị

lsusb : Xem danh sách các thiết bị usb kết nối
lsusb -t : Xem danh sách dưới dạng cây phân cấp
lsusb -s <id> : 
lsmod : Xem danh sách các module được tải

modprobe -r <tên_module> : gỡ bỏ module nào đó trong kernel 
modinfo -p <tên> : Xem thông tin module

/proc và /sys là 2 thư mục được tạo trong quá trình chạy, chứa các thông tin tiến trình chạy và tài nguyên phần cứng. Hầu hết thông tin sẽ được lưu trữ trong 2 thư mục này.

dmesg : Hiển thị các thông báo về kernel và hệ thống
journalctl --list-boots :

Địa chỉ UEFI System Partition trên MBR : 0xEF
Địa chỉ UEFI System Partition trên GPT : C12A7328-F81F-11D2-BA4B-00A0C93EC93B

Quy trình boot
Power On - BIOS/UEFI - Bootloader - Kernel - initramfs - systemd (PID 1) - Services - Login

```