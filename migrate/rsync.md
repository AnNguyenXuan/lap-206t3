## Lệnh đồng bộ dữ liệu 2 máy chủ
```
# Đối với 2 máy chủ chạy phân vùng thuần
rsync -avpogtStlHz --numeric-ids --exclude=/etc/fstab --exclude=/etc/network/* --exclude=/proc/* --exclude=/tmp/* --exclude=/sys/* --exclude=/dev/* --exclude=/mnt/* --exclude=/boot/* --exclude=/root/* / root@IP_NEW_VPS:/

# Đôi với 2 máy chủ chạy lvm 
rsync -avpogtStlHz --numeric-ids \
  --exclude=/etc/fstab \
  --exclude=/etc/network/* \
  --exclude=/etc/lvm/* \
  --exclude=/proc/* \
  --exclude=/tmp/* \
  --exclude=/sys/* \
  --exclude=/dev/* \
  --exclude=/run/* \
  --exclude=/mnt/* \
  --exclude=/media/* \
  --exclude=/lost+found \
  --exclude=/boot/* \
  / root@NEW-VM:/
```