### Các bộ lệnh cơ bản
```
Cài đặt vmware tools
pkg install -y open-vm-tools-nox11


Reset Root password
pfSsh.php playback changepassword admin


Các lệnh kiểm tra mạng
ifconfig
netstat -an -p tcp | grep LISTEN
```

### Thao tác cấu hình VPN cho pfsence
```
CLient to Site

System > Certificate> Add

Firewall > Rules > Add > 

Firewall > Rules > OpenVPN > Add > Ok

```