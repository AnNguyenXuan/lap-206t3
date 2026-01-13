## Quản trị đĩa ảo Glance
```
Cấu hình đĩa ảo

Ta có các loại đĩa ảo sau
ISO : Ảnh đĩa CD/DVD để boot installer (Ubuntu ISO, Windows ISO…). Dùng khi muốn boot từ CD-ROM để cài OS
QCOW2 : Định dạng copy-on-write của QEMU/KVM, hỗ trợ sparse (file nhỏ hơn raw), có thể mở rộng động. Phổ biến nhất khi hypervisor là KVM
RAW : Ảnh đĩa thô (không metadata/phân lớp). File thường lớn hơn qcow2 (không sparse), nhưng đơn giản và hay dùng cho một số backend
VMDK : Định dạng đĩa của VMware. Dùng khi bạn mang image từ VMware sang (hoặc môi trường hypervisor liên quan VMware)
VDI : Định dạng đĩa của VirtualBox
VHD : Định dạng đĩa thường gặp trong Hyper-V/Microsoft và cũng được nhiều hệ ảo hóa hỗ trợ
```
