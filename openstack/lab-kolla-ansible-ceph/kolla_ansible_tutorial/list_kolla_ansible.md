- Lenh : kolla-ansible certificates -i all-in-one
- Lenh : kolla-ansible bootstrap-servers -i all-in-one 
- Lenh : kolla-ansible prechecks -i all-in-one
- Lenh : kolla-ansible deploy -i all-in-one
- Lenh : kolla-ansible post-deploy -i all-in-one


--------------------------------------------------------------

Thưc mục default : kolla-ansible/venv/share/kolla-ansible/ansible/group_vars/all.yml
qg-cb7dbbd1-41

Cấu hình tên các node trong /etc/hosts

cài đặt ufw, chrony trên tất cả các node

Kiểm tra trạng thái thời gian
timedatectl status

Đồng bộ thời gian
timedatectl set-ntp true