## FTP server
```
apt update
apt install vsftpd -y
systemctl status vsftpd

cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

#Cấu hình các tham số sau
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000

ufw allow 22/tcp
ufw allow 21/tcp
ufw allow 20/tcp
ufw allow 40000:50000/tcp

# Tạo user
adduser ftpuser
sudo chown -R ftpuser:ftpuser /home/ftpuser

# Kiểm tra đăng nhập tên terminal
ftp ip
```