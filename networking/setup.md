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