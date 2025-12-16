## Phần mềm test ổ cứng

### 1. Victoria
```
Victoria (thường gọi là Victoria HDD/SSD Utility) là một phần mềm kiểm tra – chẩn đoán – sửa lỗi cấp thấp cho ổ cứng rất nổi tiếng trên Windows.

Các tính năng
1. Kiểm tra tình trạng ổ cứng (HDD/SSD)
Đọc SMART để xem số giờ hoạt động, bad sector, tình trạng sức khỏe.
Xem tốc độ đọc/ghi, độ trễ truy cập từng sector

2. Quét lỗi (Scan)
Quét toàn bộ sector để tìm Bad Sector.
Đánh giá sector theo màu (Xanh – tốt, Cam – chậm, Đỏ – lỗi).
Cho bạn biết vùng nào của ổ đang có vấn đề

3. Remap / Erase / Refresh
Remap: đánh dấu sector lỗi để ổ cứng không dùng lại sector đó.
Erase: xoá sector bị lỗi để ép firmware tự chuyển sang sector dự phòng.
Refresh: ghi lại sector để “làm tươi” vùng có tốc độ kém (thích hợp HDD).
Lưu ý : Với SSD thì tuyệt đối không nên dùng chế độ sửa lỗi bừa bãi vì thao tác ghi xoá lặp lại dễ làm giảm tuổi thọ

4. Test controller / giao tiếp
Giao tiếp SATA.
Chế độ DMA/PIO.
Lỗi truyền tải dữ liệu
```

### 2. Hard Disk Sentinel 
```

```


## Tổng Quan Về IOPS (Input/Output Operations Per Second)
```
IOPS là chỉ số đo lường số lượng thao tác đọc/ghi ngẫu nhiên độc lập mà một thiết bị lưu trữ có thể thực hiện được trong một giây. IOPS cao đồng nghĩa với Độ trễ (Latency) thấp nhưng latency và throughput cũng là các chỉ số quan trọng đi kèm để đánh giá hiệu năng tổng thể của hệ thống lưu trữ. Latency là thời gian phản hồi cho mỗi yêu cầu I/O, còn throughput là lượng dữ liệu truyền tải trên mỗi giây (MB/s). Ba chỉ số này tương tác với nhau để xác định hiệu suất thực tế của workload. Khi latency thấp hơn, thiết bị có thể phục vụ nhiều IOPS hơn, và throughput tổng thể có thể được tính sơ bộ bằng công thức throughput ≈ IOPS × block size của I/O thực tế, do đó một IOPS cao kết hợp với block size lớn sẽ mang lại throughput lớn hơn. Đồng thời IOPS thường được phân loại thành random IOPS và sequential IOPS tùy vào dạng truy cập dữ liệu.
```

### Mối Quan Hệ Vật Lý Quyết Định IOPS
```
Hiệu suất IOPS cơ bản được xác định bởi thiết kế vật lý của thiết bị và kiến trúc hệ thống:

1. **HDD:**
   Yếu tố Vật lý Chính: Cơ chế cơ học.
   Cơ chế Ảnh hưởng: IOPS bị giới hạn bởi Tốc độ Quay (RPM) và Thời gian Tìm kiếm (Seek Time) của đầu đọc vật lý – ổ HDD truyền thống 7200 RPM chỉ đạt vài trăm IOPS do overhead cơ học.

2. **SSD:**
   Yếu tố Vật lý Chính: Bộ nhớ Flash NAND và Controller.
   Cơ chế Ảnh hưởng: SSD loại bỏ giới hạn cơ học, IOPS cao hơn nhờ tốc độ truy cập chip Flash nhanh và controller hỗ trợ nhiều queue I/O song song. Các SSD NVMe có thể đạt hàng trăm nghìn đến hàng triệu IOPS trong điều kiện queue depth cao.

3. **Giao Tiếp:**
   Yếu tố Vật lý Chính: Bus Vật lý (PCIe vs SATA).
   Cơ chế Ảnh hưởng: Giao thức NVMe/PCIe hỗ trợ nhiều hàng đợi I/O song song hơn so với SATA cũ, giúp giảm bottleneck của bus và tăng khả năng xử lý I/O đồng thời.

4. **RAID:**
   Yếu tố Vật lý Chính: Kiến trúc song song đĩa.
   Cơ chế Ảnh hưởng: Tăng IOPS nhờ phân tán tải I/O (striping). Tuy nhiên các cấp RAID như RAID 5/6 gây hình phạt ghi do chi phí tính toán và ghi parity vật lý, làm giảm hiệu năng ghi thực tế và tăng độ trễ.

5. **Nhiệt độ:**
   Yếu tố Vật lý Chính: Quá nhiệt (overheating).
   Cơ chế Ảnh hưởng: Quá nhiệt có thể gây thermal throttling ở controller và NAND, làm giảm tốc độ xử lý và dẫn tới giảm IOPS đột ngột. Thermal throttling ảnh hưởng tới latencies và throughput trong các workload dài.

6. **Controller và cache:**
   Yếu tố Vật lý Chính: Bộ đệm DRAM/SLC cache và thuật toán controller.
   Cơ chế Ảnh hưởng: Cache lớn và thuật toán quản lý tốt giúp giảm tác động của truy cập ngẫu nhiên và tăng hiệu quả xử lý, điều này có thể tăng IOPS và giảm độ trễ tổng thể.
```

