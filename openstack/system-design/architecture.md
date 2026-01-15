### Mô hình Active-Active và Active-Standby
```
1. Mô hình Active-Active
Đặc điểm: Tất cả các node đều chủ động xử lý request cùng lúc
- Cơ chế:
Một Virtual IP (VIP) được quảng bá qua nhiều node.
Traffic được phân phối giữa các node (round robin, leastconn...).
- Ưu điểm:
Tận dụng tối đa tài nguyên (cả CPU, RAM, băng thông đều hoạt động).
Hiệu năng cao, scale dễ dàng.
- Nhược điểm:
Cấu hình phức tạp hơn, đặc biệt với các service yêu cầu session persistence (ví dụ Horizon, Keystone).
Khó đồng bộ trạng thái nếu service không stateless.
- Ứng dụng trong OpenStack:
Dùng cho API services (Keystone, Glance, Nova API, Neutron API, Placement...) vì các API này stateless, dễ scale ngang.
```
```
2. Active-Standby
Đặc điểm: Chỉ 1 node active, các node khác standby chờ failover.
- Cơ chế:
VIP chỉ gắn vào node active.
Khi active node hỏng, Keepalived chuyển VIP sang standby node.
- Ưu điểm:
Thiết kế đơn giản, dễ quản lý.
Tránh xung đột dữ liệu đối với service có trạng thái (stateful).
- Nhược điểm:
Tài nguyên lãng phí (standby node hầu như idle).
Failover có độ trễ (vài giây).
- Ứng dụng trong OpenStack:
Dùng cho MariaDB/Galera (dù bản chất Galera replication active-active, nhưng thường triển khai kiểu active-passive cho load balancer để tránh conflict khi write).
Một số service stateful khác (RabbitMQ, memcached có thể chạy active-active nhưng nhiều team vẫn chọn standby để ổn định).
```
| Tiêu chí               | Active-Active                              | Active-Standby                         |
| ---------------------- | ------------------------------------------ | -------------------------------------- |
| **Sử dụng tài nguyên** | Tối ưu (mọi node đều chạy)                 | Không tối ưu (chỉ 1 node chạy)         |
| **Khả năng mở rộng**   | Cao, scale ngang dễ dàng                   | Hạn chế                                |
| **Độ phức tạp**        | Cao hơn (cần session persistence, đồng bộ) | Đơn giản, dễ vận hành                  |
| **Độ sẵn sàng**        | Cao, không downtime khi 1 node hỏng        | Có downtime ngắn khi failover          |
| **Ứng dụng**           | Stateless API (Keystone, Nova API...)      | Stateful DB, MQ (MariaDB, RabbitMQ...) |
```
Active-Active: dùng cho các dịch vụ stateless, scale-out, yêu cầu hiệu năng.

Active-Standby: dùng cho dịch vụ stateful, dữ liệu nhạy cảm, cần an toàn hơn là hiệu năng.
```
### Phân biệt stateless và stateful
```
1. Stateless (không trạng thái)
Định nghĩa: Mỗi request được xử lý độc lập, server không cần nhớ thông tin từ các request trước.
- Đặc điểm:
Request nào đến cũng có đủ thông tin để xử lý.
Server không lưu “session” hay dữ liệu người dùng sau khi trả lời.
- Ưu điểm:
Dễ scale ngang (thêm node để chia tải).
Failover dễ, vì node nào cũng có thể xử lý request tiếp theo.
- Nhược điểm:
Client phải gửi nhiều thông tin hơn trong mỗi request (ví dụ token, auth data).
- Ví dụ trong OpenStack:
Keystone API: mỗi request gửi kèm token → server xác thực và trả kết quả, không cần nhớ “ai đang login” trên node đó.
Glance API, Nova API, Neutron API: hầu hết chỉ nhận/gửi JSON request-response, không lưu session.
```
```
2. Stateful (có trạng thái)
Định nghĩa: Server ghi nhớ trạng thái hoặc session của client giữa nhiều request.
- Đặc điểm:
Server giữ thông tin (session, cache, data đang xử lý).
Các request sau phụ thuộc vào context đã lưu trước đó.
- Ưu điểm:
Một số ứng dụng dễ xây dựng hơn (ví dụ chat, giao dịch DB).
Hiệu năng cao hơn trong vài trường hợp (ít phải gửi thông tin lặp lại).
- Nhược điểm:
Khó scale: vì request sau phải quay về đúng node đã lưu trạng thái.
Khó HA: khi failover có thể mất trạng thái.
- Ví dụ trong OpenStack:
MariaDB/Galera: giữ dữ liệu, transaction, lock → rõ ràng là stateful.
RabbitMQ: lưu message queue, đảm bảo thứ tự/độ tin cậy → stateful.
Horizon (Dashboard): giữ session login trong web server (cần cấu hình session persistence).
```
| Tiêu chí           | Stateless                         | Stateful                         |
| ------------------ | --------------------------------- | -------------------------------- |
| **Trạng thái**     | Không lưu, mỗi request độc lập    | Lưu session/context              |
| **Khả năng scale** | Dễ dàng, node nào cũng xử lý được | Khó hơn, cần đồng bộ trạng thái  |
| **Failover**       | Nhanh, ít ảnh hưởng               | Phức tạp, có nguy cơ mất dữ liệu |
| **Ví dụ**          | Keystone API, Glance API          | MariaDB, RabbitMQ, Horizon       |
```
Stateless phù hợp cho API services, scale-out dễ → thường chạy Active-Active.

Stateful phù hợp cho DB, MQ, cache, dashboard, khó HA hơn → hay chạy Active-Standby hoặc có cơ chế replication riêng.
```

