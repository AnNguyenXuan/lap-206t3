- Chuyển timezone về Việt Nam

```zsh
sudo timedatectl set-timezone Asia/Ho_Chi_Minh
```

- Cài đặt chrony để đồng bộ thời gian với một máy chủ NTP chỉ định

```zsh
sudo apt install chrony -y
```

Enable and start

```zsh
sudo systemctl enable chrony
sudo systemctl start chrony
```

Thêm pool local để đồng bộ

```zsh
sudo nano /etc/chrony/chrony.conf
```

Thêm dòng sau để cho các máy trong mạng LAN đồng bộ

```zsh
allow 10.110.200.0/24
```

Khởi động lại chrony

```zsh
sudo systemctl restart chrony
```

Kiểm tra

```zsh
sudo chronyc sources -v
```