## Quy trình cài đặt Raid mềm OS Debian
```
Tại bước cài đặt ổ cứng, chọn manual
Giả sử ta có 8 ổ cứng, chọn 2 ổ để cài OS, 6 ổ sẽ để dự phòng
Bước 1 : 
- Phân vùng 2 ổ cài OS : Ổ 1 [1 boot, 1 swap, 1 OS], Ổ 2 [1 trống, 1 swap, 1 OS]
Bước 2 : 
- Gộp 2 phân vùng OS lại thành RAID 1 và cho nó phân vùng root /
Bước 3 : 
- Lưu lại và cài grub lên ổ 1
Bước 4 : 
- Reboot và vào chế độ Rescue mode
Bước 5 : 
- Tại đây, ta cần mount /target vào đúng phân vùng root / của hệ thống
- Ở trên : phân vùng root thường là /dev/md
Bước 6 : 
mount --bind /dev /target/dev
mount --bind /proc /target/proc
mount --bind /sys /target/sys
chroot /target
Bước 7 : 
grub-install /dev/sdb
grub-install /dev/sdc
update-grub
grub-install --recheck /dev/sdb
Bước 8 :
exit
umount /target/dev /target/proc /target/sys
reboot
```
