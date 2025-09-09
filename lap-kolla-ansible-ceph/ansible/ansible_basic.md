### Hướng dẫn cài đặt Ansible
```
- Chạy quyền root, tại thư mục root tạo và truy cập môi trường ảo 
python3 -m venv ansible
source ansible/venv/bin/activate
pip install -U pip
mkdir ansible_quickstart && cd ansible_quickstart
```

### Kiến trúc
```
Ansible gồm 2 thành phần chính
- Node controller : Cài đặt Ansible, các cấu hình Inventory
- Node managed : Node được quản trị từ xa thông qua Ansible và các Inventory 
```

### Lợi ích chính của Ansible
```
Ansible cung cấp khả năng tự động hóa triển khai, linh hoạt, dễ mở rộng, giảm chi phí vận hành và cập nhập.
```

### Syntax cơ bản
```
- Để có thể khởi chạy Ansible trên một node khác
ssh-keygen
ssh-copy-id root@172.16.0.212
- Khởi tạo file inventory.ini có nội dung sau :
[myhosts]
172.16.0.212
- Xác minh inventory
ansible-inventory -i inventory.ini --list
- Kết quả sẽ cho ra như sau :
{
    "_meta": {
        "hostvars": {
            "172.16.0.212": {
                "ansible_local": {}
            }
        }
    },
    "all": {
        "children": [
            "ungrouped",
            "myhosts"
        ]
    },
    "myhosts": {
        "hosts": [
            "172.16.0.212"
        ]
    }
}
- Ping đến myhosts
ansible myhosts -m ping -i inventory.ini
- Kết quả :
172.16.0.212 | SUCCESS => 
    ansible_facts:
        discovered_interpreter_python: /usr/bin/python3.11
    changed: false
    ping: pong
- Ngoài triển khai bằng cấu trúc .ini, ta có thể định nghĩa nội dung bằng cấu trúc .yaml, điều này phù hợp khi số node quản lý tăng lên
myhosts:
  hosts:
    my_host_01:
      ansible_host: 172.16.0.212
- Kết quả cũng tương tự :
ansible-inventory -i inventory2.yaml --list
{
    "_meta": {
        "hostvars": {
            "my_host_01": {
                "ansible_host": "172.16.0.212",
                "ansible_local": {}
            }
        }
    },
    "all": {
        "children": [
            "ungrouped",
            "myhosts"
        ]
    },
    "myhosts": {
        "hosts": [
            "my_host_01"
        ]
    }
}
```

### Quy trình build một file cấu trúc .yaml
```
Tuân theo quy tắc sau :
- Đảm bảo tên nhóm là duy nhất, chữ hoa và chữ thường cũng phân biệt
- Tránh sử dụng khoảng trắng, dấu gạch nối, số đứng đầu
- Nhóm các hosts theo quy tắc What, Where, When
- What : các hosts đóng vai trò làm việc gì, ví dụ : Database, Web, v.v.
- Where : vị trí các hosts theo nhóm, ví dụ : Datacenter, Region, v.v.
- When : các giai đoạn của hosts, ví dụ : Development, Test, Staging, Production, v.v.
- Sử dụng cấu trúc metagroups :
metagroupname:
  children:
- Ví dụ :
leafs:
  hosts:
    leaf01:
      ansible_host: 192.0.2.100
    leaf02:
      ansible_host: 192.0.2.110

spines:
  hosts:
    spine01:
      ansible_host: 192.0.2.120
    spine02:
      ansible_host: 192.0.2.130

network:
  children:
    leafs:
    spines:

webservers:
  hosts:
    webserver01:
      ansible_host: 192.0.2.140
    webserver02:
      ansible_host: 192.0.2.150

datacenter:
  children:
    network:
    webservers:
    
- Set biến cho hosts duy nhất
webservers:
  hosts:
    webserver01:
      ansible_host: 192.0.2.140
      http_port: 80
    webserver02:
      ansible_host: 192.0.2.150
      http_port: 443

- Set biến cho toàn bộ hosts trong group
webservers:
  hosts:
    webserver01:
      ansible_host: 192.0.2.140
      http_port: 80
    webserver02:
      ansible_host: 192.0.2.150
      http_port: 443
  vars:
    ansible_user: my_server_user
```