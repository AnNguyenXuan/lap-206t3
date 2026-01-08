## Cấu hình ban đầu
```
Cấu hình rule cho cụm, quy định dữ liệu sẽ đi vào đâu
ceph replicate_rule

Đọc từ bản replicate, không khuyến nghị chỉnh
read_from_replica

Bỏ auto scale
ceph config set global osd_pool_default_pg_autoscale_mode on

Bỏ cân bằng tải cụm
ceph balancer off

Set default pool size
ceph config set global osd_pool_default_size 2
ceph config set global osd_pool_default_min_size 1

Set min osd ratio
ceph config set global mon_osd_min_in_ratio 0.5

Disable memory autotune (không nên loại bỏ, chỉ dùng trong benmark)
ceph config set osd osd_memory_target_autotune false

Cấu hình pg
pg = OSD x target PG per OSD / replicate (thường lấy lũy thừa của 2 hoặc làm tròn)
```

## Tham số

### OSD Settings

1. General Settings
```
osd_max_write_size : Giới hạn kích thước tối đa của một lần write (tính theo MB/size) mà OSD chấp nhận
osd_max_object_size : Giới hạn kích thước tối đa của một RADOS object
osd_client_message_size_cap : Giới hạn kích thước message dữ liệu lớn nhất của client mà OSD cho phép giữ trong bộ nhớ.
```

2. Scrubbing 
```
osd_max_scrubs : Số scrub đồng thời tối đa trên 1 OSD. Cluster nhỏ/bận thì hạ xuống để giảm latency; cluster lớn/rảnh thì giữ default hoặc tăng nhẹ để catch up
osd_scrub_begin_hour : Giới hạn scrub theo khung giờ. Dùng khi bạn muốn scrub chạy ban đêm/low-traffic
osd_scrub_end_hour : Giới hạn scrub theo khung giờ. Dùng khi bạn muốn scrub chạy ban đêm/low-traffic
osd_scrub_begin_week_day : Giới hạn scrub theo ngày trong tuần. Dùng khi bạn muốn scrub dồn vào cuối tuần
osd_scrub_end_week_day : Giới hạn scrub theo ngày trong tuần. Dùng khi bạn muốn scrub dồn vào cuối tuần
osd_scrub_during_recovery : Cho phép scrub trong lúc đang recovery (mặc định false để giảm tải)
osd_scrub_load_threshold : Nếu load cao hơn ngưỡng thì Ceph không scrub. Cluster lúc nào cũng bận thì cân nhắc tăng nhẹ ngưỡng để scrub chạy (đổi lại latency tăng). Cluster nhạy latency giảm ngưỡng để scrub ít chạy đi.
osd_scrub_min_interval : Khoảng thời gian mong muốn giữa các lần scrub một PG khi tải thấp
osd_scrub_max_interval : Hạn cuối dù tải cao vẫn phải scrub khi quá thời gian này
osd_scrub_chunk_min : min/max số object deep-scrub mỗi chunk; chunk lớn nhanh hơn nhưng có thể tăng latency client
osd_shallow_scrub_chunk_min : tương tự nhưng cho shallow scrub
osd_scrub_chunk_max : min/max số object deep-scrub mỗi chunk; chunk lớn nhanh hơn nhưng có thể tăng latency client
osd_shallow_scrub_chunk_max : tương tự nhưng cho shallow scrub
osd_scrub_sleep : nghỉ giữa các chunk để giảm impact lên client, tham số này bị bỏ qua nếu bạn dùng mClock scheduler
osd_deep_scrub_interval : 
osd_scrub_interval_randomize_ratio : thêm độ trễ ngẫu nhiên vào lịch scrub để tránh tất cả PG scrub cùng lúc
osd_deep_scrub_stride : kích thước đọc khi deep scrub
osd_scrub_auto_repair : tự động repair PG nếu scrub/deep-scrub thấy lỗi, nhưng sẽ không repair nếu lỗi vượt quá ngưỡng (mặc định false)
osd_scrub_auto_repair_num_errors : số object hỏng tối đa để vẫn auto repair
```

3. Operations
```
osd_op_num_shards
osd_op_num_shards_hdd
osd_op_num_shards_ssd
osd_op_num_threads_per_shard
osd_op_num_threads_per_shard_hdd
osd_op_num_threads_per_shard_ssd
osd_op_queue
osd_op_queue_cut_off
osd_client_op_priority
osd_recovery_op_priority
osd_scrub_priority
osd_requested_scrub_priority
osd_snap_trim_priority
osd_snap_trim_sleep
osd_snap_trim_sleep_hdd
osd_snap_trim_sleep_ssd
osd_snap_trim_sleep_hybrid
osd_op_thread_timeout
osd_op_complaint_time
osd_op_history_size
osd_op_history_duration
osd_op_log_threshold
osd_op_thread_suicide_timeout
```

### BlueStore settings

