## Tổng hợp một số tools trên window
```
Công cụ chỉnh sửa ảnh : Skitch
Công cụ kiểm tra ổ cứng :  Hard Disk Sentinel 
Công cụ quét file : SpaceSniffer
Công cụ quản lý driver : DriverStoreExplorer
Công cụ sysadmin : Sysinternals
Công cụ SDK : Windows Assessment and Deployment Kit (ADK)
```


## Pooltag Memory leak check
```
Truy cập cài đặt công cụ WDK trên Microsoft

C:\Program Files (x86)\Windows Kits\10\Tools\64\poolmon.exe
Chạy trong thư mục Program x86
Nhấn P  → lọc Nonpaged Pool
Nhấn B  → sort theo Bytes

findstr /m /l "VFil" c:\Windows\System32\drivers\*.sys


```