### Ảnh Hưởng Của IOPS Lên Các Loại Hình Lưu Trữ
```
1. **Block Storage (Lưu trữ khối):**
   Mức độ quan trọng: RẤT CAO.
   Nguyên nhân Cấu trúc: Truy cập cấp thấp, các khối dữ liệu được truy cập trực tiếp qua địa chỉ logic mà không có lớp metadata phức tạp như file hoặc object. Block storage cung cấp latency thấp và IOPS cao, phù hợp với workloads yêu cầu truy cập dữ liệu nhỏ và ngẫu nhiên như cơ sở dữ liệu và hệ thống ảo hóa. Block storage có thể đạt hàng chục nghìn đến hàng trăm nghìn IOPS với latency sub-millisecond.
   Yêu cầu ưu tiên: Random IOPS cao, latency thấp.
   Ứng dụng điển hình: Cơ sở dữ liệu, Volumes Cloud (EBS, Azure Disk), SAN, VM disks.

2. **File Storage (Lưu trữ tệp):**
   Mức độ quan trọng: CAO.
   Nguyên nhân Cấu trúc: Có lớp filesystem và metadata (như directory, permission), dẫn tới overhead liên quan tới việc quản lý metadata. File storage cân bằng giữa random IOPS và sequential throughput, và thường có latency cao hơn block storage nhưng thấp hơn object storage trong môi trường mạng.
   Yêu cầu ưu tiên: Cân bằng giữa random và sequential IOPS, throughput để phục vụ các truy vấn quản lý tệp và truyền tải dữ liệu lớn.
   Ứng dụng điển hình: NAS, chia sẻ file SMB/NFS.

3. **Object Storage (Lưu trữ đối tượng):**
   Mức độ quan trọng: THẤP đối chỉ số IOPS truyền thống.
   Nguyên nhân Cấu trúc: Truy cập qua API/HTTP, lưu trữ theo object với metadata gắn kèm. Object storage thường ưu tiên throughput tổng thể và quy mô mở rộng lớn hơn là IOPS từng block. Latency trong object storage có thể cao hơn đáng kể so với block và file storage do overhead giao thức và xử lý trên nhiều node phân tán.
   Yêu cầu ưu tiên: Throughput và số lượng yêu cầu API đồng thời, khả năng mở rộng theo dữ liệu.
   Ứng dụng điển hình: Lưu trữ đám mây (S3, Blob), data lakes, backup/archive.
```

### Các Điểm Chuyên Sâu Liên Quan
```
1. **Latency, IOPS và Throughput:**
   Latency là thời gian để hoàn thành một yêu cầu I/O đơn lẻ, IOPS là số lượng yêu cầu trên mỗi giây, và throughput là lượng dữ liệu di chuyển mỗi giây. Mối quan hệ gần gũi của chúng cho phép đánh giá tổng thể hiệu năng của một hệ thống lưu trữ, và trong thực tế latency thấp và IOPS cao thường dẫn tới throughput lớn hơn nếu kích thước block phù hợp.

2. **Block Size & Queue Depth:**
   Kích thước block nhỏ dẫn tới nhiều IOPS hơn cho cùng một lượng dữ liệu chuyển tải, trong khi queue depth (số lượng I/O đang chờ) ảnh hưởng tới cách bộ controller quản lý song song các yêu cầu. Latency và throughput có thể thay đổi đáng kể theo block size và queue depth.

3. **Metadata và overhead:**
   File storage và object storage cần xử lý metadata nhiều hơn block storage, dẫn tới overhead về thời gian xử lý và ảnh hưởng tới latency trung bình, đặc biệt ở workload nhiều truy cập metadata.

4. **Scalability và chi phí:**
   Block storage thường có chi phí/GB cao hơn và phù hợp với performance-sensitive workloads; object storage cung cấp khả năng mở rộng gần như vô hạn với chi phí thấp hơn, thích hợp cho dữ liệu lớn không nhạy latency; file storage nằm giữa hai loại này về mặt truy cập và metadata support.
```