1. Automatic Cache Sizing
```
bluestore_cache_autotune : Bật/tắt việc tự động tune tỉ lệ dung lượng cho các cache của BlueStore (metadata cache, kv/rocksdb cache, …)
osd_memory_target : Ngân sách memory mapped mà OSD cố gắng giữ quanh mức này khi autotune bật. Lưu ý: nó không nhất thiết trùng RSS; có thể RSS vẫn cao hơn (có trường hợp ghi nhận RSS > mapped tới ~20% tuỳ kernel). Giảm nếu node hay OOM/swap (nhiều OSD / RAM ít / chạy kèm OpenStack service). Tăng nếu node dư RAM và bạn muốn cache lớn hơn để tăng hit-rate (đọc nhiều / metadata nặng).
bluestore_cache_autotune_interval : Chu kỳ (giây) để BlueStore nhìn lại mức dùng RAM và tính lại tỉ lệ cache. Muốn hệ ổn định hơn, ít điều chỉnh có thể tăng nhẹ.  
osd_memory_base : Phần RAM nền dành cho OSD nhưng không dành cho cache (coi như overhead cố định). Autotune sẽ coi phần này là không được xài cho cache.
osd_memory_expected_fragmentation : Tỉ lệ % dự phòng cho phân mảnh heap / hiệu ứng allocator. Autotune sẽ trừ trước phần này khỏi ngân sách để tránh ảo tưởng còn RAM.
osd_memory_cache_min : Ngưỡng tối thiểu cho tổng cache (autotune không cho cache co xuống thấp hơn mức này). 
osd_memory_cache_resize_interval : Chu kỳ (giây) để cơ chế autotune thực sự áp thay đổi kích thước cache (khác với interval tính toán). 

Như vậy ta có thể tính chi phí thực cho cache như sau : osd_memory_target - osd_memory_base - osd_memory_target*osd_memory_expected_fragmentation > osd_memory_cache_min
```

2. Inline Compression
```
bluestore_compression_algorithm : thuật toán nén bao gồm snappy(nhanh, nhẹ), zlib (nén tốt nhưng tốn CPU), zstd (nén mạnh, CPU overhead cao), lz4 (giống snappy)
bluestore_compression_mode : lựa chọn khi nào nén none (không) passive (khi có yêu cầu) aggressive (mặc định nén, hoặc có thể không nếu client yêu cầu) force (luôn nén kể cả client yêu cầu)
bluestore_compression_required_ratio : lựa chọn điều kiện nén là dữ liệu phải giảm xuống còn bao nhiêu % trước khi nén
bluestore_compression_min_blob_size : kích thước nhỏ hơn thì không nén (giảm tải CPU)
bluestore_compression_min_blob_size_hdd : theo chuẩn HDD
bluestore_compression_min_blob_size_ssd : theo chuẩn SSD
bluestore_compression_max_blob_size : Blob lớn hơn mức này sẽ bị chẻ nhỏ thành các blob con (mỗi blob con tối đa = max) rồi mới nén. Mục đích: nén theo kích thước vừa phải để ổn định CPU/latency và giảm rủi ro worst-case
bluestore_compression_max_blob_size_hdd : theo chuẩn HDD
bluestore_compression_max_blob_size_ssd : theo chuẩn SSD
```

3. Throttling
```
bluestore_throttle_bytes : tổng chi phí I/O đang được BlueStore submit xuống backend (kernel/aio/spdk) mà chưa hoàn tất. Khi vượt ngưỡng, BlueStore sẽ throttle, tạm không submit thêm I/O mới, bắt request chờ.
bluestore_throttle_deferred_bytes : BlueStore có những ghi deferred (ghi bị trì hoãn / gom lại / chờ commit) trước khi thực sự flush xuống disk. Ý nghĩa: tổng bytes của deferred writes đang treo. Khi vượt ngưỡng: throttle để không tiếp tục nhận/submit thêm, tránh deferred backlog phình ra.
bluestore_throttle_cost_per_io : BlueStore không chỉ throttle theo bytes thật sự của payload, mà còn có thể cộng thêm một khoản overhead giả lập cho mỗi IO để phản ánh chi phí xử lý (metadata, journal, CPU, sync, seek…). Ý nghĩa: mỗi I/O (transaction) được tính thêm X bytes vào tổng cost đang in-flight. Tác dụng: nếu workload là nhiều IO nhỏ (4K, 8K), chỉ throttle theo bytes sẽ không thấy gì (vì bytes ít) nhưng thực tế disk/CPU lại quá tải. Thêm cost/IO giúp throttle đúng bản chất.
bluestore_throttle_cost_per_io_hdd : cost tính theo HDD
bluestore_throttle_cost_per_io_ssd : cost tính theo SSD

Chi phí có thể tính : in_flight_cost = sum(bytes_of_io) + (num_io * cost_per_io)
```

