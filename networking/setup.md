### Cấu hình CCNA cơ bản

#### Cấu hình Router
```
hostname R1 : Đặt hostname
no ip domain-lookup : Tắt tính năng kiểm tra query dns câu lệnh trên terminal

# Bảo mật mật khẩu chế độ privileged Exec #
security password min-length 10
enable secret Ciscoenpa55
service password-encryption

# Banner thông báo
banner motd # UNAUTHORIZED ACCESS IS PROHIBITED #

# Cấu hình SSH
ip domain-name CCNA-lab.com
crypto key generate rsa
1024
username Admin1 privilege 15 secret Admin1pa55

# Chống tấn công Brute force
login block-for 180 attempts 4 within 120

# Cấu hình các đường Line (Console & VTY)
line con 0
 password Ciscoconpa55
 login
 exec-timeout 5 0
line vty 0 4
 transport input ssh
 login local
 exec-timeout 5 0

# Cấu hình Interface (Giả sử các cổng tương ứng)
interface g0/0
 description Connection to Staff
 ip address 192.168.0.1 255.255.255.128
 no shutdown

interface g0/1
 description Connection to Sales
 ip address 192.168.0.129 255.255.255.192
 no shutdown

interface g0/2
 description Connection to IT
 ip address 192.168.0.193 255.255.255.224
 no shutdown

copy running-config startup-config
```

#### Cấu hình Switch
```
hostname S1
no ip domain-lookup

# Bảo mật mật khẩu
enable secret Ciscoenpa55
service password-encryption

# Cấu hình Management IP (SVI) - Giả sử thuộc subnet IT
interface vlan 1
 ip address 192.168.0.194 255.255.255.224
 no shutdown

# Default Gateway để có thể quản lý từ xa
ip default-gateway 192.168.0.193

# Cấu hình đường Line
line con 0
 password Ciscoconpa55
 login
 exec-timeout 5 0
line vty 0 15
 password Ciscoconpa55
 login
 exec-timeout 5 0
```



enable
configure terminal

# 1. Cấu hình cơ bản & Bảo mật
hostname Town-Hall
service password-encryption
security password min-length 10
enable secret [Mật_khẩu_của_bạn_ít_nhất_10_ký_tự]
banner motd "WARNING: Unauthorized access is prohibited!"

# 2. Tạo User & SSH (Secure transport)
username netadmin secret Cisco_CCNA7
ip domain-name cisco.com
crypto key generate rsa
# Nhập 1024 khi được hỏi
line vty 0 4
 transport input ssh
 login local
exit

# 3. Cấu hình Interface G0/0 (IT Department LAN)
interface g0/0
 description Connection to IT Dept LAN
 ip address 192.168.1.126 255.255.255.224
 ipv6 address 2001:db8:acad:a::1/64
 ipv6 address fe80::1 link-local
 no shutdown

# 4. Cấu hình Interface G0/1 (Administration LAN)
interface g0/1
 description Connection to Admin LAN
 ip address 192.168.1.158 255.255.255.240
 ipv6 address 2001:db8:acad:b::1/64
 ipv6 address fe80::1 link-local
 no shutdown

# Kích hoạt định tuyến IPv6
ipv6 unicast-routing
exit
wr



enable
configure terminal

interface vlan 1
 description Management Interface
 ip address 192.168.1.157 255.255.255.240
 no shutdown
exit

# Trỏ về IP của cổng Router tương ứng (G0/1 của Town Hall)
ip default-gateway 192.168.1.158