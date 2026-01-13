### Tài liệu cấu hình các tham số trong globals.yml và inventory
#### Cấu hình globals.yml
1. kolla_haproxy_ssl_settings 
- 3 tham số bao gồm modern, intermediate, legacy ứng với các cấp độ bảo mật khác nhau, đi cùng với đó là sự tương thích
- Về bảo mật : modern > intermediate > legacy
- Về độ tương thích với nhiều OS : legacy > intermediate > modern 

#### Cấu hình inventory