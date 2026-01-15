# Các khái niệm về Object Storage Ceph
```
# Khi triển khai Ceph Object Storage có những vấn đề sau
Realm : 
Zonegroup :
Zone :

# Kiến trúc triển khai
Singer-zone :
Multi-zone :
Multi-Zonegroup hay Multi-Realm : 

# Lớp lưu trữ
Ceph Object Storage sử dụng 2 lớp dữ liệu trừu tượng để quyết định việc lưu trữ dữ liệu
- Placement ID : Là cấp bucket, quy định dữ liệu trong bucket đến những pool nào, bucket tạo ra sẽ gán liền với Placement ID và không thể thay đổi
- Storage Class : Là cấp object, quy định object nào sẽ lưu vào pool nào
Có thể hiểu, nếu ta cho phép Placement ID lưu trữ trong 3 pool khác nhau ứng với 3 loại ổ ssd, hdd, nvme, thì việc tạo 3 Storage Class sẽ giúp ta quản lý dễ dàng hơn khi chuyển đổi dữ liệu giữa các loại ổ mà không phải đổi pool hay bucket, do việc tạo bucket sẽ gắn với pool và không thể thay đổi. Quá trình này gọi là Lifecycle Transition, chuyển đổi dữ liệu từ pool này sang pool khác mà giữ nguyên bucket và key
```

# Ứng dụng 
```
Dùng ngắn gọn: Ceph Object Storage (RGW) là kho S3/Swift-compatible, rẻ – bền – mở rộng tuyến tính. Những ứng dụng điển hình:

1. Backup/Archive & DR

Cinder-backup: dùng S3 driver (trỏ về RGW) hoặc Ceph RBD driver (backup block-level). RGW = phù hợp offsite/DR, RBD = nội bộ nhanh.

VM/Container backup: Veeam, Velero (K8s), Restic, Borg, Kopia… đẩy thẳng lên S3 của RGW.

DB backup: MySQL/Mongo/Postgres làm PITR/streaming tới S3 (wal-g, pgBackRest…).

Lưu trữ dài hạn: bật Lifecycle để auto chuyển STANDARD → COLD (pool rẻ), Versioning, Object Lock (WORM) để đáp ứng tuân thủ.

2. Lưu trữ tệp ứng dụng (App object store)

Nextcloud/OwnCloud: đặt primary/external storage là S3 (RGW).

GitLab/CI artifacts, LFS, Jenkins artifacts.

Container Registry: Harbor/Quay sử dụng S3 backend.

OpenShift/K8s: logs/artifacts, backup, model blobs.

3. Phân phối nội dung & website

Origin cho CDN (ảnh/video/static). RGW có thể bật Website hosting cho static site nhỏ.

Media pipelines: upload đa phần, multipart upload cho file lớn.

4. Dữ liệu phân tích, AI/ML

Data lake: truy cập qua S3A/S3 (Hadoop, Spark, Trino/Presto, Hive).

AI/ML datasets & model store: lưu checkpoint/model/embeddings; dịch vụ đọc qua SDK S3.

5. OpenStack tích hợp “chuẩn bài”

Thay Swift: RGW cung cấp Swift API + Keystone auth → Glance/Cinder-backup có thể dùng như Swift.

Glance images: có thể đặt ở RGW (ít dùng hơn RBD nhưng vẫn được khi cần tách rời).

Multi-site RGW (realm/zonegroup/zone) → replication liên vùng cho DR.

6. Log/metrics quy mô lớn

Thanos/Cortex/Mimir: object storage để lưu blocks của Prometheus.

Grafana Loki (boltdb-shipper) lưu chunks/index lên S3.

Tính năng làm nên khác biệt

Erasure Coding + replication: bền vững, tối ưu chi phí.

Lifecycle & Storage Class → map sang placement target/pool (ví dụ STANDARD vs COLD).

Bucket policy/ACL, Server-Side Encryption, Versioning, Object Lock (WORM).

Multi-site (bi-directional/one-way) cho HA/DR.

Khi nào KHÔNG nên dùng RGW

Khối lượng I/O nhỏ, cực nhiều file rất nhỏ và yêu cầu latency thấp → cân nhắc CephFS/RBD.

Cần POSIX semantics đầy đủ → dùng CephFS.
```

# Cài đặt
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
# Deploy rgw
```
ceph orch apply rgw s3.htv \
  --realm=s3 --zone=htv \
  --port 8080 \
  --placement="3 openstack-mon-1 openstack-data-1 openstack-data-2"

ceph orch ps --daemon_type rgw
```

# Tạo placement theo pool
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

# Xử lý vấn đề liên quan đến hàng đợi
```
Hàng đợi GC (garbage collection) của Ceph RGW

Khi ta xóa hoặc ghi đè (overwrite) một object S3, RGW không xóa ngay toàn bộ dữ liệu thô trong RADOS (các “data chunk”/“shard” phía dưới).

Thay vào đó RGW đưa công việc xóa dữ liệu thô vào một hàng đợi (GC queue) lưu trong pool log của zone (ví dụ htv.rgw.log).

Một worker nền trong RGW sẽ xử lý hàng đợi này định kỳ để xóa thật các data chunk → khi đó dung lượng pool mới giảm.

Vì vậy: ta thấy file biến mất ngay khi xóa, dung lượng bucket giảm, nhưng Usage của pool chỉ giảm sau khi các mục trong GC queue được xử lý xong.

# Xem số lượng hàng đợi
radosgw-admin gc list --include-all | wc -l

# Xem hàng đợi đang xử lý gc nào
radosgw-admin gc list --include-all | head

# Tăng tốc xử lý hàng đợi, không nên quá cao vì sẽ gây tải lớn
radosgw-admin gc process --max-entries=10000
# Xem cấu hình gc của rgw
```
# Các API quản trị
```
Ceph cung cấp cho ta 4 loại API chính theo mức độ tác động vào hệ thống
S3 API, Switf API : lớp người dùng, tương tác với bucket để xử lý các vấn đề lưu trữ, quyền truy cập
IAM API : lớp quản trị người dùng, xử lý các vấn đề user, quyền, khóa
Admin Ops API : lớp quản trị hệ thống, cần có 1 user admin tạo
```
# Vấn đề phân quyền
```
Chúng ta có user và subuser,
```
# Quản lý cụm
```
# Xóa bucket
radosgw-admin bucket rm --bucket=warp-benchmark-bucket --purge-objects

```
