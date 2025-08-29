#### Một số lỗi có thể gặp khi triển khai Ceph-ansible
1. Lỗi phân vùng gpt
```
Log error có từ khóa GPT

Ceph yêu cầu ổ cứng sạch, nếu trong quá trình cài ổ cứng có dữ liệu, rất dễ bị lỗi khi ceph sẽ đọc được bảng phân vùng gpt

Fix lỗi bằng cách làm sạch dữ liệu ổ cứng, trong trường hợp ổ đĩa ảo như Exsi thì phải chọn type Thick Erosin
```
2. Lỗi tồn tại key Docker
```
Log error có từ khóa Docker, gpg, keyrings

Ceph sẽ tự import key Docker nên cần xóa bỏ key Docker cũ, trong quá trình cài đặt nếu thấy Docker cũ thì Ansible sẽ tự động xóa

Fix lỗi bằng cách xóa Source tải Docker trên các node, ví dụ : rm /etc/apt/sources.list.d/docker.list
```
3. Lỗi không có quyền truy cập grafana dashboard
```
Log error requests.exceptions.HTTPError: 401 Client Error: Unauthorized for url: https://10.10.210.18:3000/api/dashboards/db

Lỗi nay do 2 yếu tố, tham số cấu hình trong group_vars/all.yml của Grafana đặt tên Dashboard, trong khi đó Ceph thì kết nối đến Dashboard1, tiếp theo là ta cần set password cho các user khác password mặc định.

Fix lỗi bằng cách đặt grafana_datasource: Dashboard1, dashboard_admin_password: <pass>, grafana_admin_password: <pass>
```