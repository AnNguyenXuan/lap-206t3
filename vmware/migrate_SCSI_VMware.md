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
```

