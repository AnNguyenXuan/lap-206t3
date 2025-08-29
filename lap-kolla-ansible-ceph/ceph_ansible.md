## Tài liệu ceph ansible
#### Chuẩn bị môi trường
1. Yêu cầu
- Chuẩn bị một node deploy cài ansible-ceph, các node còn lại được gọi là node setup. Sử dụng quyền root tại node deploy, đảm bảo /etc/hosts có nội dung sau:
```
<tên_node_setup> < ip_node_setup>
<tên_node_setup> < ip_node_setup>
<tên_node_setup> < ip_node_setup>
```
- Sau đó thực hiện copy-ssh key cho các node setup
```
- ssh-keygen
- ssh-copy-id root@<tên_node_setup>
```
2. Tạo môi trường ảo để tránh xung đột
```
- python3 -m venv <tên_môi_trường>
Truy cập môi trường ảo
- source <tên_môi_trường>/bin/activate
Để thoát môi trường ảo
- deactivate
Lưu ý, bất kì khi nào làm việc với ceph-ansible, ta cần truy cập môi trường ảo
```
3. Clone mã nguồn, thiết lập nhánh triển khai
```
- git clone https://github.com/ceph/ceph-ansible.git
- git branch -a
Chuyển sang nhánh mong muốn và cài đặt các dependency
- git checkout <tên-nhánh>
- pip install -r requirements.txt
- ansible-galaxy install -r requirements.yml
```
#### Các phiên bản tại thời điểm viết tài liệu
```
stable-3.0 Supports Ceph versions jewel and luminous. This branch requires Ansible version 2.4.

stable-3.1 Supports Ceph versions luminous and mimic. This branch requires Ansible version 2.4.

stable-3.2 Supports Ceph versions luminous and mimic. This branch requires Ansible version 2.6.

stable-4.0 Supports Ceph version nautilus. This branch requires Ansible version 2.9.

stable-5.0 Supports Ceph version octopus. This branch requires Ansible version 2.9.

stable-6.0 Supports Ceph version pacific. This branch requires Ansible version 2.10.

stable-7.0 Supports Ceph version quincy. This branch requires Ansible version 2.15.

main Supports the main (devel) branch of Ceph. This branch requires Ansible version 2.15 or 2.16.
```
#### Các thư mục cần lưu ý
```
Do hệ thống đã được đóng gói sẵn, ta không cần quan tâm quá nhiều các thư mục khác, dưới đây là 3 tệp và thư mục chính cần quan tâm
root@debian:~/ceph-ansible# ls
- site-container.yml.sample
- site.yml.sample 
- group_vars/
- ...
Ngoài ra, ceph-ansible sử dụng một file inventory tên hosts để quy định các node triển khai, file đó nếu ta cài ansible ở môi trường chính trong máy chủ, thì nó thường nằm ở /etc/ansible/hosts.Tuy nhiên do ta cài trong môi trường ảo, nên ta cần tự tạo file hosts này
```
#### Sơ lược các dịch vụ
```
Dưới đây là các dịch vụ của Ceph hỗ trợ triển khai với ansible, được quy định trong site-container.yml.sample hoặc site.yml.sample

mons: Ceph Monitors.
osds: Ceph OSDs (Object Storage Daemons).
mdss: Ceph Metadata Servers.
rgws: Ceph RGWs (RADOS Gateway).
nfss: Ceph NFS (Ganesha).
rbdmirrors: RBD (RBD Mirroring).
clients: Ceph Clients (máy khách).
iscsigws: iSCSI Gateways.
mgrs: Ceph Managers.
monitoring: Ceph Monitoring (ví dụ như Grafana, Prometheus).
```
#### Triển khai Ceph
```
Trong một hệ thống lớn, một cụm Ceph sẽ tách riêng vai trò của các node, node giám sát, node quản lý, node lưu trữ, từ đó sẽ cài đặt các dịch vụ khác nhau lên đó. Tuy nhiên trong lab, ta triển khai với số lượng nhỏ, test thì hoàn toàn có thể tích hợp chung.

Ceph cho phép ta triển khai cung cấp 3 dạng tài nguyên chính :
- Ceph file system : cung cấp lưu trữ dạng file
- Ceph block device : cung cấp lưu trữ dạng ổ cứng
- Ceph object gateway : cung cấp lưu trữ các định dạng tệp, ảnh, video

Tùy thuộc vào nhu cầu người dùng, ta sẽ cài đặt các dịch vụ tương ứng :
- Ceph block device : mons, osds, mgrs, monitoring
- Ceph file system : <update>
- Ceph object gateway : <update>
```
#### Cấu hình triển khai Ceph block device
```
- Tạo một file hosts tại thư mục ceph-ansible và cấu hình. Ở đây ta khai báo tên các node được sử dụng để cài đặt các dịch vụ của Ceph. Một kiến trúc cụm nhỏ cần ít nhất số node Mons là lẻ (1,3,5,..), Mgrs thường triển khai số lượng bằng với Mons và nằm cùng node Mons. Osds là dịch vụ quản lý ổ đĩa, có thể triển khai chung hoặc riêng tùy vai trò

[mons]
<tên_node_setup>
...
[osds]
<tên_node_setup>
...
[mgrs]
<tên_node_setup>
...
[monitoring]
<tên_node_setup>
...
```
