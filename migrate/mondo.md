## Hướng dẫn Setup Mondo Debian 12
```
Link cài đặt http://www.mondorescue.org/ftp/
Note : 
- Do link các dependency của Debian 12 không đầy đủ, và sau 7749 cách cài với các dependency của Debian 12 không thành công, tôi thử nghiệm cài dependency của Debian 11 và nó thành công (Ảo thật :V)
- Phương pháp này chưa thử nghiệm trên các distro khác, tuy nhiên tôi nghĩ thì vẫn áp dụng được
- Hiện nay mới chỉ dừng ở việc cài đặt, chưa thử nghiệm các tính năng của công cụ
```

### Giới thiệu các gói
```
mindi-busybox : tệp lệnh cho môi trường boot
mindi : môi trường boot
mondo : công cụ backup và restore
perl-MondoRescue : các module cốt lõi
perl-ProjectBuilder : công cụ dùng cho quản lý/build đa bản phân phối
```

### Quy trình cài đặt trên Debian 12
```
apt update
apt install -y gnupg ca-certificates
apt install -y afio gzip xorriso genisoimage buffer \
               lzop bzip2 mdadm parted gawk gddrescue \
               syslinux mtools isolinux

mkdir /mondo && cd /mondo

wget http://www.mondorescue.org/ftp/debian/11/libprojectbuilder-perl_0.16.2-1_all.deb
wget http://www.mondorescue.org/ftp/debian/11/libmondorescue-perl_3.2.2-1_all.deb
wget http://www.mondorescue.org/ftp/debian/11/mindi-busybox_1.21.1-1_amd64.deb
wget http://www.mondorescue.org/ftp/debian/11/mindi_3.0.2-1_amd64.deb
wget http://www.mondorescue.org/ftp/debian/11/mondo_3.2.2-1_amd64.deb

apt install ./libprojectbuilder-perl_0.16.2-1_all.deb
apt install ./libmondorescue-perl_3.2.2-1_all.deb
apt install ./mindi-busybox_1.21.1-1_amd64.deb
apt install ./mindi_3.0.2-1_amd64.deb
apt install ./mondo_3.2.2-1_amd64.deb

mondoarchive -V
mindi --version
```