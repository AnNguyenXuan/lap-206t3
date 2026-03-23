### Cài đặt Window Server 2016 DAAS
```
Chọn phiên bản Window Server 2016 Standard Desktop > Custom Window Only
```

### Cài đặt AD trên Window Server 2016
```
Bước 1: Cài vmware tools, horizon agent
VMware tools: Cài đặt ở ngoài
Horizon Agent (Templates, máy ảo user): Settings > DVD > VMware-Horizon-Agent.iso
Vào máy ảo, chạy bộ cài iso vừa mount

Bước 2: Chỉnh tên máy trong local server, cấu hình IP (không gateway), DNS localhost

Bước 3: Cài AD
1.Add roles and features
2.Role based
3.Chọn Server cần cài 
4.AD domain service và DNS server
5.NET Frame 3.5 
6.Next and Install

Bước 4: Tại logs thông báo, cấu hình deployment configure

Bước 5: 

```
### Hướng dẫn cài DHCP Server trên Window Server 2016
```
Bước 1: Server Manager
Bước 2: Add role and features
Bước 3: Các bước cài đặt chọn đúng Server cần cài, chọn DHCP server roles

```
