### Tổng hợp Ceph health: HEALTH_WARN
1. Lỗi bảo mật
```
Cảnh báo : mons are allowing insecure global_id reclaim

Nguyên nhân : Trong Ceph, global_id là một định danh duy nhất (một số nguyên) được gán cho mỗi thực thể (client hoặc daemon) đã được xác thực (authenticated) và đang kết nối với Ceph cluster. Vấn đề bảo mật xuất phát từ việc Ceph Monitor không yêu cầu các client phải chứng minh quyền sở hữu của global_id cũ một cách an toàn khi kết nối lại, kẻ tấn công đã có quyền xác thực trên cluster có thể giả mạo một client khác. Bằng cách đoán hoặc biết global_id của client đó, kẻ tấn công có thể "reclaim" global_id đó một cách không an toàn.

Cách fix : ceph config set mon auth_allow_insecure_global_id_reclaim false
```
2. Lỗi đồng bộ thời gian
```
Cảnh báo : clock skew detected on mon.openstack-data-1, mon.openstack-data-2

Nguyên nhân : Chưa đồng bộ cấu hình time server

Cách fix : Cài chrony trên tất cả các node, sử dụng 1 node làm node chính, các node khác đồng bộ tới, chi tiết xem ở chrony.md
```
3. Lỗi triển khai mgr
```
Cảnh báo : Failed to apply 1 service(s): mgr

Nguyên nhân :

Cách fix : 
```
4. Cảnh báo phân bố PGs trên cụm
```
Cảnh báo : PGs are not balanced across OSDs

Nguyên nhân : Có thể do không bật tự động cân bằng cụm, nên dẫn đến warning

Cách fix : 
```