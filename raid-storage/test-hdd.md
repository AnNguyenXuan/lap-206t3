## Test hiệu năng cụm RAID HDD
```
- Read ngẫu nhiên, test nhiều ứng dụng
fio --name=randread_4k --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=100G --rw=randread --bs=4k --time_based --runtime=180 --ramp_time=0 --randrepeat=0 --norandommap --group_reporting

- Write ngẫu nhiên, test nhiều ứng dụng
fio --name=randwrite_4k --filename=/dev/sdb --ioengine=libaio --direct=1 --invalidate=1 --iodepth=64 --numjobs=4 --size=100G --rw=randwrite --bs=4k --time_based --runtime=180 --ramp_time=0 --randrepeat=0 --norandommap --group_reporting

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


## Thông số RAID 0
```
Strip size ảnh hưởng khá mạnh đến kết quả đầu ra, với Strip size lớn, các bài test có kích thước file lớn cho kết quả tốt hơn,

Thông số Strip size = 64k
Băng thông max (bs=1M):
random_read khoảng 250-300 MB
random_write khoảng 300 MB
sqential_read khoảng 400-500 MB
sqential_write khoảng 500-600 MB
random_rw khoảng khoảng 150-250 MB (tổng cả 2)

IOPS max (Bs=16k):
random_read khoảng 3000 IOPS với kích thước nhỏ
random_write khoảng 3000 IOPS với kích thước nhỏ
sqential_read khoảng 20k IOPS với kích thước 16k
sqential_write khoảng 8k IOPS với kích thước 16k
random_rw khoảng khoảng 2000-2500 IOPS với kích thước nhỏ (tổng cả 2)
```

## Đánh giá RAID 10
```
Strip size ảnh hưởng khá mạnh đến kết quả đầu ra, với Strip size lớn, các bài test có kích thước file lớn cho kết quả tốt hơn 

Thông số Strip size = 128k, bs=1M
Băng thông max (bs=1M):
random_read khoảng 350-400 MB
random_write khoảng 200 MB
sqential_read khoảng 500-600 MB
sqential_write khoảng 250-350 MB
random_rw khoảng khoảng 250-300 MB (tổng cả 2)

IOPS max (Bs=16k):
random_read khoảng 2600 IOPS với kích thước nhỏ
random_write khoảng 1100 IOPS với kích thước nhỏ
sqential_read khoảng 20k IOPS với kích thước 16k
sqential_write khoảng 20k IOPS với kích thước 16k
random_rw khoảng giao động, tuy nhiên với write nhiều thì IOPS thấp hơn read nhiều (tổng cả 2)
```

## Đánh giá RAID 5
```
Strip size ảnh hưởng khá mạnh đến kết quả đầu ra, với Strip size lớn, các bài test có kích thước file lớn cho kết quả tốt hơn 

Thông số Strip size = 128k
Băng thông max (bs=1M):
random_read khoảng 280-320 MB
random_write khoảng 70-90 MB
sqential_read khoảng 650-950 MB
sqential_write khoảng 400 MB
random_rw khoảng khoảng 200 MB (tổng cả 2)

IOPS max (Bs=16k):
random_read khoảng 2500 IOPS với kích thước nhỏ
random_write khoảng 500 IOPS với kích thước nhỏ
sqential_read khoảng 15k IOPS với kích thước 16k
sqential_write khoảng 19k IOPS với kích thước 16k (?)
random_rw khoảng giao động, tuy nhiên với write nhiều thì IOPS thấp hơn read nhiều (tổng cả 2) do phải tính parity
kết quả random_rw giao động 600-1000 với tỉ lệ 30-70 và 70-30
```


## Đánh giá chung về HDD
```
Với HDD, song song hiệu quả nhất đến từ:

Nhiều ổ (spindles) trong RAID

Nhiều luồng I/O (queue depth) để các ổ luôn bận

Phân mảnh làm tăng seek -> mỗi ổ bận di chuyển đầu đọc nhiều hơn -> hiệu quả pipeline kém đi, nên bạn cảm giác mất song song. Nhưng bản chất vẫn là: RAID vẫn stripe, vẫn nhiều ổ cùng làm chỉ là mỗi ổ phải nhảy nhiều hơn nên tổng throughput giảm.
```