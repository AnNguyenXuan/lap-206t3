### Lệnh thao tác với Openstack
```
Đổi password máy ảo : openstack server set --root-password <id-server>

Tạo flavor cho máy ảo : openstack flavor create --vcpus 4 --ram 8192 --disk 10 --ephemeral 10 m2.large

Tạo image cho máy ảo : openstack image create "Debian12" --file /path/images/debian12.img --disk-format qcow2 --container-format bare --public 

Tạo boot volume : openstack volume create --image <IMAGE_ID> --size <SIZE_GB> <VOLUME_NAME>

Tạo network : openstack network create selfservice1

Tạo subnet : openstack subnet create --subnet-range 192.0.2.0/24 --network selfservice1 --dns-nameserver 1.1.1.1 selfservice1-v4

Tạo router : openstack router create router1

Add router : openstack router add subnet router1 selfservice1-v4

Tao network : openstack network create --share --provider-physical-network physnet1 --provider-network-type flat provider1

Tao subnet : openstack subnet create --subnet-range 10.10.240.0/24 --gateway 10.10.240.254 \
--network provider1 --allocation-pool start=10.10.240.21,end=10.10.240.29 \
--dns-nameserver 1.1.1.1 provider1-v4

Tao external network : openstack network set --external provider1

Add external router : openstack router set router1 --external-gateway provider1

Tao rule : openstack security group rule create --proto icmp default

Tao rule : openstack security group rule create --proto tcp --dst-port 22 default

Tao float ip : openstack floating ip create provider1

Tao sshkey : openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey 

Doi pass root : sudo passwd root

Truy cập máy ảo : virsh console instance-0000001
```