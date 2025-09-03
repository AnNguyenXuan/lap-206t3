### Tổng hợp các lệnh Ansible
ansible-playbook -i hosts site.yml --tags monitoring

### Tổng hợp các lệnh Kolla-Ansible
kolla-ansible -i inventory deploy --list-tags