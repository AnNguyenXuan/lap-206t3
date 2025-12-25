## Test hiệu năng cụm RAID 0 HDD
```
- Read ngẫu nhiên, test nhiều ứng dụng
fio --name=randread_4k --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randread --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting

- Write ngẫu nhiên, test nhiều ứng dụng
fio --name=randwrite_4k --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randwrite --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting

- Read tuần tự, test nhiều ứng dụng
fio --name=seqread_4k --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=read --bs=4k --time_based --runtime=180 --ramp_time=20       --randrepeat=0 --norandomma --group_reporting

- Write tuần tự, test nhiều ứng dụng
fio --name=seqwrite_4k --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=write --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandomma --group_reporting

- Read write mix ngẫu nhiên
fio --name=mixed_rw_70r30w --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=32 --numjobs=4 --size=8G --rw=randrw --rwmixread=70 --bs=1M --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting

fio --name=mixed_rw_70r30w --filename=/dev/sdb --ioengine=libaio --direct=0 --invalidate=1 --iodepth=32 --numjobs=4 --size=8G --rw=randrw --rwmixread=70 --bs=1M --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --norandommap --group_reporting

- Read write mix tuần tự
fio --name=seq_mixed_rw_70r30w --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=32 --numjobs=4 --size=8G --rw=rw --rwmixread=70 --bs=1M --time_based --runtime=180 --ramp_time=20 --randrepeat=0 --group_reporting

```

## Đánh giá cụm RAID 0 HDD
```
Hiệu năng của cụm RAID 0 HDD chịu ảnh hưởng bởi cấu hình controller và đặc tính vật lý của ổ cứng. Trong đó, strip size quyết định mức độ phân tán I/O xuống các ổ vật lý, còn cache bypass size ảnh hưởng đến việc I/O đi qua cache hay ghi trực tiếp xuống đĩa, từ đó tác động đến độ trễ và throughput quan sát được trong quá trình đo.

Việc tăng số lượng ổ cứng trong cụm RAID 0 giúp tăng khả năng song song hóa I/O và băng thông tổng, tuy nhiên mức cải thiện sớm đạt ngưỡng do giới hạn cơ học của HDD và controller. RAID 0 không làm tăng IOPS vật lý của từng ổ, mà chủ yếu phân tán tải và tận dụng băng thông tổng của nhiều platter (đĩa).

HDD thể hiện tốt với các thao tác đọc ghi dữ liệu lớn. Trong các bài test tuần tự, throughput đạt mức rất cao do hạn chế seek và tận dụng pipeline I/O. Với các bài test ngẫu nhiên block nhỏ, IOPS giảm mạnh do chi phí seek chi phối; tuy nhiên khi block size tăng, workload dần chuyển sang dạng “random offset nhưng transfer lớn”, giúp bandwidth vẫn duy trì ở mức tốt dù độ trễ tăng.

Trong bài toán mixed read/write, hiệu năng tổng thể thường giảm so với read-only hoặc write-only, nhưng mức suy giảm không quá lớn khi backend đã bị bão hòa băng thông. Khi đó, tỉ lệ đọc/ghi không còn là yếu tố quyết định chính; bottleneck nằm ở khả năng phục vụ I/O của cụm HDD.

Khi cụm RAID 0 HDD đã bão hòa băng thông, việc thay đổi block size không làm thay đổi đáng kể throughput tổng. Sự khác biệt chủ yếu thể hiện ở số lượng I/O và độ trễ: block size lớn làm giảm IOPS logic nhưng tăng latency do fan-out và queueing sâu hơn. Đây là sự đánh đổi giữa latency và throughput, không phải sự cải thiện năng lực vật lý của ổ cứng.

Lớp block layer của hệ điều hành đóng vai trò chuẩn hóa và điều phối I/O. Các yêu cầu I/O lớn ở tầng ứng dụng sẽ được chia nhỏ theo giới hạn của kernel, driver và RAID controller trước khi được striping xuống các ổ vật lý. Vì vậy, block size trong benchmark phản ánh kích thước I/O logic, không phải kích thước I/O vật lý duy nhất tại đĩa.

Kết luận:
RAID 0 HDD tối ưu việc khai thác băng thông tổng của nhiều ổ cứng bằng cách giảm chi phí seek trên mỗi đơn vị dữ liệu, nhưng không làm tăng IOPS vật lý của HDD. Khi backend đã bão hòa, mọi điều chỉnh block size hay queue depth chỉ làm thay đổi cách đánh đổi giữa latency và IOPS logic, chứ không thể vượt qua giới hạn vật lý của hệ thống.
```

