## Các lớp dữ liệu trong linux

### 1. Ứng dụng / User Space

Lớp cao nhất, nơi các chương trình người dùng (như `cp`, `ls`, `tar`, database, ứng dụng…) gọi các hàm I/O (`open()`, `read()`, `write()`) để đọc/ghi dữ liệu.
Tất cả truy xuất dữ liệu đều bắt đầu từ đây và đi xuống các lớp bên dưới để thực hiện.

### 2. Virtual File System (VFS)

Đây là lớp trừu tượng hóa file system trong kernel Linux.
VFS cung cấp một giao diện chung để các ứng dụng thao tác với file dù trên bất kỳ filesystem nào (ext4, XFS, FAT, NFS…). Nó giúp thống nhất cách truy cập dữ liệu mà không cần biết file system cụ thể.

### 3. File System cụ thể

Lớp này là các driver filesystem thực sự như:
ext4, XFS, Btrfs, JFS… (filesystem trên ổ đĩa)
procfs, sysfs, tmpfs (hệ thống file ảo) 
Mỗi filesystem tổ chức dữ liệu, metadata (inode, directory, quyền truy cập…) theo quy luật riêng, nhưng đều tuân theo interface của VFS.

### 4. Page Cache / Cache dữ liệu

Linux có bộ nhớ đệm để lưu các trang dữ liệu đã đọc/ghi gần đây nhằm tăng tốc I/O. Page cache nằm giữa filesystem và block layer, giúp giảm số lần đọc/ghi vật lý.

### 5. Block Layer

Lớp này quản lý các device block (đơn vị dữ liệu cố định như 512B, 4KB…) và chuẩn hóa cách thức truyền I/O giữa filesystem và các device driver. Nó xử lý các truy vấn đọc/ghi lớn, hợp nhất yêu cầu và tối ưu thứ tự I/O.

### 6. I/O Scheduler

Là lớp xử lý lên lịch cho các yêu cầu I/O block do block layer đưa ra. Ví dụ các bộ lập lịch như `bfq`, `mq_deadline`, `kyber` giúp tối ưu throughput và giảm độ trễ.

### 7. Device Mapper / Volume Management

Đây là lớp trừu tượng hóa thiết bị block bằng cách gom nhiều ổ vật lý thành một thể logic (ví dụ Logical Volume Manager – LVM) hoặc hỗ trợ RAID, mã hóa (dm-crypt). Lớp này đứng giữa block layer và driver để cung cấp tính linh hoạt trong quản lý lưu trữ.

### 8. Device Drivers

Các driver này giao tiếp trực tiếp với phần cứng lưu trữ — ví dụ:

* NVMe driver
* SCSI driver
* SATA/ATA driver
Chúng nhận các yêu cầu block từ block layer/mapper và gửi đến thiết bị thực sự.

### 9. Phần cứng lưu trữ

Lớp thấp nhất, bao gồm ổ đĩa SSD/HDD, controller, nơi dữ liệu thực sự được ghi và đọc trên bề mặt vật lý hoặc flash. Đây là lớp xuất phát của dữ liệu lưu trữ.

## Tóm tắt mô hình lưu trữ trên Linux

Từ trên xuống dưới, dữ liệu đi qua các lớp sau:

1. Ứng dụng / user space
2. Virtual File System (VFS)
3. File system cụ thể (ext4, XFS, tmpfs, v.v.)
4. Page cache / bộ nhớ đệm
5. Block layer
6. I/O Scheduler
7. Volume/Device mapper (LVM, RAID, dm-crypt)
8. Device Drivers (NVMe, SCSI, SATA)
9. Phần cứng lưu trữ (SSD/HDD/Controller)