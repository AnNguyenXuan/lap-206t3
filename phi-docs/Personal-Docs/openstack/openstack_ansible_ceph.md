# 1. Quy mô, cấu hình

- 4 node gồm 1 controller và 2 compute và 1 node deployer
- NIC: một bond NIC hoặc NIC giống hệt ceph public, 1 NIC mgmt, 1 NIC không IP (có thể bond) giao tiếp nội bộ openstack
- Ổ cứng tầm 100GB, ram 12gb cpu 8cores

### Bảng phân tích kết nối mạng và yêu cầu cho các node

Dưới đây là bảng mô tả các node, vai trò, kết nối mạng cần thiết và yêu cầu kết nối đến Ceph:

| Node         | Vai trò         | NIC Management (SSH) | NIC OpenStack Internal | NIC kết nối Ceph (Public) | Cần cài đặt Ceph Client | Ghi chú                                                                                                                                                                                                  |
| ------------ | --------------- | -------------------- | ---------------------- | ------------------------- | ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| deployer     | Node triển khai | ✅ (ssh đến các node) | ❌                      | ❌                         | ❌                       | Chỉ dùng để chạy Kolla Ansible, không cần kết nối trực tiếp đến Ceph.                                                                                                                                    |
| controller01 | Control node    | ✅                    | ✅                      | ✅                         | ✅                       | Chạy services: Glance, Cinder, Keystone, Neutron, cần kết nối Ceph để truy cập storage backend [](https://docs.ceph.com/en/reef/rbd/rbd-openstack)[](https://programmersought.com/article/48396245867/). |
| compute01    | Compute node    | ✅                    | ✅                      | ✅                         | ✅                       | Chạy Nova Compute, cần kết nối Ceph để sử dụng RBD cho ephemeral disks và volume attachments [](https://docs.ceph.com/en/reef/rbd/rbd-openstack)[](https://programmersought.com/article/48396245867/).   |
| compute02    | Compute node    | ✅                    | ✅                      | ✅                         | ✅                       | Tương tự compute01.                                                                                                                                                                                      |
# 2. Triển khai

## 2.1 Đảm bảo thông suốt cho ops

**Trên node deployer**: Tạo SSH key pair (nếu chưa có):

```zsh
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
```

**Copy public key** đến tất cả các node (controller01, compute01, compute02):

```zsh
ssh-copy-id root@controller01
ssh-copy-id root@compute01
ssh-copy-id root@compute02
```

# 2.2 Cấu hình trên ceph

Tạo các pools trên ceph

```zsh
ceph osd pool create volumes 512 512
ceph osd pool create images 256 256
ceph osd pool create backups 16 16
ceph osd pool create vms 256 256

ceph osd pool application enable volumes rbd
ceph osd pool application enable images rbd
ceph osd pool application enable backups rbd
ceph osd pool application enable vms rbd

rbd pool init -p volumes
rbd pool init -p images
rbd pool init -p backups
rbd pool init -p vms
```

Tạo các keyrings cho openstack

**Tạo keyring cho Glance**:

```zsh
ceph auth get-or-create client.glance mon 'profile rbd' osd 'profile rbd pool=images' mgr 'profile rbd pool=images' -o /etc/ceph/ceph.client.glance.keyring
```

**Tạo keyring cho Cinder**:

```zsh
ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd pool=backups' mgr 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd pool=backups' -o /etc/ceph/ceph.client.cinder.keyring
```

**Tạo keyring cho Nova**:

```zsh
ceph auth get-or-create client.nova mon 'profile rbd' osd 'profile rbd pool=vms' mgr 'profile rbd pool=vms' -o /etc/ceph/ceph.client.nova.keyring
```

Trên các node openstack tạo thư mục:

```zsh
mkdir /etc/ceph
```

Sao chép sang controller01 (chạy Glance và Cinder):

```zsh
scp /etc/ceph/ceph.client.glance.keyring root@controller01:/etc/ceph/
scp /etc/ceph/ceph.client.cinder.keyring root@controller01:/etc/ceph/
scp /etc/ceph/ceph.conf root@controller01:/etc/ceph/
```

**Sao chép sang compute01 và compute02** (chạy Nova):

```zsh
scp /etc/ceph/ceph.client.nova.keyring root@compute01:/etc/ceph/
scp /etc/ceph/ceph.conf root@compute01:/etc/ceph/
scp /etc/ceph/ceph.client.nova.keyring root@compute02:/etc/ceph/
scp /etc/ceph/ceph.conf root@compute02:/etc/ceph/
```

**Phân quyền cho keyring**:

- Trên **controller01**:

```zsh
sudo chown glance:glance /etc/ceph/ceph.client.glance.keyring
sudo chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
```

Trên **compute01 và compute02**:

```zsh
sudo chown nova:nova /etc/ceph/ceph.client.nova.keyring
```

Copy key admin sang tạm để test

```zsh
scp /etc/ceph/ceph.client.admin.keyring  root@controller01:/etc/ceph/
scp /etc/ceph/ceph.client.admin.keyring  root@compute01:/etc/ceph/
scp /etc/ceph/ceph.client.admin.keyring  root@compute02:/etc/ceph/
```

Sau đó trên 1 trong 3 node openstack thử

```zsh
apt install ceph-common -y
ceph -s
```

### 🐍 2. Thiết lập môi trường trên node deployer

Node deployer dùng để chạy Kolla Ansible. Chúng ta sẽ thiết lập môi trường Python virtual environment (venv) để cài đặt Kolla Ansible và các dependencies.

#### a. Cài đặt các gói hệ thống cần thiết

**Trên node deployer** (Ubuntu 24.04), chạy các lệnh sau:

```zsh
sudo apt update
sudo apt install -y git python3-dev libffi-dev gcc libssl-dev python3-venv python3-pip
```

#### b. Tạo và kích hoạt virtual environment

Tạo thư mục cho venv và kích hoạt nó:

```zsh
sudo mkdir /etc/kolla && cd /etc/kolla
python3 -m venv kolla-venv
source kolla-venv/bin/activate
```

#### c. Cài đặt Kolla Ansible và dependencies

Trong venv, chạy các lệnh sau:

```zsh
pip install -U pip
pip install git+https://opendev.org/openstack/kolla-ansible@stable/2025.1
```

#### d. Thiết lập cấu hình Kolla Ansible

Tạo các thư mục cấu hình và sao chép file mẫu:

```zsh
cp -r /etc/kolla/kolla-venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla/
```

Tạo file inventory cho multinode:

```zsh
cp /etc/kolla/kolla-venv/share/kolla-ansible/ansible/inventory/multinode .
```

`globals.yml`

```zsh
nano globals.yml
```

```zsh
kolla_base_distro: "ubuntu"
kolla_install_type: "source"
openstack_release: "2025.1"

# Cấu hình network
network_interface: "ens34"  # NIC cho management network
neutron_external_interface: "ens39"  # NIC cho external network
api_interface: "{{ network_interface }}"
storage_interface: "{{ network_interface }}"
cluster_interface: "{{ network_interface }}"

# Cấu hình VIP
kolla_internal_vip_address: "10.10.210.137"  # VIP cho HA

# Kích hoạt các services
enable_cinder: "yes"
enable_cinder_backend: "yes"
enable_ceph: "no"  # Sử dụng Ceph external
enable_ceph_rbd: "yes"
enable_ceph_client: "yes"

# Cấu hình Ceph external
ceph_conf_file: "/etc/ceph/ceph.conf"
ceph_cluster_name: "ceph"
ceph_mon_hosts: "10.20.20.120, 10.20.20.121, 10.20.20.122"  # IP các Ceph MON
ceph_keyring_file: "/etc/ceph/ceph.client.{{ client_name }}.keyring"

# Cấu hình backend cho Cinder và Glance
cinder_backend_ceph: "yes"
#cinder_volume_group: "cinder-volumes"
glance_backend_ceph: "yes"
glance_default_store: "rbd"
nova_backend_ceph: "yes"

enable_loadbalancer: "no"
```

multinode

```zsh
[control]
controller01

[compute]
compute01
compute02

[network]
controller01

[storage]
controller01

[monitoring]
controller01

[deployment]
localhost       ansible_connection=local

[baremetal]
controller01
compute01
compute02

[bifrost]
```

Cài đặt các dependences

```zsh
kolla-ansible install-deps
```

```zsh
kolla-ansible bootstrap-servers -i multinode
```

### 🚀 4. Triển khai OpenStack với Kolla Ansible

**Trên node deployer**, thực hiện các bước sau:

Gen password

```zsh
kolla-genpwd
```

1. **Bootstrap các node**
    
```zsh
kolla-ansible bootstrap-servers -i ./multinode
```
    
2. **Kiểm tra pre-deployment**:

    
```zsh
kolla-ansible prechecks -i ./multinode
```
    
3. **Triển khai OpenStack**:
    
    
```zsh
kolla-ansible deploy -i ./multinode
```
    
4. **Tạo OpenStack RC file và khởi tạo môi trường**:
    
    bash
    
```zsh
kolla-ansible post-deploy
source /etc/kolla/admin-openrc.sh
```
    
5. **Kiểm tra deployment**:
    
    bash
    
    openstack hypervisor list
    openstack network agent list