## Lệnh đồng bộ dữ liệu 2 máy chủ
```
rsync -avpogtStlHz --numeric-ids --exclude=/etc/fstab --exclude=/etc/network/* --exclude=/proc/* --exclude=/tmp/* --exclude=/sys/* --exclude=/dev/* --exclude=/mnt/* --exclude=/boot/* --exclude=/root/* / root@IP_NEW_VPS:/
```