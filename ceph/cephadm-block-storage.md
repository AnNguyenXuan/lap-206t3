### Các khái niệm về Block Storage Ceph
```
1. RBD (RADOS Block Device) là gì?
- RBD là lớp “block storage” của Ceph: mỗi image (ổ đĩa ảo) được chia thành các object và lưu trong pool.
- VM/host truy cập image qua librbd (client-side), còn dữ liệu thực nằm trên cụm OSD.

2. Pool, PG (Placement Group) và vì sao nó quan trọng
- Pool: kho logic chứa object. Mỗi RBD image nằm trong một pool.
- PG: đơn vị gom object để Ceph phân phối dữ liệu ra OSD theo CRUSH.
- Lưu ý cấu hình PG:
  - Mỗi pool nên đặt pg_num theo lũy thừa của 2 để tránh phân phối lệch.
  - Nên dùng PG autoscaler để Ceph tự đề xuất/điều chỉnh pg_num theo mức sử dụng (warn/on/off).
  - Có thể đặt ngưỡng min/max cho PG của pool để tránh pool nhỏ bị phình PG.

3. CRUSH và CRUSH rule (quy tắc rải dữ liệu)
- CRUSH là cơ chế tính toán nơi đặt dữ liệu/replica, giúp client nói chuyện trực tiếp với OSD, tránh điểm nghẽn trung tâm.
- CRUSH rule quyết định cách rải PG/replica của một pool; bạn có thể tạo rule riêng nếu mặc định không hợp use-case (theo class SSD/HDD, theo rack/host…).
- Điểm cần chú ý:
  - failure domain (host/rack/…) nằm ở CRUSH rule/hierarchy: quyết định replica sẽ tách nhau theo cấp nào (host hay rack).

4. Replication vs Erasure Coding (EC) cho pool RBD
- Replication: cấu hình đơn giản, phù hợp I/O ngẫu nhiên (VM, DB), đổi lại tốn dung lượng.
- EC: tiết kiệm dung lượng, nhưng thường hợp “bulk/throughput” hơn; nếu dùng cho RBD thường cần thiết kế profile/rule kỹ.
- Lưu ý: CRUSH rule chi phối cả replica (replicated) lẫn shard/chunk (EC).

5. BlueStore (OSD backend) và layout thiết bị
- BlueStore ghi trực tiếp raw lên block device (không mount filesystem truyền thống); thiết bị có thể là disk/partition/LVM LV.
- BlueStore có thể dùng 1/2/3 thiết bị:
  - block: data chính
  - block.db: metadata (RocksDB) – nên đặt trên SSD/NVMe nếu data ở HDD
  - block.wal: write-ahead log – chỉ đáng tách riêng nếu nhanh hơn block (vd SSD/NVMe nhanh hơn HDD)
- Nếu block.db đầy, metadata sẽ spill về block (thường làm hiệu năng tụt), nên cần sizing/giám sát dung lượng db.
- Metadata BlueStore lưu dạng key-value trong RocksDB; RocksDB nằm trên BlueFS (filesystem tối giản cho RocksDB).

6. RBD image format & image features (rất quan trọng khi vận hành)
Các feature phổ biến (và phụ thuộc):
- layering: hỗ trợ snapshot/clone theo kiểu copy-on-write
- striping: striping v2
- exclusive-lock: khóa độc quyền để tránh nhiều tiến trình ghi lung tung (đặc biệt dùng nhiều trong ảo hóa)
- object-map: yêu cầu exclusive-lock
- fast-diff: yêu cầu object-map; tăng tốc diff giữa snapshot
- journaling: yêu cầu exclusive-lock
- deep-flatten: hỗ trợ flatten clone/snapshot (lưu ý có hệ thống chỉ cho bật lúc tạo image)
- data-pool: hỗ trợ mô hình data pool (thường dùng khi kết hợp EC)

Gợi ý vận hành:
- Với workload VM/ảo hóa: hầu như nên có exclusive-lock + object-map + fast-diff để tối ưu snapshot/diff và tránh ghi đè nhau.

7. Network trong Ceph (chỉ xét cấu hình Ceph)
- public network: bắt buộc (client/daemon giao tiếp).
- cluster network (private): nếu cấu hình sẽ tách traffic nội bộ OSD (recovery/replication/backfill) khỏi public; nhiều triển khai lớn được khuyến nghị dùng 2 network.
- msgr2: protocol on-wire v2; có chế độ secure mode mã hóa dữ liệu trên đường truyền.

8. Scrub / Deep-scrub (toàn vẹn dữ liệu) và lịch chạy
- Ceph scrub giống fsck ở tầng object; light scrub thường theo ngày và deep scrub thường theo tuần.
- Nên giới hạn khung giờ scrub để tránh đè I/O giờ cao điểm:
  - osd_scrub_begin_hour / osd_scrub_end_hour (và theo tuần)
- Tránh tắt deep scrub trong vận hành chuẩn, thay vào đó điều chỉnh lịch/độ ưu tiên nếu ảnh hưởng hiệu năng.

9. Recovery / Backfill (phục hồi & tái cân bằng)
- Khi thêm/bớt OSD, CRUSH sẽ rebalance; quá trình di chuyển PG/object có thể làm giảm hiệu năng, nên Ceph dùng backfilling để ưu tiên I/O client hơn.
- Điểm cần chú ý: các tham số recovery/backfill là dao hai lưỡi (đẩy nhanh thì cluster dễ nghẹt), nên chỉnh theo mức chịu tải và theo khung thời gian bảo trì.

10. RBD client cache (nằm trong Ceph config cho client)
- Cache của librbd có thể cấu hình trong [client] (ảnh hưởng I/O đọc/ghi từ phía client):
  - rbd_cache, rbd_cache_size, rbd_cache_max_dirty…
- Lưu ý: bật write-back cache giảm latency nhưng tăng yêu cầu kiểm soát rủi ro (crash/powerloss ở phía client).
```

### Cài đặt Block Storage Ceph
```
Thiết lập số replicate per osd
ceph config set global osd_pool_default_size 2
ceph config set global osd_pool_default_min_size 1

Tạo pool cho OPS
ceph osd pool create volumes 64 64
ceph osd pool create images 32 32
ceph osd pool create backups 32 32
ceph osd pool create vms 32 32
ceph osd pool set volumes target_size_ratio 0.55
ceph osd pool set images target_size_ratio 0.30
ceph osd pool set backups target_size_ratio 0.10
ceph osd pool set vms target_size_ratio 0.05
rbd pool init volumes
rbd pool init images
rbd pool init backups
rbd pool init vms

Set config theo KiB (hệ nhị phân, 1KiB = 1028B)
ceph config set client.glance rbd_default_stripe_unit 65536
ceph config set client.glance rbd_default_stripe_count 16
```

### Test rbd
```
Lấy thông tin
ceph config get client.glance rbd_default_stripe_unit
ceph config get client.glance rbd_default_stripe_count

rbd -p images create teststripe --size 1024 \
  --object-size 8M --stripe-unit 64K --stripe-count 16

rbd -p images info teststripe
```


