### Quản trị và mở rộng
```
kolla-ansible reconfigure -i multinode --tags neutron
ansible-playbook -i hosts site.yml --tags monitoring
kolla-ansible -i inventory deploy --list-tags
kolla-ansible reconfigure -i multinode --tags haproxy
```
