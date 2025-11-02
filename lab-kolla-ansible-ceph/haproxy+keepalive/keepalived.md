### Tài liệu giới thiệu về Keepalive
---
```1. Ý tưởng về phần mềm```

Keepalived là phần mềm viết bằng C chuẩn ANSI/ISO nhằm cung cấp tính high availability (HA) và load balancing cho hệ thống Linux. Thiết kế cốt lõi xoay quanh một I/O multiplexer trung tâm (event loop) để xử lý tác vụ mạng theo thời gian thực, hướng tới mã nguồn an toàn, ổn định và dễ bảo trì

---
```2. Kiến trúc tiến trình```

Daemon của Keepalived được tách thành 3 tiến trình: 

(1) tiến trình parent tối giản làm “watchdog”

(2) tiến trình VRRP phụ trách failover VIP 

(3) tiến trình healthchecking kiểm tra tình trạng dịch vụ trên mỗi node

Mỗi tiến trình con có event loop riêng nhằm giảm “jitter” lập lịch của VRRP (tác vụ nhạy cảm hơn healthcheck). Watchdog giám sát các tiến trình con qua UNIX domain socket và định kỳ gửi “hello” để phát hiện treo/đơ và tự khởi động lại khi cần

---
```3. Các thành phần kernal```

Keepalived sử dụng 4 thành phần của kernal linux bao gồm :

LVS : Dùng để giao tiếp socket

Netfilter : Mã IPVS hỗ trợ NAT và Masquerading

Netlink : Quản lý IP ảo VRRP trên các Network Interface

Multicast : Mạng quảng bá riêng 224.0.0.18

---
```4. Lớp phần mềm```

Keepalived được cấu thành từ các lớp phần mềm sau :

Control Plane : Đọc config từ file keepalived.conf và ánh xạ vào bộ nhớ

Scheduler / I-O Multiplexer : event-loop tập trung để lập lịch tác vụ I/O; framework tự trừu tượng hóa “thread” cho networking, không phụ thuộc POSIX threads

Memory management: chế độ thường & debug để truy dấu rò rỉ bộ nhớ; buffer fixed-length để giảm rủi ro overflow

Core components: thư viện chung (HTML parsing, list, timer, vector, format chuỗi, dump buffer, utils mạng, quản trị daemon/PID, TCP L4)

Watchdog: cơ chế parent/child hoạt động hoàn toàn qua I/O multiplexer và tín hiệu

System Call: hook chạy script ngoài (MISC checker, hoặc khi VRRP chuyển trạng thái) trong tiến trình fork riêng để không làm nhiễu scheduler

Netlink Reflector: lắng nghe broadcast Netlink (RTMGRP_LINK, RTMGRP_IPV4_IFADDR) để phản chiếu thay đổi giao diện/địa chỉ vào cấu trúc dữ liệu người dùng

IPVS Wrapper: ánh xạ dữ liệu nội bộ sang libipvs để đẩy quy tắc vào kernel IPVS

Syslog/SMTP: log toàn bộ thông báo qua syslog; SMTP dùng FSM đa luồng để gửi thông báo khi healthcheck/VRRP đổi trạng thái

---
```5. Các framework```

Healthcheck Framework

VRRP framework

---
```6. Các kĩ thuật cân bằng tải```

### Hướng dẫn setup 
```
OS : Debian 12
Mô hình : 2 node 1 active 1 standby

Cài đặt 
apt-get install keepalived


```

