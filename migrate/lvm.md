## Hướng dẫn convert với lvm dùng cho trường hợp live migrate, tránh downtime
```
Mô tả giả định trên 2 host ảo trong ESXI
Yêu cầu : 
- 2 host phải kết nối được đến nhau
- hệ thống có cài chạy lvm
- phân vùng backup cần có dung lượng >= phân vùng hiện tại
- giả định 2 host đang có 2 ổ cứng sda, sdb chạy lvm

root@debian12:~# lvs
  LV     VG Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  OS     OS -wi-ao---- <27.94g                                                    
  swap   OS -wi-ao---- 952.00m    

# Clone ra disk nội bộ
# Chạy backup
lvconvert --type mirror --alloc anywhere -m1 /dev/OS/OS
# Kiểm tra
lvs -a -o +devices | egrep "LV|OS"
# Tạo lvs backup
lvconvert --splitmirrors 1 --name OSCopy /dev/OS/OS

# Clone ra 1 external disk
# Ở bước này, gắn thêm 1 ổ cứng sdc
pvcreate /dev/sdc
vgextend OS /dev/sdc
lvconvert --type mirror -m1 /dev/OS/OS /dev/sdc
lvconvert --splitmirrors 1 --name OSCopy-External /dev/OS/OS /dev/sdc
lvchange -an /dev/OS/OSCopy-External
lvs -a -o +devices | egrep "LV|OS"
vgsplit OS migratevg /dev/sdc
vgchange -an migratevg

# Chuyển ổ cứng ảo sang host còn lại
# Scan để kiểm tra phân vùng
pvscan
vgscan
lvscan
vgimport migratevg
vgchange -ay migratevg


-------------------------------------------------------
Mô tả giả định trên 2 host ảo trong ESXI
Yêu cầu : 
- 2 host phải kết nối được đến nhau
- hệ thống có cài chạy lvm
- phân vùng backup cần có dung lượng >= phân vùng hiện tại
- giả định 2 host đang có 2 ổ cứng sda, sdb
- sda chạy chia phân vùng, sdb chạy lvm

# Với trường hợp hệ thống đang chạy partition thuần muốn chuyển sang lvm
# Cấu hình ban đầu
sda                     8:0    0   40G  0 disk 
├─sda1                  8:1    0  953M  0 part /boot
├─sda2                  8:2    0  954M  0 part [SWAP]
└─sda3                  8:3    0 27.9G  0 part /
sdb                     8:16   0   40G  0 disk 

# Tạo VG cho sdb
pvcreate /dev/sdb
vgcreate backup /dev/sdb
lvcreate -L 30G -n backup-host backup

# Rsync dữ liệu sang lvm
mkfs.ext4 /dev/backup/backup-host
mkdir -p /mnt/backup
mount /dev/backup/backup-host /mnt/backup

rsync -aAXH --numeric-ids --info=progress2 \
  --one-file-system \
  --exclude={"/dev/*","/proc/*","/sys/*","/run/*","/tmp/*","/mnt/*","/media/*","/lost+found"} \
  / /mnt/backup

mkdir -p /mnt/backup/{dev,proc,sys,run,tmp}
chmod 1777 /mnt/backup/tmp

# Boot lại bằng lvm
mount /dev/sda1 /mnt/backup/boot
mount --bind /dev  /mnt/backup/dev
mount --bind /proc /mnt/backup/proc
mount --bind /sys  /mnt/backup/sys
mount --bind /run  /mnt/backup/run
chroot /mnt/backup /bin/bash

# Sửa fstab theo uuid phân vùng
blkid /dev/backup/backup-host
grub-install /dev/sda
update-grub

# Reboot lại hệ thống
# Sau khi reboot, hệ thống đã chuyển sang lvm
sda                     8:0    0   40G  0 disk 
├─sda1                  8:1    0  953M  0 part /boot
├─sda2                  8:2    0  954M  0 part [SWAP]
└─sda3                  8:3    0 27.9G  0 part 
sdb                     8:16   0   40G  0 disk 
└─backup-backup--host 254:0    0   30G  0 lvm  /


------------------------------------------------
Thử nghiệm convert dữ liệu từ ổ NVME sang ổ cắm SATA thuần

# Cấu trúc phân vùng
sda                       8:0    0 558.9G  0 disk 
├─sda1                    8:1    0  1023M  0 part 
└─sda2                    8:2    0   100G  0 part 
  └─backup-backup--host 253:0    0    90G  0 lvm  
sr0                      11:0    1  1024M  0 rom  
nvme0n1                 259:0    0   1.7T  0 disk 
├─nvme0n1p1             259:1    0     1G  0 part /boot/efi
└─nvme0n1p2             259:2    0   100G  0 part /

# Đặt cờ ESP/boot cho chắc (không rescan)
parted -s /dev/sda set 1 esp on
parted -s /dev/sda set 1 boot on

# Format FAT32 và đặt nhãn với UEFI, ext2 với BIOS
mkfs.vfat -F32 -n EFI2 /dev/sda1 
mount /dev/sda1 /mnt/backup/boot/efi

# Tạo VG cho sdb
pvcreate /dev/sdb
vgcreate backup /dev/sdb
lvcreate -L 90G -n backup-host backup

# Rsync dữ liệu sang lvm
mkfs.ext4 /dev/backup/backup-host
mkdir -p /mnt/backup
mount /dev/backup/backup-host /mnt/backup

rsync -aAXH --numeric-ids --info=progress2 \
  --one-file-system \
  --exclude={"/dev/*","/proc/*","/sys/*","/run/*","/tmp/*","/mnt/*","/media/*","/lost+found"} \
  / /mnt/backup

mount --bind /dev  /mnt/backup/dev
mount --bind /proc /mnt/backup/proc
mount --bind /sys  /mnt/backup/sys
mount --bind /run  /mnt/backup/run
chroot /mnt/backup /bin/bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ubuntu --recheck
update-grub

# Sửa fstab trỏ tới phân vùng boot mới và phân vùng OS mới
lsblk -f

# Reboot và kiểm tra kết quả
sda                       8:0    0 558.9G  0 disk 
├─sda1                    8:1    0  1023M  0 part 
└─sda2                    8:2    0   100G  0 part /boot/efi
  └─backup-backup--host 253:0    0    90G  0 lvm  /
sr0                      11:0    1  1024M  0 rom  
nvme0n1                 259:0    0   1.7T  0 disk 
├─nvme0n1p1             259:1    0     1G  0 part
└─nvme0n1p2             259:2    0   100G  0 part 

# Chuyển đổi sang boot trên efi
efibootmgr -v
efibootmgr -o 0006,0005,0008,000A

# Nếu lỗi mount, có thể chroot lại nvme và update lại grub
mount /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/boot/efi
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys  /mnt/sys
chroot /mnt

grub-install --target=x86_64-efi --efi-directory=/boot/efi \
             --bootloader-id=ubuntu-nvme --recheck
update-grub

----------------------------------------------------
Chuyển đổi sang máy ảo ESXI với ổ cứng vừa backup

----------------------------------------------------
```

## Backup lvm bằng snapshot 
```
lvcreate --size 50G --snapshot --name os-snap /dev/Volume-data/os

# Rollback
lvconvert --merge /dev/Volume-data/os-snap
reboot
```