## Quy trình đưa host từ trạng thái maintain trở lại cluster (host đã joining)
```
Ví dụ add host A
Bước 1: Kiểm tra vSan 
Chọn 1 host thuộc cluster add host > Datastores > Check Datastores host có giống host A

Bước 2: Kiểm tra vDS
Chọn Mục Network > Tích chọn dvSwitch thuộc cluster > Host > Sắp xếp theo State kiểm tra các host maintain đã nằm trong dvSwitch chưa

Bước 3: Add host

```
