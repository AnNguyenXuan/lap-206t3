
# Trường hợp network interface down

Check bằng lệnh

```zsh
ip a
```

Kiểm tra:

```zsh
cat /usr/local/directadmin/scripts/<NIC-name>
```

Xem bên trong có nội dung chưa, nếu chưa, sửa như sau:

```zsh
# Created by cloud-init on instance boot automatically, do not edit. 
# 
BOOTPROTO=dhcp 
DEVICE=eth0 
HWADDR=fa:16:3e:f6:a3:4a 
MTU=1450 
ONBOOT=yes 
STARTMODE=auto 
TYPE=Ethernet 
USERCTL=no
```

Tiếp theo enable lại NIC

```zsh
ifdown eth0
ifup eth0
```

Check xem ip mới là gì `ip a`

Sửa ip mới trong Directadmin_information.txt ở thư mục `/root`

Tiếp theo:

```
cd /usr/local/directadmin/custombuild 
./build rewrite_confs
```

Tiếp theo check xem DA có lỗi không

```zsh
systemctl status directadmin
```

Nếu DA lỗi, khởi động lại xem được không

```zsh
systemctl restart directadmin
```

Nếu không được, import key mới cho DA:

Copy key từ máy khác về:

```zsh
rsync -rav -e "ssh -p 22" --progress root@103.81.87.83:/usr/local/directadmin/conf/license.key /usr/local/directadmin/conf/license.ke
```
puqPgtq4d

Update key

```zsh
/etc/.directadmin/updatelicense.sh
```

Done