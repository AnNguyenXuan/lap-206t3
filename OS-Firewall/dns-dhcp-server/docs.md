## Các giải pháp dns trong kiến trúc doanh nghiệp
```
Đánh giá :
1. unbound   
Hiệu năng tốt, bảo mật cao, hỗ trợ đa luồng, dễ cấu hình, khả năng mở rộng có, tùy biến thấp, có cache thông minh tốt

2. bind9 
Hiệu năng yếu, bảo mật cao, không tối ưu đa luồng, khó cấu hình, khả năng mở rộng thấp, tùy biến cao, có cache thông minh trung bình

3. powerDNS Recursor
Hiệu năng cao, bảo mật tốt, hỗ trợ đa luồng, cấu hình không khó, khả năng mở rộng cao, tùy biến cao, có cache thông minh rất tốt

4. Knot Resolver
Hiệu năng cao, bảo mật tốt, hỗ trợ đa luồng, cấu hình khó, khả năng mở rộng rất cao, tùy biến cao, có cache thông minh rất tốt
```

## Giải pháp dhcp trong kiến trúc doanh nghiệp
```
ISC DHCP Server (Đời cũ)
Truyền thống, chạy trên Linux
Hỗ trợ nhiều option
Ổn định nhưng single-thread
Bắt đầu bị thay thế bởi kea

ISC Kea DHCP Server (Đời mới)
Multi-thread, hiệu năng cực cao
API REST để quản lý động
Quản lý phân tán, clustering
Dùng nhiều tại ISP
```

## Firewall OS mã nguồn mở
```
IPFire, OPNsense dùng Unbound 
Do đó nếu lựa chọn triển khai firewall OS cho doanh nghiệp vừa và nhỏ, có thể cân nhắc 2 thằng này 
```