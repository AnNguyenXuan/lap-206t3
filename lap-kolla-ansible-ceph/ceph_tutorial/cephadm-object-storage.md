### Các khái niệm về Object Storage Ceph
```

```

### Cài đặt
```
# Realm mới, đặt mặc định
radosgw-admin realm create --rgw-realm s3 --default

# Zonegroup 'default' làm master + default, trỏ endpoint của bạn
radosgw-admin zonegroup create \
  --rgw-realm s3 --rgw-zonegroup default \
  --master --default \
  --endpoints=http://10.10.210.20:8080

# Zone 'htv' làm master + default
radosgw-admin zone create \
  --rgw-realm s3 --rgw-zonegroup default --rgw-zone htv \
  --master --default \
  --endpoints=http://10.10.210.20:8080

# Publish
radosgw-admin period update --commit
```
### Deploy rgw
```
ceph orch apply rgw s3.htv --port 8080 --placement="1 openstack-mon-1"

ceph orch ps --daemon_type rgw
```

### Tạo placement theo pool
```
# Tạo pool cho placement
ceph osd pool create s3.ssd.data  32
ceph osd pool create s3.ssd.index  8

ceph osd pool application enable s3.ssd.data  rgw
ceph osd pool application enable s3.ssd.index rgw

# zonegroup: thêm target 'ssd' (KHÔNG gắn tags để đỡ rắc rối)
radosgw-admin zonegroup placement add \
  --rgw-realm s3 --rgw-zonegroup default \
  --placement-id ssd \
  --data-pool s3.ssd.data \
  --index-pool s3.ssd.index \
  --storage-class STANDARD

# zone: map pool cho target 'ssd'
radosgw-admin zone placement add \
  --rgw-realm s3 --rgw-zonegroup default --rgw-zone htv \
  --placement-id ssd \
  --data-pool s3.ssd.data \
  --index-pool s3.ssd.index

# publish
radosgw-admin period update --commit
systemctl restart ceph-radosgw@* 
```

