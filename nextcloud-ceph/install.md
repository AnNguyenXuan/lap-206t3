## Chuẩn bị môi trường
```
Tùy thuộc sở thích, có thể lựa chọn các OS khác nhau

Ubuntu 24.04 LTS
Ubuntu 22.04 LTS (recommended)
Red Hat Enterprise Linux 9 (recommended)
Red Hat Enterprise Linux 8
Debian 12 (Bookworm)
SUSE Linux Enterprise Server 15
openSUSE Leap 15.5
CentOS Stream

Ở đây, phiên bản tôi lựa chọn là Debian 12, các câu lệnh có thể khác nhau tùy phiên bản OS. Các câu lệnh cài đặt dưới đây được sử dụng để cài đúng phiên bản yêu cầu của các dịch vụ cần thiết. Bao gồm mariadb 10.11, apache 2.4, php 8.2

sudo apt update && sudo apt upgrade -y
sudo apt install unzip curl wget gnupg lsb-release -y

sudo apt install mariadb-server mariadb-client -y
mariadb --version : nên là phiên bản 10.6, 10.11, 11.4

sudo apt install -y \
  apache2 libapache2-mod-php \
  php php-cli php-mysql php-xml php-curl php-gd php-mbstring php-zip php-fpm \
  php-intl php-apcu php-redis redis-server php-imagick \
  ffmpeg libreoffice

apache2 -v : phiên bản 2.4
php -v : phiên bản 8.2

sudo a2enmod rewrite headers env dir mime
sudo systemctl restart apache2

php -m | egrep -i "ctype|curl|dom|fileinfo|filter|gd|mbstring|openssl|posix|session|simplexml|xml(reader|writer)|zip|zlib|intl|sodium|apcu|redis|imagick"
```
## Cài đặt
```
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
- sửa bind-address 127.0.0.1 thành 0.0.0.0
sudo systemctl restart mariadb


sudo mariadb -u root -p

CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'ncuser'@'%' IDENTIFIED BY 'Ohm_p2)6T3';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'ncuser'@'%';
FLUSH PRIVILEGES;
EXIT;

- Cài đặt Nextcloud
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
sudo mv nextcloud /var/www/
sudo chown -R www-data:www-data /var/www/nextcloud
sudo chmod -R 755 /var/www/nextcloud

- Cấu hình Apache2
sudo nano /etc/apache2/sites-available/nextcloud.conf
<VirtualHost *:80>
    ServerAdmin admin@example.com
    ServerName 10.10.240.9
    DocumentRoot /var/www/nextcloud

    <Directory /var/www/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog ${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>

sudo a2ensite nextcloud.conf
sudo a2dissite 000-default.conf
sudo a2enmod rewrite headers env dir mime ssl
sudo systemctl reload apache2

Sau đó, truy cập : http://10.10.240.9
Điền các thông tin đăng nhập, database
```

## Cài đặt thông qua Docker
```
Đảm bảo cài đặt Docker trên host

yin sepia runaround freebase slimness enquirer disjoin tipper
```