## Ảnh hưởng của page cache đến bài toán đọc ghi
```
Trong hệ thống RAID HDD, page cache của hệ điều hành có ảnh hưởng rất lớn đến kết quả đo hiệu năng, đặc biệt với các bài toán đọc ghi ngẫu nhiên và workload hỗn hợp (mixed read/write).

Về bản chất, page cache hoạt động như một lớp đệm bộ nhớ trung gian giữa ứng dụng và block device. Khi sử dụng buffered I/O (direct=0), các thao tác ghi thường được hoàn thành ngay khi dữ liệu được ghi vào page cache, trong khi việc ghi xuống disk vật lý được thực hiện bất đồng bộ ở phía sau. Điều này có thể tạo ra cảm giác hiệu năng ghi rất cao, dù backend HDD thực tế vẫn có giới hạn lớn về độ trễ và IOPS.

Đối với các bài toán đọc, page cache chỉ mang lại lợi ích khi workload có tính tái sử dụng dữ liệu (locality). Trong các bài test có working set nhỏ hoặc pattern truy cập lặp lại, dữ liệu có thể được phục vụ trực tiếp từ RAM, dẫn đến băng thông đọc “ảo”, vượt xa khả năng thực của RAID HDD. Ngược lại, với workload có phạm vi truy cập lớn và truy cập ngẫu nhiên rộng, page cache nhanh chóng bị thay thế (cache thrashing), tỷ lệ cache hit thấp, và hiệu năng đo được tiến gần hơn đến giới hạn vật lý của disk.

Khi RAID HDD bị bão hòa băng thông hoặc IOPS, page cache không làm tăng năng lực xử lý thực tế của hệ thống, mà chỉ che giấu độ trễ trong ngắn hạn. Trong các tình huống ghi nhiều, cơ chế writeback và dirty throttling của kernel có thể gây ra độ trễ lớn và không ổn định, thể hiện qua tail latency cao (p95, p99 tăng mạnh), dù băng thông trung bình vẫn được duy trì.

Kết luận : page cache không làm RAID HDD nhanh hơn, mà chỉ thay đổi thời điểm và cách chi phí I/O được bộc lộ. Trong các phép đo hiệu năng backend lưu trữ, việc bật page cache có thể dẫn đến kết quả sai lệch nếu không kiểm soát chặt chẽ pattern truy cập và kích thước working set.
```


## Bài toán page cache
```
cat /proc/sys/vm/swappiness : quyết định giữ page cache hay đẩy ra swap
vm.swappiness = 1–10 : giữ page cache lâu hơn, tránh swap sớm
sysctl -w vm.swappiness=10

Swappiness xác định mức độ kernel ưu tiên giữ page cache so với bộ nhớ tiến trình; giá trị 60 là mặc định và phù hợp cho hệ thống tổng quát, nhưng với backend HDD và workload nhạy độ trễ, việc giảm swappiness giúp hạn chế swap và tránh spike latency.

/proc/sys/vm/dirty_ratio 20
/proc/sys/vm/dirty_background_ratio 10
/proc/sys/vm/dirty_bytes 0
/proc/sys/vm/dirty_background_bytes 0
Ý nghĩa : kiểm soát bao nhiêu dữ liệu được ghi trong RAM, tránh write burst gây latency spike

Khi ứng dụng ghi (buffered IO): 
Ghi vào page cache → rất nhanh Dirty < 10% → kernel chưa vội flush
Dirty > 10% → background writeback bắt đầu
Dirty > 20% → ứng dụng bị chặn, latency tăng vọt

Disk HDD chậm
→ writeback không kịp
→ xuất hiện stall vài trăm ms đến vài giây

Thiết kế của Linux là cố tình tách 2 pha:
pha gom (accumulate)
dirty pages được gom trong RAM → tạo IO lớn, liên tục
pha xả (flush)
writeback chạy khi đủ dữ liệu → HDD làm việc hiệu quả

Có thể cáu hình sang 10-5, latency sẽ ổn định hơn, BW giảm nhẹ nhưng có thể chấp nhận, flush sớm hơn, vẫn đủ batch để merge

Các tham số dirty_ratio và dirty_background_ratio quyết định lượng dữ liệu được phép tồn tại trong page cache trước khi bị flush xuống disk. Trong hệ thống RAID HDD, giá trị này ảnh hưởng mạnh đến độ ổn định độ trễ: ngưỡng cao giúp tăng tốc độ ghi ngắn hạn nhưng dễ gây writeback congestion và latency spike, trong khi ngưỡng thấp giúp hệ thống ổn định hơn nhưng làm giảm băng thông đỉnh.

cat /sys/block/sdb/queue/read_ahead_kb
Dùng cho scan, backup, sequential read
```