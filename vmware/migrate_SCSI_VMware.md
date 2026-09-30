## Chuyển đổi LSI SCSI sang PV SCSI cho bài toán đọc ghi số lượng lớn
```
Bước 1: Power Off Machine
Bước 2: Tạo PV SCSI card và 1 hard disk, gán PV SCSI vào disk này
Bước 3: Bật Machine, kiểm tra computer manager xem đã nhận driver PV SCSI chưa
Bước 4: Power Off Machine, Xóa hard disk vừa tạo, sau đó gán PV SCSI cho Disk cũ
Bước 5: Power On Machine và kiểm tra
```


## Test hiệu năng với diskspd trên Windows
```
:: QD1
diskspd.exe -c10G -d60 -r -b4K -o1 -t1 -w30 -Sh -L C:\DiskTest\test.dat

:: QD4
diskspd.exe -c10G -d60 -r -b4K -o4 -t1 -w30 -Sh -L C:\DiskTest\test.dat

:: QD16
diskspd.exe -c10G -d60 -r -b4K -o16 -t1 -w30 -Sh -L C:\DiskTest\test.dat

:: QD32
diskspd.exe -c10G -d60 -r -b4K -o32 -t1 -w30 -Sh -L C:\DiskTest\test.dat


-c10G: Tạo một file dữ liệu mẫu có kích thước 10 Gigabyte để phục vụ cho bài kiểm tra (nếu file chưa tồn tại).
-d60: Thời gian chạy bài kiểm tra là 60 giây (Duration).
-r: Thực hiện các truy xuất Đọc/Ghi ngẫu nhiên (Random I/O). Nếu không có cờ này, mặc định công cụ sẽ truy xuất tuần tự (Sequential).
-b4K: Kích thước của mỗi khối dữ liệu (Block size) truy xuất là 4 Kilobyte. (Mức 4K thường được dùng để giả lập các tác vụ hệ điều hành hoặc cơ sở dữ liệu nhỏ).
-o1: Hàng đợi lệnh (Queue Depth / Outstanding I/O requests) là 1. Mỗi luồng sẽ chỉ gửi 1 yêu cầu I/O và đợi xong mới gửi tiếp.
-t1: Số lượng luồng xử lý (Threads) được sử dụng là 1 luồng.
-w30: Tỉ lệ tác vụ Ghi (Write) là 30%. Điều này đồng nghĩa với việc 70% tác vụ còn lại sẽ là Đọc (Read).
-Sh: Vô hiệu hóa cả bộ nhớ đệm phần mềm (software caching) và bộ nhớ đệm ghi phần cứng (hardware write caching). Việc tắt cache giúp bài test phản ánh đúng tốc độ phần cứng vật lý thực tế.
-L: Kích hoạt việc đo lường và thống kê độ trễ (Latency) trong bản báo cáo kết quả.
```

