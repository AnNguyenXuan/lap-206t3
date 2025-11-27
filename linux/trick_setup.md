## Một số setup mẹo với hệ thống

### Tắt tiếng beep khi ấn tab
```
1. Dùng cho 1 profile duy nhất
nano ~/.inputrc
set bell-style none
bind -f ~/.inputrc

2. Dùng cho toàn bộ hệ thống
nano /etc/inputrc
set bell-style none
```

### Clear cấu hình ổ đĩa
```
# Cài đặt công cụ
apt install gdisk
apt install parted

# Xóa cấu hình
sgdisk --zap-all /dev/sdb
sgdisk --zap-all /dev/sdc
sgdisk --zap-all /dev/sdd
wipefs -a /dev/sdb
wipefs -a /dev/sdc
wipefs -a /dev/sdd

# Reset cấu hình cũ
partprobe /dev/sde
partprobe /dev/sdf
partprobe /dev/sdg
```

### Kiểm tra inodes
```
Một hệ thống file trong Linux được chia làm hai phần, đó là phần khối dữ liệu (data block) và phần inode. Phần block thì được cố định và không thể thay đổi, còn phần inode thì bạn có thể thay đổi được

Inode lưu toàn bộ thông tin mô tả file:
- Loại file (regular file, directory, symlink…)
- Kích thước file (bytes)
- Quyền truy cập (rwx)
- UID/GID của owner
- Timestamps (atime/mtime/ctime)
- Số lượng hard links
- Vị trí block dữ liệu trên disk (data block pointers)

Inode đóng vai trò gì trong hệ thống?
1. Quản lý file
Khi bạn “mở file”, Linux thực ra làm:
Tìm tên file trong directory → lấy inode number
Đọc metadata trong inode
Theo inode → tới đúng block chứa dữ liệu
2. Giới hạn số lượng file
Filesystem tạo số lượng inode cố định → nếu bạn hết inode thì:
Disk vẫn còn dung lượng
Nhưng bạn không tạo thêm file được
Rất hay xảy ra trên server log hoặc mail queue.
3. Quản lý hard link
Nhiều tên file khác nhau có thể trỏ về cùng một inode → gọi là hard link
…dẫn đến việc xóa một tên file chưa chắc đã xóa dữ liệu, nếu link count > 1.
4. Ảnh hưởng performance
Filesystem phải đọc inode để biết block nào chứa dữ liệu → tốc độ I/O phụ thuộc việc quản lý inode

ls -i filename : Xem inodes 
stat filename : Xem inodes + netadata
df -i : Kiểm tra số inodes sử dụng
ln file1 file2 : Tạo hardlink
ln -s file1 likename : Tạo Symbolic

Lưu ý : 
Ext2/3/4, XFS, UFS dùng inode.
NTFS và FAT32 không dùng inode mà có cấu trúc riêng.
```

### Hardlink và Symlink
```
Hard link là gì?
Hard link = 1 tên file khác trỏ tới cùng inode của file gốc.
Nghĩa là:
Hai file khác tên, nhưng chung inode, chung dữ liệu thật trên disk.
Xóa một file → dữ liệu chưa bị xóa, vì vẫn còn link khác giữ inode.
fileA ────→ inode 1234 ───→ data blocks
fileB ────→ inode 1234 ───→ data blocks
Tính chất:
Không phân biệt “file gốc” hay “bản link”: cả hai bình đẳng.
Cùng kích thước, cùng quyền, cùng metadata.
ls -i sẽ thấy inode number giống nhau.
Không tạo ra inode mới.
Hạn chế:
Không link được qua filesystem khác (khác partition).
Không dùng được cho directory (tránh loop)

Symbolic link = 1 file đặc biệt chứa đường dẫn đến file gốc.
Nghĩa là:
Symlink có inode riêng, không trỏ trực tiếp tới dữ liệu.
Chỉ giống như 1 “shortcut” hình thành bởi text path.
linkA ───→ inode 5678 ───→ "/path/to/fileA"
fileA ───→ inode 1234 ───→ data blocks
Tính chất:
Khác inode với file gốc.
Nếu file gốc bị xóa → symlink bị gãy (broken).
Symlink có kích thước bằng độ dài path.
Có thể link qua filesystem khác.
Có thể link tới directory.
```

### Bind mount 
```
Bind mount : ánh xạ 1 directory/file sang 1 vị trí khác trong cùng filesystem.
Bind mount tạm thời :
mount --bind /source /target

Bind mount vĩnh viễn, sửa trong fstab :
/source   /target   none   bind   0 0
```

### Cấu hình custom jobs định kỳ
```
Logrotate giúp tự động xoay vòng (rotate), nén, hoặc xóa log theo thời gian.
/etc/logrotate.d/custom


Thiết lập cron job.
crontab -e
```

