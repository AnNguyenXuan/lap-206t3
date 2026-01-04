## Tham số
```
ceph replicate_rule
read_from_replica

Bỏ auto scale
ceph config set global osd_pool_default_pg_autoscale_mode off

Bỏ cân bằng tải cụm
ceph balancer off

Set default pool size
ceph config set global osd_pool_default_size 2
ceph config set global osd_pool_default_min_size 1

Set min osd ratio
ceph config set global mon_osd_min_in_ratio 0.5

Disable memory autotune
ceph config set osd osd_memory_target_autotune false


1. General Settings
osd_max_write_size : Giới hạn kích thước tối đa của một lần write (tính theo MB/size) mà OSD chấp nhận
osd_max_object_size : Giới hạn kích thước tối đa của một RADOS object
osd_client_message_size_cap : Giới hạn kích thước message dữ liệu lớn nhất của client mà OSD cho phép giữ trong bộ nhớ.

2. Scrubbing 
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

3. Operations
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
