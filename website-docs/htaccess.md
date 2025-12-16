## Fix htaccess
```
# Khi muốn chuyển hướng thư mục dự án từ /public_html sang /public_html/public/
# Tại thư mục /public_html cấu hình .htaccess như dưới

RewriteEngine On
RewriteBase /

RewriteCond %{THE_REQUEST} /public/([^\s?]*) [NC]
RewriteRule ^ %1 [L,NE,R=302]

RewriteRule ^((?!public/).*)$ public/$1 [L,NC]

# tạo thêm 1 file index.php trỏ sang thư mục
<?php
// Chuyển hướng về folder public
header('Location: ./public', true, 302);
exit;
```