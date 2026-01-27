## Một số công cụ check lỗi
```
Công cụ check lỗi
apt install netcat-traditional 

nc -vz -w2 10.10.240.168 8080
curl -I --max-time 3 http://10.10.240.168:8080/

nft list ruleset | head -n 120
```

## Lưu ý về Keepalived và Haprxy 
```
1. Keepalived có cơ chế quản trị firewall để tránh việc data truyền sẽ sang node Backup, không nên dùng cơ chế này.
Thay vào đó, ta sẽ tạo script check trạng thái để loadbalance khi cài keepalived

2. Keepalived có đặc tính
Cơ chế bình thường của keepalived + VRRP
Keepalived chạy VRRP để bầu chọn 1 node giữ VIP (MASTER).
Node MASTER định kỳ gửi VRRP Advertisement ra network.
Node BACKUP nghe quảng bá đó, thấy MASTER còn sống thì không giữ VIP.
Nếu BACKUP không nhận được quảng bá trong một khoảng thời gian (Master_Down_Interval) thì nó kết luận MASTER chết và tự lên MASTER, gắn VIP vào interface.

3. Cơ chế split-brain trong Keepalived
Split-brain xảy ra khi:
Node A không nhận được VRRP advert từ node B
Node B cũng không nhận được VRRP advert từ node A
Khi đó, cả hai đều nghĩ bên kia chết, cả hai cùng lên MASTER, cả hai cùng add VIP, bạn thấy VIP xuất hiện trên cả node-1 và node-2.
Nguyên nhân phổ biến :
Multicast bị chặn/lọc trên vSwitch/portgroup (nhiều môi trường enterprise làm thế).
IGMP snooping bật nhưng không có IGMP join đúng cách nên switch không forward multicast đến port kia.
Policy bảo mật chặn IP protocol 112 (nhiều firewall rule chỉ nghĩ TCP/UDP).
Một số overlay/SDN xử lý multicast không chuẩn.
Phương án fix :
VRRP unicast nghĩa là:
MASTER gửi advert trực tiếp tới IP của peer (10.10.240.165 - 10.10.240.166)
Không còn phụ thuộc multicast 224.0.0.18
Cực hợp với VM/vSwitch môi trường khắt khe

4. VRRP Protocol 
Trong IPv4 header có 1 trường tên là Protocol 8 bit, dùng để nói payload trong là giao thức gì
TCP = 6
UDP = 17
ICMP = 1
VRRP = 112
Tức là VRRP không chạy trên TCP/UDP port. Nó là một IP protocol riêng.
Vậy nó không phải là 1 cổng định danh là 112, nó là allow IP protocol 112.
Cơ chế bảo vệ quan trọng TTL=255
VRRP advert (chuẩn RFC) thường yêu cầu:
Gói VRRP phải có TTL = 255
Node nhận sẽ drop nếu TTL != 255
Mục đích:
đảm bảo gói chỉ đến từ cùng local link
chống spoof từ xa (qua router), vì qua router TTL sẽ giảm <255

5. Ý nghĩa địa chỉ 224.0.0.18
Dải 224.0.0.0/24 thuộc dải link-local multicast
Router không forward các gói này sang subnet khác
Tức là VRRP advert chỉ tồn tại trong cùng broadcast domain/VLAN
Mapping sang MAC multicast
Multicast IPv4 sẽ map sang MAC multicast dạng 01:00:5e:xx:xx:xx.
Với 224.0.0.18, MAC thường sẽ là:
01:00:5e:00:00:12
(12 là 0x12 = 18 thập phân).
Switch L2 thực ra forward multicast dựa theo MAC này (và IGMP snooping nếu bật).
```

