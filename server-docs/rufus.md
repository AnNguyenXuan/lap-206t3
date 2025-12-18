## Giới thiệu bộ cài rufus
```
Rufus là một phần mềm miễn phí và mã nguồn mở dùng để tạo USB boot được từ các file ISO. Rufus chạy trên hệ điều hành Windows và không cần cài đặt, chỉ cần tải file thực thi và chạy. Rufus hỗ trợ tạo USB boot cho nhiều hệ điều hành khác nhau, bao gồm Windows và các bản phân phối Linux, cũng như USB để chạy các công cụ cứu hộ hoặc cập nhật firmware. Rufus rất nhẹ, hoạt động nhanh và tương thích với cả các hệ thống sử dụng BIOS cổ điển và UEFI hiện đại.

Rufus cho phép người dùng chọn partition scheme như MBR hoặc GPT, định dạng hệ thống file như FAT32, NTFS hoặc exFAT, và các tùy chọn khác để phù hợp với yêu cầu khởi động của thiết bị mục tiêu. Rufus có thể viết image ISO trực tiếp vào USB, cài bootloader cần thiết và cấu trúc USB để nó hoạt động giống như một đĩa CD/DVD boot được.

Rufus hỗ trợ cả BIOS legacy và UEFI, giúp USB boot hoạt động trên nhiều thiết bị khác nhau, từ máy tính cũ đến thiết bị mới sử dụng UEFI. Rufus cũng hỗ trợ chế độ Secure Boot trên các hệ thống UEFI tương thích.

Quy trình tạo USB boot với Rufus thường bao gồm các bước: kết nối USB, mở Rufus, chọn file ISO cần ghi, chọn partition scheme và file system phù hợp, sau đó nhấn “Start” để tiến hành ghi. Khi hoàn tất, USB có thể được sử dụng để khởi động thiết bị và cài đặt hoặc chạy môi trường boot.

Rufus cũng hỗ trợ nhiều loại file ảnh như ISO và IMG, và có các tùy chọn nâng cao cho người dùng chuyên sâu như thay đổi kích thước cụm dữ liệu, nhãn thiết bị, thư mục ghi boot và các cấu hình khác. RuFus tương thích với rất nhiều loại thiết bị USB và được tin dùng bởi quản trị viên hệ thống và người dùng phổ thông.
```

## Nguyên nhân sử dụng
```
1. Tạo USB boot để cài đặt hệ điều hành
Rufus giúp tạo USB boot từ file ISO của các hệ điều hành như Windows, Linux, FreeDOS… để cài đặt OS trên máy tính, máy chủ hoặc thiết bị không có hệ điều hành sẵn.

2. Khởi động máy khi hệ điều hành bị lỗi
Khi hệ điều hành không thể khởi động, USB boot do Rufus tạo có thể dùng để chạy công cụ cứu hộ, phân vùng, sửa lỗi hoặc khôi phục dữ liệu.

3. Flash BIOS/UEFI hoặc cập nhật firmware
Rufus có thể tạo USB boot chứa công cụ cập nhật firmware hoặc BIOS/UEFI để nạp firmware ngay khi khởi động máy mà không cần hệ điều hành.

4. Tương thích rộng với cả BIOS và UEFI
Rufus hỗ trợ cả hai chuẩn khởi động phổ biến là BIOS legacy và UEFI modern, giúp USB boot có thể hoạt động trên nhiều loại thiết bị khác nhau.

5. Tốc độ tạo USB nhanh và ổn định
Rufus nổi tiếng với hiệu suất cao, tạo USB boot nhanh hơn nhiều công cụ khác cùng loại, đặc biệt khi xử lý các file ISO lớn.

6. Không cần cài đặt (portable)
Rufus là một file .exe độc lập, không yêu cầu cài đặt, có thể chạy trực tiếp trên máy Windows bất kỳ lúc nào.

7. Hỗ trợ nhiều tùy chọn nâng cao
Rufus cho phép tùy chỉnh partition scheme (MBR/GPT), hệ thống file (FAT32/NTFS/exFAT…), chia kích thước cluster và các tùy chọn khác để phù hợp với yêu cầu boot đặc thù. ([rufus-s.com][1])

8. Dễ sử dụng cho cả người mới và chuyên gia
Giao diện đơn giản, dễ hiểu giúp người mới bắt đầu có thể tạo USB boot chỉ với vài bước, trong khi người dùng nâng cao vẫn có thể tinh chỉnh các tùy chọn chi tiết.

9. Độ tin cậy cao và được tin dùng rộng rãi
Rufus là công cụ phổ biến được cộng đồng IT, quản trị hệ thống và người dùng cá nhân tin dùng vì tính ổn định, hiệu quả và ít lỗi.
```

## Các định dạng file system
```
Các dạng file system Rufus hỗ trợ
Rufus cho phép định dạng USB với nhiều hệ thống file khác nhau để phù hợp với việc boot trên các thiết bị và tải file lớn hơn giới hạn của một số file system. ([rufuse.com][1])

Các file system được Rufus hỗ trợ:
FAT32
FAT32 là file system cổ điển, tương thích rất rộng với cả BIOS và UEFI, nhưng có giới hạn file 4 GB.

NTFS
NTFS là file system Windows phổ biến, hỗ trợ file lớn hơn 4 GB, phù hợp với USB chứa các file ISO lớn.

exFAT
exFAT là file system được thiết kế cho thiết bị lưu trữ flash, không có giới hạn file 4 GB, và tương thích với nhiều hệ thống.

UDF
UDF (Universal Disk Format) được sử dụng cho một số mục đích đặc biệt, nhất là khi ISO hoặc nội dung cần tổ chức theo chuẩn quang học.

ReFS
ReFS là file system hiện đại trên Windows Server, Rufus cũng liệt kê hỗ trợ trong một số tài liệu, nhưng sử dụng thực tế phụ thuộc vào mục đích boot.
```