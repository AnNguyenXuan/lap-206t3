## Cấu hình vlan cho linux TH trunk mode
```
# Bật hỗ trợ vlan nếu chưa có
sudo apt install vlan
sudo modprobe 8021q


# Load cấu hình để tự khởi động
echo "8021q" >> /etc/modules


# Interface vật lý để làm trunk
auto eno1
iface eno1 inet manual

# VLAN 240
auto eno1.240
iface eno1.240 inet static
    address 192.168.240.10      # IP VLAN 240 của bạn
    netmask 255.255.255.0
    gateway 192.168.240.1       # Gateway của VLAN 240 (nếu có)
    vlan-raw-device eno1

# (Tùy chọn) VLAN 210 nếu cần
# auto eno1.210
# iface eno1.210 inet static
#     address 192.168.210.10
#     netmask 255.255.255.0
#     vlan-raw-device eno1

```

## Cấu hình bond cho linux TH trunk mode