## Cơ chế hoạt động
```
Giả sử :
advert_int 1 (MASTER gửi advert mỗi 1 giây)
Node-1 priority 110, node-2 priority 100

Bình thường :
Mỗi giây node-1 (MASTER) gửi 1 advert.
Node-2 (BACKUP) nhận advert, reset timer, không làm gì cả.

Khi node-2 ngừng nhận advert :
Ví dụ multicast bị chặn hoặc mạng flap:
Node-2 bắt đầu đếm mất MASTER.
Nếu quá ngưỡng Master_Down_Interval, node-2 tự lên MASTER và add VIP.

Tại thời điểm đó:
Node-1 vẫn nghĩ nó MASTER (vì nó vẫn chạy) nên nó vẫn giữ VIP.
Node-2 cũng lên MASTER nên nó cũng giữ VIP.
=> VIP nằm ở cả 2 node.

Master_Down_Interval tính thế nào?
VRRP không chờ đúng 3 giây một cách ngẫu nhiên; nó có công thức để tránh 2 backup cùng nhảy lên master đúng cùng lúc.
Một cách hiểu đơn giản:
Master_Down_Interval ≈ (3 × advert_int) + skew_time
advert_int: chu kỳ advert
skew_time: một số lệch phụ thuộc priority để giảm khả năng cùng failover
Với advert_int=1, failover thường rơi vào khoảng 3–4 giây (tùy priority)

Priority quyết định ai làm MASTER
Trong VRRP, node có priority cao nhất thắng (nếu cùng VRID, cùng interface segment).
Node-1: 110
Node-2: 100
=> Node-1 sẽ làm MASTER nếu mọi thứ bình thường.
Nếu Node-1 chết hoặc priority Node-1 tụt xuống thấp hơn Node-2, Node-2 sẽ lên MASTER.

Track_script + weight: failover theo dịch vụ, không chỉ theo node
Cơ chế :
vrrp_script chạy định kỳ (interval)
Nếu fail liên tiếp fall lần => script coi là down
Keepalived cộng weight vào effective priority của node đó

Ví dụ:
base priority Node-1 = 110
Node-2 = 100
weight của chk_haproxy = -60

Nếu haproxy trên node-1 chết:
effective priority node-1 = 110 + (-60) = 50
node-2 vẫn 100
node-2 thắng => node-2 lên MASTER => VIP nhảy.

Vì sao bạn nên đặt cả hai state BACKUP?
Ưu điểm:
giảm cứng nhắc theo cấu hình state
tránh một số cảnh báo/edge-case trong strict mode
dễ vận hành, nhất quán
Nó giống kiểu để VRRP tự bầu cử, mình chỉ gợi ý bằng priority

Nên tune những thông số nào cho production?
Gợi ý cấu hình:
advert_int 1 là ổn (failover ~3–4s)
Script check:
interval 2
fall 2 (fail 2 lần mới coi down)
rise 2 (pass 2 lần mới coi up)
Weight:
chọn sao cho: priority_master + weight < priority_backup
GARP refresh:
có thể thêm garp_master_refresh để cập nhật ARP sau failover, giảm dính ARP cũ.
```

## Scripts check 2 node
```
cat >/usr/local/bin/chk_haproxy.sh <<'EOF'
#!/bin/sh
/usr/bin/systemctl is-active --quiet haproxy
EOF

chmod 755 /usr/local/bin/chk_haproxy.sh
chown root:root /usr/local/bin/chk_haproxy.sh
```

