## Giải pháp Horizon
```
Horizon Connection Server -> AD : Dùng để view admin và quản trị
Horizon UAG


Horizon Cloud = Portal liên quan đến quản trị Cloud Desktop cung cấp cho khách hàng

```

### Cấu hình NSX Edge
```
1. NEW 
2. Settings
3. Chọn cấu hình, nhấn + chọn tenants
4. Add interface unlink
uplink : chọn dải internet 
Add IP primary, secondary theo quy hoạch
5. Add interface internal
internal : dải đã quy hoạch nội bộ cho khách hàng
Add IP primary gateway theo quy hoạch
6. Add gateway 171.244.15.254
7. Enable default firewall policy
```

