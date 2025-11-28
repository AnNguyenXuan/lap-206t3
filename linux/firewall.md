## Cấu hình firewall Linux
```
Firewall là cơ chế bảo vệ của linux, dựa trên backend mặc định nftables hoặc iptables. Tại các distro khác nhau của linux thường sẽ sử dụng một số bộ công cụ quản trị thay thế như ufw, firewalld để thao tác vì các công cụ này cung cấp một bộ cấu hình dễ dàng hơn so với các backend mặc định.

Hướng dẫn cấu hình với ufw

# Cài đặt
apt install ufw
ufw enable
ufw status

# Xem cấu hình hiện tại
ufw status verbose
ufw status numbered

# Thêm cấu hình
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Xóa cấu hình
ufw delete allow 80/tcp

```

## Một số lệnh với iptables
```
iptables -I OUTPUT 1 -p tcp --dport 1433 -j ACCEPT

```


