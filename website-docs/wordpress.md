## Tài liệu wordpress

### Tài nguyên
```
Link tạo secret key 
https://api.wordpress.org/secret-key/1.1/salt/
```

### Lệnh cài đặt wp cli
```
cd /tmp
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp --info
```

### Cài đặt core
```
cd /var/www/clients/client1/web1/web
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz
```

### Lệnh thao tác 
```
## checksum kiểm tra mã nguồn
cd /home/hongphuc/domains/plastichongphuc.com/public_html
wp core verify-checksums --allow-root

## Nếu checksum báo mismatch
wp core download --skip-content --force --allow-root

## Trong TH báo proc_open() proc_close() are disabled 
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp --info
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp core verify-checksums --allow-root
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp core download --skip-content --force --allow-root

## Update DB
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp core update-db --allow-root

## Deactivate plugins (1 trong 2 cách)
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp plugin deactivate woocommerce --allow-root --skip-plugins --skip-themes
mv wp-content/plugins/woocommerce wp-content/plugins/woocommerce_broken

## Cài lại plugins
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp plugin install woocommerce --force --activate --allow-root --skip-themes

## checksum plugins
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp plugin verify-checksums woocommerce --allow-root --skip-themes

## Hiển thị danh sách plugins
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp plugin list --status=active --allow-root

## Lệnh update plugins
/usr/local/php74/bin/php74 -d disable_functions= /usr/local/bin/wp plugin update insert-headers-and-footers --allow-root --skip-themes

```

