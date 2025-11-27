# Triển khai mail server
## Cài đặt một số dịch vụ mã nguồn mở phổ biến
### 1. Mailcow
```

```

### 2. Modoboa
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl gnupg2 wget python3 python3-venv python3-pip
sudo hostnamectl set-hostname mail.anserver.vn
git clone https://github.com/modoboa/modoboa-installer
cd modoboa-installer

sudo ./run.py --stop-after-configfile-check mail.anserver.vn

Chỉnh sửa config trước khi cài đặt
[certificate]
generate = true
type = letsencrypt

[letsencrypt]
email = cloud247.admin@mail.anserver.vn

[database]
engine = mysql     # hoặc postgres
host = 127.0.0.1
install = true

sudo ./run.py mail.anserver.vn

# Chế độ update, reconfig
sudo ./run.py --upgrade mail.anserver.vn

```