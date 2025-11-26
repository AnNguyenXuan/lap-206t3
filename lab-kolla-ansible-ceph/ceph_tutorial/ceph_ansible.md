## Tài liệu ceph ansible
#### Chuẩn bị môi trường
1. Yêu cầu
- Chuẩn bị một node deploy cài ansible-ceph, các node còn lại được gọi là node setup. Sử dụng quyền root tại node deploy, đảm bảo /etc/hosts có nội dung sau:
```
<tên_node_setup> < ip_node_setup>
<tên_node_setup> < ip_node_setup>
<tên_node_setup> < ip_node_setup>
```
- Cấu hình mẫu
```
10.10.240.18 ceph1
10.10.240.19 ceph2
10.10.240.20 ceph3
10.10.240.165 lb1
10.10.240.166 lb2
```

- Sau đó thực hiện copy-ssh key cho các node setup
```
- ssh-keygen
- ssh-copy-id root@<tên_node_setup>
```
2. Tạo môi trường ảo để tránh xung đột
```
- apt install -y python3-venv git
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
- ansible all -m ping -i inventory.ini
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
#### Fix lỗi callback
```
nano ansible.cfg
[default]
stdout_callback = default
result_format = yaml
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
- Tạo một file hosts tại thư mục ceph-ansible và cấu hình. Ở đây ta khai báo tên các node được sử dụng để cài đặt các dịch vụ của Ceph. Một kiến trúc cụm nhỏ cần ít nhất số node Mons là lẻ (1,3,5,..) để đạt Quotum, Mgrs thường triển khai số lượng bằng với Mons và nằm cùng node Mons. Osds là dịch vụ quản lý ổ đĩa, có thể triển khai chung hoặc riêng tùy vai trò

nano hosts.ini

[mons]
ceph1 ansible_host=10.10.240.18
ceph2 ansible_host=10.10.240.19
ceph3 ansible_host=10.10.240.20

[mgrs]
ceph1
ceph2
ceph3

[osds]
ceph1
ceph2
ceph3

[rgws]
ceph1
ceph2
ceph3

[rgwloadbalancers]
lb1 ansible_host=10.10.240.165
lb2 ansible_host=10.10.240.166

[monitoring]
ceph1   # hoặc 1 node riêng nếu bạn muốn tách

[all:vars]
ansible_user=root
ansible_become=true


- Cấu hình all.yml triển khai 

nano group_vars/all.yml

dummy:
mon_group_name: mons
osd_group_name: osds
rgw_group_name: rgws
mgr_group_name: mgrs
rgwloadbalancer_group_name: rgwloadbalancers
monitoring_group_name: monitoring
ceph_origin: repository
valid_ceph_origins:
  - repository
ceph_repository: community
valid_ceph_repository:
  - community
ceph_mirror: https://download.ceph.com
ceph_stable_key: https://download.ceph.com/keys/release.asc
ceph_stable_release: squid
ceph_stable_repo: "{{ ceph_mirror }}/debian-{{ ceph_stable_release }}"
ip_version: ipv4
monitor_interface: ens224
public_network: "10.10.210.0/24"
public_interface: ens224
cluster_network: "10.10.20.0/24"
cluster_interface: ens256
radosgw_frontend_type: beast # For additional frontends see: https://docs.ceph.com/en/latest/radosgw/frontends/
radosgw_frontend_port: 8080
radosgw_interface: ens224
radosgw_num_instances: 1
containerized_deployment: false
dashboard_enabled: true
dashboard_admin_user: admin
dashboard_admin_password: "Ohm_p2)6T3"
grafana_admin_user: admin
grafana_admin_password: "Ohm_p2)6T3"

nano group_vars/osds.yml

dummy:
devices:
   - /dev/sdb
   - /dev/sdd
dedicated_devices:
   - /dev/sdc
   - /dev/sdc
osd_auto_discovery: false
crush_device_class: "hdd"
osds_per_device: 2
crush_rule_config: true
crush_rule_hdd:
  name: HDD
  root: default
  type: host
  class: hdd
  default: false
crush_rules:
  - "{{ crush_rule_hdd }}"

nano group_vars/rgwloadbalancers.yml 

dummy:
haproxy_frontend_port: 80
haproxy_frontend_ssl_port: 443
virtual_ips:
   - 10.10.240.167
virtual_ip_netmask: 24
virtual_ip_interface: ens192
```

### Deploy
```
setsid ansible-playbook -i inventory.ini site.yml -e 'yes_i_know=true' > deploy.logs 2>&1 &
```
