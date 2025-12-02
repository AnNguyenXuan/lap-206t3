# Hướng dẫn cài đặt php
## PHP 5.2.10
```
wget -c http://museum.php.net/php5/php-5.2.10.tar.gz
apt update

apt install -y build-essential autoconf libtool bison re2c pkg-config \
    libxml2-dev libssl-dev libcurl4-openssl-dev libjpeg-dev libpng-dev \
    libfreetype6-dev libbz2-dev libzip-dev \
    libmariadb-dev libmariadb-dev-compat

apt update
apt install -y libjpeg62-turbo-dev

apt update
apt install -y libpng-dev

apt install -y apache2

mkdir -p /usr/include/curl
ln -s /usr/include/x86_64-linux-gnu/curl/* /usr/include/curl/
ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/libjpeg.so 2>/dev/null || true
ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/libpng.so 2>/dev/null || true

# Kiểm tra 
ls -l /usr/lib/libjpeg.so
ls -l /usr/lib/x86_64-linux-gnu/libpng*.so
ls -l /usr/include/png.h || echo "no /usr/include/png.h"


cd ~/php-setup/php-5.2.10

./configure \
  --prefix=/usr/local/php52 \
  --with-config-file-path=/usr/local/php52/etc \
  --with-mysql \
  --with-zlib \
  --with-curl \
  --enable-mbstring \
  --with-gd \
  --with-jpeg-dir=/usr \
  --with-png-dir=/usr \
  --with-freetype-dir=/usr \
  --with-openssl \
  --enable-zip \
  --enable-sockets \
  --enable-soap

# Nếu cài lỗi, chạy 
make clean || true
rm -f config.cache

```
## Thử nghiệm cài bằng Docker
```
cd /root

docker network create php52_net

docker run --name php52_db \
  --network php52_net \
  -e MYSQL_ROOT_PASSWORD=kDZQ0e6omlIY7SES \
  -e MYSQL_DATABASE=after5asia_new \
  -e MYSQL_USER=after5asia_new \
  -e MYSQL_PASSWORD=ZAQ787kau244 \
  -d mysql:5.7

docker run --name php52_5asia \
  --network php52_net \
  -p 8080:80 \
  -v ./web:/project \
  -d kuborgh/php-5.2

echo "<?php phpinfo(); ?>" > web/info.php


sửa file ./web/conn.php
$db_host = "php52_db"; 

docker exec -it php52_5asia bash

# Kiểm tra trên giao diện info.php xem đường dẫn load configure file
sed -i 's/^short_open_tag\s*=\s*Off/short_open_tag = On/' /etc/php/apache2-php5.2/php.ini

apache2ctl restart

http://10.10.240.66:8080/info.php
```