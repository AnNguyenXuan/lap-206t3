## Tài liệu về Server Dell
```
Quy tắc đặt tên máy Server Dell bao gồm

1. Chữ cái đầu (kiểu hình thức)
    R = Rack-mount (Dạng lắp tủ rack)
    T = Tower (Dạng tháp, đứng)
    C = Cloud (Máy chủ mô-đun cho môi trường siêu lớn)
    M hoặc MX = Modular (Máy chủ phiến/Blade cho khung mô-đun)
    F = Flexible (Dạng Hybrid rack)
    XE, XR, HS = Dòng chuyên dụng (AI/ML, công nghiệp, Hyper-scale)

2. Số đầu tiên (Class/Performance)
    1 - 3	Máy chủ 1 CPU (Single-Socket)
    4 - 7	Máy chủ 2 CPU (Dual-Socket)
    8	Máy chủ 2 hoặc 4 CPU
    9	Máy chủ 4 CPU

3. Số thứ hai (Generation Naming)
    0	Thế hệ 10 (10G)	R705
    1	Thế hệ 11 (11G)	R710
    2	Thế hệ 12 (12G)	R720
    3	Thế hệ 13 (13G)	R730
    4	Thế hệ 14 (14G)	R740
    5	Thế hệ 15 (15G)	R750
    6	Thế hệ 16 (16G)	R760

4. Số cuối cùng (Processor Type)
    0 = Bộ xử lý Intel
    5 = Bộ xử lý AMD
    Đặc biệt với AMD thì có thêm thông tin số lượng CPU (R6515)
```

## Cài đặt iDRAC Service Module cho Debian
```
Link tham khảo : https://linux.dell.com/repo/community/openmanage/
apt install gnupg -y

# Tải tệp khóa công khai chính xác
wget -O- https://linux.dell.com/repo/pgp_pubkeys/0x1285491434D8786F.asc | gpg --dearmor | sudo tee /usr/share/keyrings/dell-iSM-debian-11-key.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/dell-iSM-debian-11-key.gpg] https://linux.dell.com/repo/community/openmanage/iSM/5400/bullseye/ bullseye main" | sudo tee /etc/apt/sources.list.d/dell-ism.list

apt update
apt install dcism -y

systemctl status dcismeng

systemctl enable dcismeng

systemctl start dcismeng

# Cài đặt các chế độ cho linux
apt update
apt install tasksel -y

systemctl get-default

# Chế độ terminal
systemctl set-default multi-user.target

# Chế độ GUI
sudo systemctl set-default graphical.target
```
## SD Module
```
IDSDM là viết tắt của Internal Dual SD Module (Mô-đun SD kép nội bộ) của Dell.

IDSDM là một mô-đun phần cứng đặc biệt trong các máy chủ Dell PowerEdge, có chức năng chính là cung cấp một giải pháp lưu trữ có khả năng dự phòng (redundancy), thường được sử dụng để khởi động Hệ điều hành (OS) hoặc Hypervisor (như VMware ESXi, Citrix XenServer, hoặc Microsoft Hyper-V)

IDSDM cho phép máy chủ khởi động trực tiếp từ hai thẻ SD (hoặc microSD) được lắp trên mô-đun này

Bằng cách sử dụng thẻ SD để chạy Hypervisor/OS, bạn có thể dành toàn bộ các ổ cứng HDD/SSD chính của máy chủ cho việc lưu trữ dữ liệu hoặc Datastore của máy ảo, tối ưu hóa hiệu suất và dung lượng lưu trữ.
```
## IPMI
```
IPMI là viết tắt của Intelligent Platform Management Interface (Giao diện Quản lý Nền tảng Thông minh).

Đây là một bộ tiêu chuẩn công nghiệp mở dùng để quản lý phần cứng máy chủ. IPMI hoạt động độc lập với CPU, BIOS và Hệ điều hành (OS) của máy chủ thông qua một bộ xử lý chuyên dụng gọi là BMC (Baseboard Management Controller) – mà trong các máy chủ Dell, BMC được tích hợp trong iDRAC

# Để cài đặt
apt install ipmitool

# Một số lệnh
ipmitool -I lanplus -H 10.10.240.170 -U root -P htv@2025 power status
ipmitool -I lanplus -H 10.10.240.170 -U root -P htv@2025 bmc info

# Tạo file lưu đăng nhập
touch ~/.ipmitool.conf
nano ~/.ipmitool.conf

# Tạo profile cho máy chủ Dell-r730xd
[dell-r730xd]
host = 10.10.240.170
username = root
password = htv@2025
interface = lanplus

# Đăng nhập thử nghiệm
ipmitool -N dell-r730xd power status
```