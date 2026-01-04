# 1. Đọc log

Nếu là nginx đọc log

```zsh
tail -f /www/wwwlogs/after5asia.com.error.log
```

# 2 Xử lý từng lỗi

Nếu là lỗi này:

```zsh
2025/12/02 14:49:55 [error] 3816#0: *1666 connect() failed (111: Connection refused) while connecting to upstream, client: 14.248.94.9, server: after5asia.com, request: "GET /favicon.ico HTTP/1.1", upstream: "fastcgi://127.0.0.1:9000", host: "after5asia.com", referrer: "http://after5asia.com/"
2025/12/02 14:49:55 [error] 3816#0: *1666 connect() failed (111: Connection refused) while connecting to upstream, client: 14.248.94.9, server: after5asia.com, request: "GET /favicon.ico HTTP/1.1", upstream: "fastcgi://127.0.0.1:9000", host: "after5asia.com", referrer: "http://after5asia.com/"
```

Do php fastcgi không chạy

```zsh
netstat -tuln | grep 9000
```