## Cài đặt keepalive
```
apt update
apt install -y keepalived

node1 :

nano /etc/keepalived/keepalived.conf
global_defs {
  router_id RGW_LB_1

  # Bật script security để hết cảnh báo SECURITY VIOLATION khi chạy script
  enable_script_security
  script_user root
}

vrrp_script chk_haproxy {
  script "/usr/local/bin/chk_haproxy.sh"
  interval 2
  fall 2
  rise 2
  weight -60
}

vrrp_instance VI_RGW_240 {
  state BACKUP
  interface ens192
  virtual_router_id 51
  priority 110
  advert_int 1

  # UNICAST VRRP (tránh multicast bị chặn)
  unicast_src_ip 10.10.240.165
  unicast_peer {
    10.10.240.166
  }

  virtual_ipaddress {
    10.10.240.168/24 dev ens192
  }

  track_script {
    chk_haproxy
  }

  # GARP để cập nhật ARP nhanh khi failover
  garp_master_refresh 60
  garp_master_refresh_repeat 2
}


node 2 :

nano /etc/keepalived/keepalived.conf
global_defs {
  router_id RGW_LB_2
  enable_script_security
  script_user root
}

vrrp_script chk_haproxy {
  script "/usr/local/bin/chk_haproxy.sh"
  interval 2
  fall 2
  rise 2
  weight -60
}

vrrp_instance VI_RGW_240 {
  state BACKUP
  interface ens192
  virtual_router_id 51
  priority 100
  advert_int 1

  unicast_src_ip 10.10.240.166
  unicast_peer {
    10.10.240.165
  }

  virtual_ipaddress {
    10.10.240.168/24 dev ens192
  }

  track_script {
    chk_haproxy
  }

  garp_master_refresh 60
  garp_master_refresh_repeat 2
}

systemctl enable --now keepalived
ip a | grep 10.10.240.168
```

## Cài đặt HAproxy
```
apt update
apt install -y haproxy

node 1 :

cat >/etc/sysctl.d/99-haproxy-vip.conf <<'EOF'
net.ipv4.ip_nonlocal_bind=1
EOF

sysctl --system
sysctl net.ipv4.ip_nonlocal_bind

nano /etc/haproxy/haproxy.cfg

global
  log /dev/log local0
  log /dev/log local1 notice
  daemon
  maxconn 50000

defaults
  log global
  mode http
  option httplog
  option dontlognull
  timeout connect 5s
  timeout client  60s
  timeout server  60s

frontend rgw_s3_8080
  bind 10.10.240.168:8080
  default_backend rgw_nodes

backend rgw_nodes
  balance roundrobin

  option httpchk GET /
  http-check expect rstatus (2|3|4)[0-9][0-9]

  server rgw1 10.10.210.18:8080 check inter 2s fall 3 rise 2
  server rgw2 10.10.210.19:8080 check inter 2s fall 3 rise 2
  server rgw3 10.10.210.20:8080 check inter 2s fall 3 rise 2

node2 : 

cat >/etc/sysctl.d/99-haproxy-vip.conf <<'EOF'
net.ipv4.ip_nonlocal_bind=1
EOF

sysctl --system
sysctl net.ipv4.ip_nonlocal_bind

nano /etc/haproxy/haproxy.cfg

global
  log /dev/log local0
  log /dev/log local1 notice
  daemon
  maxconn 50000

defaults
  log global
  mode http
  option httplog
  option dontlognull
  timeout connect 5s
  timeout client  60s
  timeout server  60s

frontend rgw_s3_8080
  bind 10.10.240.168:8080
  default_backend rgw_nodes

backend rgw_nodes
  balance roundrobin

  option httpchk GET /
  http-check expect rstatus (2|3|4)[0-9][0-9]

  server rgw1 10.10.210.18:8080 check inter 2s fall 3 rise 2
  server rgw2 10.10.210.19:8080 check inter 2s fall 3 rise 2
  server rgw3 10.10.210.20:8080 check inter 2s fall 3 rise 2

systemctl enable --now haproxy
ss -lntp | grep 8080
curl -I http://10.10.240.168:8080/
```

## Ceph endpoint
```
radosgw-admin zonegroup get --rgw-realm s3 --rgw-zonegroup default | grep -i endpoints -n
radosgw-admin zone get --rgw-realm s3 --rgw-zonegroup default --rgw-zone htv | grep -i endpoints -n

radosgw-admin zonegroup modify \
  --rgw-realm s3 --rgw-zonegroup default \
  --endpoints=http://10.10.240.168:8080

radosgw-admin zone modify \
  --rgw-realm s3 --rgw-zonegroup default --rgw-zone htv \
  --endpoints=http://10.10.240.168:8080

radosgw-admin period update --rgw-realm s3 --commit
```