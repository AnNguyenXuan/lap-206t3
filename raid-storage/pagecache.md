## Ảnh hưởng của page cache đến bài toán đọc ghi
```
Trong hệ thống RAID HDD, page cache của hệ điều hành có ảnh hưởng rất lớn đến kết quả đo hiệu năng, đặc biệt với các bài toán đọc ghi ngẫu nhiên và workload hỗn hợp (mixed read/write).

Về bản chất, page cache hoạt động như một lớp đệm bộ nhớ trung gian giữa ứng dụng và block device. Khi sử dụng buffered I/O (direct=0), các thao tác ghi thường được hoàn thành ngay khi dữ liệu được ghi vào page cache, trong khi việc ghi xuống disk vật lý được thực hiện bất đồng bộ ở phía sau. Điều này có thể tạo ra cảm giác hiệu năng ghi rất cao, dù backend HDD thực tế vẫn có giới hạn lớn về độ trễ và IOPS.

Đối với các bài toán đọc, page cache chỉ mang lại lợi ích khi workload có tính tái sử dụng dữ liệu (locality). Trong các bài test có working set nhỏ hoặc pattern truy cập lặp lại, dữ liệu có thể được phục vụ trực tiếp từ RAM, dẫn đến băng thông đọc ảo, vượt xa khả năng thực của RAID HDD. Ngược lại, với workload có phạm vi truy cập lớn và truy cập ngẫu nhiên rộng, page cache nhanh chóng bị thay thế (cache thrashing), tỷ lệ cache hit thấp, và hiệu năng đo được tiến gần hơn đến giới hạn vật lý của disk.

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