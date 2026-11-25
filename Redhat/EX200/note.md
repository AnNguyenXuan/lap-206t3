## Khóa RHCSA cho Linux Administrator

### SELinux
```
DAC (Discretionary Access Control) là cơ chế phân quyền truyền thống của Linux, trong đó chủ sở hữu tự quyết định ai được truy cập tài nguyên của mình.
Dựa trên : UID, GID, rwx, ACL -> Mặc định : Quyền tùy theo mode bit, ACL, umask -> Chủ yếu là đọc, ghi, thực thi


MAC (Mandatory Access Control) của SELinux thì áp dụng policy chung của hệ thống. Process và chủ sở hữu file không tự ý vượt qua được policy này.
Dựa trên : Security context (label) user:role:type:level -> Mặc định : Không có rule allow thì bị từ chối -> Rất chi tiết: open, append, name_bind, name_connect

Cách 2 cơ chế phối hợp
SELinux không thay thế DAC mà bổ sung thêm một lớp. Kernel thường kiểm tra DAC trước:
DAC từ chối thì bị chặn luôn, SELinux không cần xét.
DAC cho phép thì SELinux xét tiếp.

Để xem quyền MAC trên Linux
Với folder ls -ldZ
Với file ls -lZ
Với Process ps -AfZ

Các mode SELinux : 
Enforcing : Kích hoạt -> Chặn truy cập vi phạm -> Ghi AVC log -> Mode production
Permissive : Kích hoạt -> Không chặn Chặn truy cập vi phạm -> Ghi AVC log -> Mode debug
Disabled : Kích hoạt -> Không chặn Chặn truy cập vi phạm -> Không Ghi AVC log -> SELinux tắt, không áp dụng policy
Để xem mode đang sử dụng :
getenforce
sestatus 
Để đổi mode trong runtime :
setenforce 0
setenforce 1
Thư mục cấu hình /etc/selinux/config

```