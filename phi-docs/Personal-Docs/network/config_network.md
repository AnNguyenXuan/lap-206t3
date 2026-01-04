```zsh
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: false
  vlans:
    vlan210:
      id: 210
      link: eno1
      dhcp4: false
      addresses:
        - 192.168.210.191/24
      routes:
        - to: default
          via: 10.10.210.254
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```