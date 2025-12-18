## Test hiệu năng ssd
```
1.Test block_size
- Read ngẫu nhiên, test nhiều ứng dụng
Với block_size khác nhau, hiệu năng giảm
Block_size càng nhỏ, IOPS càng cao

- Read ngẫu nhiên, test một ứng dụng

- Write ngẫu nhiên, test nhiều ứng dụng
Giống với read ngẫu nhiên
- Write ngẫu nhiên, test một ứng dụng
Block_size nhỏ, IOPS càng cao, tuy nhiên tốc độ write mỗi giây thấp
Block_size lớn, IOPS càng thấp, tuy nhiên tốc độ write đến 1 ngưỡng sẽ bị dừng (có thể do giới hạn vật lý) SATA = 600 MB/s

Có một quy luật IOPS giảm = block_size_lớn/block_size_bé*2

2. Test iodepth
- Read ngẫu nhiên, test nhiều ứng dụng

- Read ngẫu nhiên, test một ứng dụng

- Write ngẫu nhiên, test nhiều ứng dụng

- Write ngẫu nhiên, test một ứng dụng
iodepth tăng, IOPS tăng đến 1 ngưỡng rồi dừng, tốc độ write giữ nguyên, latency giảm
```