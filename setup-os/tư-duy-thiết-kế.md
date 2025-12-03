## Cấu hình RAID
```
1. Phân loại 
Ta có các loại RAID cơ bản gồm : 
- RAID 0 : split 
- RAID 1 : mirror
- RAID 5 : 1 backup parity
- RAID 6 : 2 backup parity
- RAID 10 : gộp 2 RAID 0 và RAID 1

Ngoài ra còn có raid 50, raid 60, v.v.

2. Thiết kế
Việc lựa chọn cấu hình cho RAID tùy thuộc vào nhu cầu và mục đích sử dụng
- Mục tiêu cài OS, có thể lấy 2 ổ đầu tiên cài 
- Mục tiêu lưu trữ, có thể gộp tất các ổ lại

Ngoài ra, trong quá trình cài đặt OS, việc chia phân vùng vào các ổ đặc biệt có thể tối ưu hiệu năng đọc ghi tổng thể.
Ví dụ, trong linux ta có thể chia thư mục /home vào ổ cứng nvme riêng nếu dữ liệu đọc ghi trên ổ này lớn.
```