# Tạo user và test
```
# user cho ứng dụng
radosgw-admin user create --uid=test --display-name="Test User" \
  --access-key=TESTKEY --secret-key=TESTSECRET

export AWS_ACCESS_KEY_ID=TESTKEY
export AWS_SECRET_ACCESS_KEY=TESTSECRET

# tạo bucket mặc định
aws --endpoint-url=http://10.10.210.20:8080 s3api create-bucket --bucket mybucket

# tạo bucket đi placement 'ssd' (trên RGW: dùng 
LocationConstraint=<api_name>:<placement-id>)
aws --endpoint-url=http://10.10.210.20:8080 s3api create-bucket \
  --bucket mybucket-ssd-1 \
  --create-bucket-configuration LocationConstraint=default:ssd

# kiểm tra
radosgw-admin bucket stats --bucket mybucket-ssd-1 | grep placement_rule
# => "placement_rule": "ssd"

# tạo file test và upload
echo "ok-ssd" > /tmp/t.txt
aws --endpoint-url=http://10.10.210.20:8080 s3 cp /tmp/t.txt s3://mybucket-ssd-1/

# xem object tăng ở pool data
ceph osd pool stats s3.ssd.data
# hoặc liệt kê trực tiếp (sẽ thấy object mới sinh)
rados -p s3.ssd.data ls | head
```
# Tạo thêm ổ để khai báo rule cho các option khách hàng
```
ceph orch daemon add osd openstack-mon-1:/dev/sde
ceph orch daemon add osd openstack-node-2:/dev/sde
ceph orch daemon add osd openstack-node-3:/dev/sde

for id in 9 10 11; do
  ceph osd crush rm-device-class osd.$id
  ceph osd crush set-device-class premium osd.$id
done

ceph osd crush rule create-replicated rgw-premium default host premium

ceph osd pool set s3.ssd.data  crush_rule rgw-premium
ceph osd pool set s3.ssd.index crush_rule rgw-premium

ceph osd df tree
ceph pg ls-by-pool s3.ssd.data | head

oid=$(rados -p s3.ssd.data ls | head -n1)
```
# Tạo bucket nextcloud để đấu nối 
```
# zonegroup
radosgw-admin zonegroup placement add \
  --rgw-realm s3 --rgw-zonegroup default \
  --placement-id nextcloud \
  --data-pool nextcloud.data \
  --index-pool nextcloud.index \
  --storage-class STANDARD

# zone
radosgw-admin zone placement add \
  --rgw-realm s3 --rgw-zonegroup default --rgw-zone htv \
  --placement-id nextcloud \
  --data-pool nextcloud.data \
  --index-pool nextcloud.index

# publish
radosgw-admin period update --commit
systemctl restart ceph-radosgw@*

# user
radosgw-admin user create --uid=nc --display-name="Nextcloud" \
  --access-key=NC_ACCESS --secret-key=NC_SECRET

# bucket
aws --endpoint-url=http://10.10.210.20:8080 s3api create-bucket \
  --bucket nextcloud-data \
  --create-bucket-configuration LocationConstraint=default:nextcloud

# Lệnh này là do đang để config key cũ ở trên, nên ta phải đổi lại
radosgw-admin bucket unlink --bucket=nextcloud-data --uid=test
radosgw-admin bucket link   --bucket=nextcloud-data --uid=nc

Lưu ý các cấu hình dưới đây là dành cho việc thay đổi cấu hình Nextcloud khi đã cài tại node 10.10.240.9
# Xóa database cũ trong nextcloud
drop database nextcloud;

# Tạo lại database
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'ncuser'@'%' IDENTIFIED BY 'Ohm_p2)6T3';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'ncuser'@'%';
FLUSH PRIVILEGES;
EXIT;

# reconfig
systemctl stop apache2
rm -rf /var/www/nextcloud/data/*
rm -f /var/www/nextcloud/config/config.php
chown -R www-data:www-data /var/www/nextcloud

sudo -u www-data php /var/www/nextcloud/occ maintenance:install \
  --database "mysql" --database-host "localhost" \
  --database-name "nextcloud" --database-user "ncuser" --database-pass "Ohm_p2)6T3" \
  --admin-user "admin" --admin-pass "Ohm_p2)6T3"

nano /var/www/nextcloud/config/config.php

<?php
$CONFIG = array (
  'trusted_domains' =>
  array (
    0 => '10.10.240.9',
  ),

  // S3 primary object store -> Ceph RGW
  'objectstore' => array(
    'class' => '\\OC\\Files\\ObjectStore\\S3',
    'arguments' => array(
      'bucket' => 'nextcloud-data',   // bucket bạn đã tạo ở placement 'nextcloud'
      'key'    => 'NC_ACCESS',
      'secret' => 'NC_SECRET',
      'hostname' => '10.10.210.20',
      'port'     => 8080,
      'use_ssl'  => false,
      'region'   => 'us-east-1',      // giá trị bất kỳ, RGW bỏ qua
      'use_path_style' => true,       // BẮT BUỘC với Ceph RGW
      'autocreate' => false,          // bạn đã tạo sẵn bucket
    ),
  ),

  // Khuyến nghị hiệu năng/độ ổn định
  'filelocking.enabled' => true,
  'memcache.local'   => '\\OC\\Memcache\\APCu',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => array('host' => '127.0.0.1', 'port' => 6379),
);


systemctl restart apache2

# Test thử kết nối 
export AWS_ACCESS_KEY_ID=NC_ACCESS
export AWS_SECRET_ACCESS_KEY=NC_SECRET
aws --endpoint-url=http://10.10.210.20:8080 s3 ls s3://nextcloud-data

echo ok >/tmp/t.txt
aws --endpoint-url=http://10.10.210.20:8080 s3 cp /tmp/t.txt s3://nextcloud-data/.healthcheck
aws --endpoint-url=http://10.10.210.20:8080 s3 rm s3://nextcloud-data/.healthcheck
```
