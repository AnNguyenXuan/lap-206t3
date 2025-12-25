## Test hiệu năng ssd
```
- Read ngẫu nhiên, test nhiều ứng dụng
fio --name=randread_4k --filename=/dev/sdd --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randread --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting
Với block_size khác nhau, hiệu năng giảm
Block_size càng nhỏ, IOPS càng cao

- Read ngẫu nhiên, test một ứng dụng
fio --name=randread_4k_single --filename=/dev/sdd --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=1 --size=4G --rw=randread --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting

- Write ngẫu nhiên, test nhiều ứng dụng
fio --name=randwrite_4k --filename=/dev/sdd --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randwrite --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting
Giống với read ngẫu nhiên

- Write ngẫu nhiên, test một ứng dụng
fio --name=randwrite_4k_single --filename=/dev/sdd --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=1 --size=4G --rw=randwrite --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting

- Read write mix
fio --name=mixed_rw_70r30w --filename=/dev/sdd --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=8G --rw=randrw --rwmixread=70 --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting
```

### Đánh giá
```
Kết quả kiểm tra cho thấy block size có ảnh hưởng trực tiếp đến mối quan hệ giữa IOPS và băng thông. Khi block size nhỏ, SSD đạt IOPS cao nhưng tốc độ ghi theo MB/s thấp do mỗi IO mang ít dữ liệu; hiệu năng ghi trong trường hợp này bị giới hạn bởi ngưỡng IOPS vật lý của thiết bị. Khi block size tăng, IOPS giảm trong khi băng thông tăng và nhanh chóng bão hòa ở giới hạn vật lý của SSD; với SATA SSD, băng thông thực tế thường đạt khoảng 500–560 MB/s.

Việc tăng iodepth và numjobs giúp tăng mức độ song song, làm IOPS tăng đến một ngưỡng bão hòa nhất định. Sau ngưỡng này, throughput gần như không tăng thêm, trong khi latency tăng do hiện tượng xếp hàng I/O. Mỗi SSD có một iodepth tối ưu; vượt quá ngưỡng này không cải thiện hiệu năng mà chỉ làm tăng độ trễ.

Trong điều kiện bị giới hạn bởi băng thông, IOPS có quan hệ tỷ lệ nghịch với block size theo công thức xấp xỉ IOPS ≈ Bandwidth / Block size. Do đó, việc tăng block size dẫn đến IOPS giảm là đặc điểm mang tính quy luật của hệ thống.

SSD cho hiệu năng tốt hơn trong các workload đọc nhiều so với các workload ghi nhiều. Khi tỷ lệ ghi tăng, IOPS giảm và latency tăng rõ rệt, đặc biệt trong các bài toán mixed read/write hoặc write-heavy. Hiệu năng ghi ban đầu có thể cao nhờ cơ chế SLC cache, nhưng khi chuyển sang trạng thái steady-state, tốc độ ghi giảm về mức NAND thực.

Về bản chất, hiệu năng đọc của SSD tốt hơn hiệu năng ghi do cơ chế Flash Translation Layer: thao tác đọc chủ yếu là tra mapping và đọc page, trong khi thao tác ghi yêu cầu ghi out-of-place, cập nhật mapping, đánh dấu page cũ không hợp lệ và có thể kích hoạt write amplification cũng như garbage collection, làm tăng latency và giảm IOPS.

Tổng thể, SSD hoạt động hiệu quả nhất với workload đọc chiếm ưu thế, block size phù hợp và iodepth tối ưu. Việc đánh giá SSD cần xem xét đồng thời IOPS, băng thông, latency (đặc biệt p95/p99) và trạng thái steady-state để phản ánh đúng khả năng vận hành thực tế của thiết bị.
```