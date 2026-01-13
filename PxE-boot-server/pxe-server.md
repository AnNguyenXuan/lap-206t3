## Cài đặt PxE boot
```
Cài đặt thư viện
apt update
apt install -y isc-dhcp-server tftpd-hpa nginx
```

### Cấu hình thư mục boot cài Debian12
```
mkdir -p /srv/tftp
cd /tmp
wget -O netboot.tar.gz https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar -xzf netboot.tar.gz -C /srv/tftp
chmod -R a+rX /srv/tftp
ls -lah /srv/tftp | head
ls -lah /srv/tftp/debian-installer/amd64/ | head
```

### Cấu hình tftp
```
nano /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure --verbose"

systemctl enable --now tftpd-hpa
systemctl restart tftpd-hpa
```

### Cấu hình isc
```
nano /etc/default/isc-dhcp-server

INTERFACESv4="ens224"
```

### Cấu hình dhcp
```
nano /etc/dhcp/dhcpd.conf


option architecture-type code 93 = unsigned integer 16;

subnet 192.168.50.0 netmask 255.255.255.0 {
  range 192.168.50.100 192.168.50.200;
  option routers 192.168.50.1;
  option subnet-mask 255.255.255.0;
  option domain-name-servers 8.8.8.8;

  next-server 192.168.50.10;

  # UEFI x86_64: trả bootnetx64.efi
  if option architecture-type = 00:07 {
    filename "debian-installer/amd64/bootnetx64.efi";
  } else {
    # Legacy BIOS: trả pxelinux.0
    filename "pxelinux.0";
  }
}

systemctl enable --now isc-dhcp-server
systemctl restart isc-dhcp-server

```

### Tạo menu
```
mkdir -p /srv/tftp/pxelinux.cfg
nano /srv/tftp/pxelinux.cfg/default

DEFAULT install
PROMPT 0
TIMEOUT 30

LABEL install
  KERNEL debian-installer/amd64/linux
  INITRD debian-installer/amd64/initrd.gz
  APPEND --- quiet

```

### Mở port fw (nếu có)
```
ufw allow 67/udp
ufw allow 69/udp
ufw allow 80/tcp
```

### Debug/Test
```
ss -lunp | egrep ':(67|69)\b'
```

