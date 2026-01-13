## Foreman
```
Foreman là một provisioning & lifecycle manager cho máy vật lý/VM: bạn khai báo host + MAC + subnet + OS + template, rồi Foreman tự tạo luồng unattended installation (cài tự động) và có thể đi kèm Smart Proxy để quản lý các dịch vụ như DHCP/TFTP/DNS phục vụ PXE

Link: https://theforeman.org/manuals/3.17/quickstart_guide.html

Trước khi cài đặt, cần setup hosts
#127.0.1.1      foreman-server
192.168.50.10   foreman-server.example.org foreman-server

apt-get -y install ca-certificates
cd /tmp && wget https://apt.puppet.com/puppet8-release-bookworm.deb
apt-get install /tmp/puppet8-release-bookworm.deb

wget https://deb.theforeman.org/foreman.asc -O /etc/apt/trusted.gpg.d/foreman.asc
echo "deb http://deb.theforeman.org/ bookworm 3.17" | sudo tee /etc/apt/sources.list.d/foreman.list
echo "deb http://deb.theforeman.org/ plugins 3.17" | sudo tee -a /etc/apt/sources.list.d/foreman.list

apt-get update && sudo apt-get -y install foreman-installer
foreman-installer
```

## FAI
```
Link: https://fai-project.org/
Docs: https://fai-project.org/fai-guide/
Đây là môt công cụ mã nguồn mở giúp tự động hóa quá trình cài đặt và setup hệ điều hành

FAI chia triển khai thành 2 mảnh chính:
1. NFSROOT: một root filesystem nhỏ (môi trường chạy tạm trong lúc cài). Máy client sẽ boot kernel/initrd rồi mount root qua NFS để chạy quá trình cài đặt.
2. Configuration Space (cấu hình): nơi bạn định nghĩa máy theo lớp/role nào thì cài gì, chia ổ ra sao, chạy script gì.
FAI dùng mô hình class-based (theo lớp/role) nên bạn không phải viết 1 file cứng cho từng máy, mà tái sử dụng cấu hình theo nhóm.

apt update
apt install -y locales
dpkg-reconfigure locales
update-locale LANG=en_US.UTF-8

apt install -y fai-server fai-quickstart
fai-setup

Rebuild nếu lỗi xảy ra
rm -rf /srv/fai/nfsroot
fai-make-nfsroot -f -v
```

## Foreman
```
Link: https://theforeman.org/manuals/3.17/quickstart_guide.html
```
