# 1. Lý thuyết

## 1.1 Khái niệm

- Mondo Rescue là một phần mềm mã nguồn mở (GPL) chuyên về disaster recovery: tức là tạo ảnh (image) hệ thống hoặc bản sao toàn bộ từ một hệ thống Unix/Linux (và có hỗ trợ Windows trong một số trường hợp) để khôi phục hoặc nhân bản hệ thống nếu có sự cố. 
    
- Nó hỗ trợ rất nhiều hệ tệp (ext2/3/4, XFS, JFS, ReiserFS), hỗ trợ LVM (v1 và v2), RAID phần mềm/ phần cứng, nhiều phương tiện lưu trữ (CD/DVD, băng từ, USB, NFS, ổ đĩa,…). [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Có hai thành phần chính:
    
    - `mondoarchive` — tạo bản backup/clone. [dedoimedo.com+1](https://www.dedoimedo.com/computers/mondo.html?utm_source=chatgpt.com)
        
    - `mondorescue` (và thành phần hỗ trợ boot môi trường cứu hộ) — để khôi phục. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
        
- Trong quá trình backup, Mondo sử dụng thành phần phụ là Mindi để tạo một môi trường boot rescue (mini-distro) có kernel/modules phù hợp với hệ thống. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    

## 1.2 Nguyên lý hoạt động chính

Ở mức cao, quá trình hoạt động của Mondo gồm các bước sau:

1. Trên máy chủ đang chạy, thực hiện tạo backup: Mondo quét phân vùng, hệ thống file, LVM/RAID, tạo mount list, đặt cấu hình. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
2. Mondo sẽ tạo một môi trường boot cứu hộ (mindi) chứa kernel + modules + driver cần thiết để khi máy chủ bị hỏng (ví dụ ổ đĩa bị mất, bảng phân vùng bị xóa, hệ điều hành không khởi động) có thể boot vào môi trường rescue. [landley.net](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
3. Sau đó, backup sẽ được lưu vào media như CD/DVD, tape, USB, NFS hoặc ổ đĩa khác — gồm toàn bộ dữ liệu, phân vùng, MBR, boot loader, cấu hình hệ thống, file hệ điều hành, ứng dụng. [mondorescue.org+1](https://www.mondorescue.org/docs/mondorescue-howto.html?utm_source=chatgpt.com)
    
4. Khi cần khôi phục:
    
    - Boot vào môi trường rescue do Mindi tạo ra.
        
    - Môi trường này sẽ nhận dạng cấu hình phần cứng hiện tại, scan các ổ đĩa, LVM, RAID, và cung cấp menu interactive hoặc tự động để định nghĩa lại phân vùng, chọn nơi restore, cấu hình boot loader, cấu hình lại fstab. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
        
    - Restore file system và thiết lập lại hệ thống để có thể khởi động lại. Nếu phần cứng khác (ví dụ ổ đĩa khác số lượng, controller khác) vẫn có thể adapt nếu driver hỗ trợ. [landley.net](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
        

## 1.3 Điểm nổi bật và hạn chế

**Ưu điểm:**

- Hỗ trợ đa dạng hệ thống file, LVM/RAID, phần cứng khác nhau. [dedoimedo.com+1](https://www.dedoimedo.com/computers/mondo.html?utm_source=chatgpt.com)
    
- Có khả năng “bare-metal restore” (khôi phục máy trống hoàn toàn) — rất phù hợp với môi trường máy chủ vật lý. [mondorescue.org+1](https://www.mondorescue.org/docs/mondorescue-howto.html?utm_source=chatgpt.com)
    
- Có thể dùng để nhân bản (clone) một hệ thống sang nhiều máy — phù hợp cho triển khai nhanh. [landley.net](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    

**Hạn chế / lưu ý:**

- Phụ thuộc vào driver/hardware: nếu phần cứng thay đổi nhiều (ví dụ controller ổ đĩa khác, boot loader UEFI thay vì BIOS truyền thống) có thể gặp vấn đề. Ví dụ forum nói: “hardware differences might make the copy system unbootable.” [Server Fault+1](https://serverfault.com/questions/75806/how-to-completely-backup-a-linux-image-and-then-load-it-in-another-server?utm_source=chatgpt.com)
    
- Version và repository đôi khi không dễ cài đặt trên các distro mới hoặc hỗ trợ có hạn. Ví dụ cài trên Rocky Linux gặp dependency. [Rocky Linux Forum](https://forums.rockylinux.org/t/mondo-rescue-on-rl9-2/11214?utm_source=chatgpt.com)
    
- Đối với môi trường doanh nghiệp lớn, có thể cần tích hợp thêm quy trình backup/incremental, quản lý thay đổi, kiểm thử … Mondo chủ yếu là image-based backup/restore, không thay thế hoàn toàn backup dữ liệu thường xuyên.
    

---

# 2. Yêu cầu khi triển khai cho máy chủ vật lý tại trung tâm dữ liệu

Khi bạn muốn dùng Mondo Rescue cho máy chủ vật lý đặt tại trung tâm dữ liệu (data centre), cần xem xét và đáp ứng các yêu cầu sau:

## 2.1 Yêu cầu phần cứng và môi trường

- Máy chủ phải có phần cứng chuẩn và driver hỗ trợ kernel sẽ dùng trong môi trường rescue: ví dụ controller ổ đĩa, RAID controller (HW hoặc SW), LVM, mạng (nếu backup hoặc restore qua mạng). Vì môi trường rescue sẽ cần driver tương thích. [mondorescue.org+1](https://www.mondorescue.org/docs/mondorescue-howto.html?utm_source=chatgpt.com)
    
- Đĩa/ổ lưu backup hoặc media: Có đủ không gian lưu trữ backup image, phương tiện lưu trữ (ví dụ USB, ổ đĩa ngoài, NFS mount, tape) phù hợp. Mondo hỗ trợ nhiều media: CD/DVD, tape, NFS, ổ đĩa. [Linux Security+1](https://linuxsecurity.com/howtos/learn-tips-and-tricks/how-to-clone-backup-linux-systems-using-mondo-rescue-disaster-recovery-tool?utm_source=chatgpt.com)
    
- Máy chủ cần đủ bộ nhớ và CPU để thực hiện backup/restore (mặc dù không quá nặng, nhưng quá trình tạo image và nén có thể dùng tài nguyên). Ví dụ tài liệu yêu cầu: 64MB RAM tối thiểu (ở phiên bản rất cũ) nhưng thực tế nên nhiều hơn. [ospedalesicuro.eu+1](https://www.ospedalesicuro.eu/storia/materiali/doc/Mondo-Rescue-Mindi-Linux-HOWTO.pdf?utm_source=chatgpt.com)
    
- Kết nối mạng nếu bạn dự kiến lưu backup qua mạng (NFS, CIFS, SSHFS) hoặc restore qua mạng (PXE, NFS). Mondo hỗ trợ PXE deployment. [landley.net](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Trước khi restore, đảm bảo máy chủ có quyền boot từ phương tiện rescue (CD/USB/boot mạng) và BIOS/UEFI hỗ trợ.
    

## 2.2 Yêu cầu phần mềm & cấu hình

- Cài đặt Mondo và Mindi trên hệ điều hành cần backup. Phải đảm bảo phiên bản tương thích với distro máy chủ. Ví dụ có các vấn đề cài đặt trên Ubuntu/Rocky Linux. [Ask Ubuntu+1](https://askubuntu.com/questions/781970/mondo-rescue-repository-unsigned-for-apt-get?utm_source=chatgpt.com)
    
- Kiểm tra hệ thống file, LVM/RAID có hỗ trợ bởi Mondo phiên bản đó. Ví dụ nếu dùng LVM v2, RAID phần mềm thì Mondo phải hỗ trợ. [landley.net](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Xác định rõ phân vùng khôi phục: Boot loader (MBR hoặc UEFI), hệ thống file root, swap, phân vùng dữ liệu, phân vùng khôi phục. Mondo sẽ sao lưu phân vùng vật lý, MBR, và boot loader. [dedoimedo.com](https://www.dedoimedo.com/computers/mondo.html?utm_source=chatgpt.com)
    
- Cấu hình backup location: nơi lưu image backup, đặt lịch hoặc thủ công, xác định exclude nếu cần (ví dụ các thư mục không cần backup). [dedoimedo.com](https://www.dedoimedo.com/computers/mondo.html?utm_source=chatgpt.com)
    
- Kiểm thử môi trường rescue: tạo boot rescue (mindi) và đảm bảo có thể boot vào môi trường đó, driver ổ đĩa/RAID nhận đúng, mount list đúng. Đây là bước rất quan trọng để đảm bảo restore khi cần.
    

## 2.3 Quy trình vận hành và các bước triển khai

- Bước 1: Chuẩn bị máy chủ và xác định cấu hình: biết rõ ổ đĩa, RAID, LVM, mount list, hệ điều hành, phân vùng.
    
- Bước 2: Cài đặt Mondo/Mindi và tạo môi trường rescue. Kiểm thử boot từ USB/CD/ISO.
    
- Bước 3: Tạo bản backup (full image) bằng `mondoarchive`. Ghi lại logs, media.
    
- Bước 4: Lưu trữ backup image ở nơi an toàn (nên tách khỏi máy chủ chính, có thể off-site hoặc ổ đĩa khác trong data centre).
    
- Bước 5: Định kỳ kiểm thử khôi phục (restore) từ backup — vì backup mà không thể restore là vô dụng.
    
- Bước 6: Trong sự cố: Boot máy chủ từ môi trường rescue → thiết lập lại phân vùng/RAID nếu cần → restore image → cấu hình boot loader → khởi động lại.
    
- Bước 7: Sau khôi phục: kiểm tra hệ thống, logs, dịch vụ, data integrity.
    

## 2.4 Các lưu ý về môi trường trung tâm dữ liệu

- Máy chủ vật lý thường sử dụng RAID phần cứng hoặc phần mềm, controller đặc biệt, boot từ SAN hoặc iSCSI… cần đảm bảo môi trường rescue hỗ trợ driver đó.
    
- Nếu máy chủ có UEFI (thay vì BIOS) thì cần kiểm tra Mondo/Mindi có hỗ trợ UEFI boot hay không.
    
- Phải có quy trình kiểm soát truy cập đến media backup, bảo mật lưu trữ backup (vì hình ảnh hệ thống đầy đủ có dữ liệu nhạy cảm).
    
- Tính tương thích phần cứng: nếu sau này thay ổ cứng, thay controller, thay bố trí phân vùng thì việc restore từ image cũ có thể gặp vấn đề — nên có kế hoạch cập nhật image periodic sau mỗi thay đổi lớn.
    
- Ghi nhật ký (logging) backup/restore, tạo cảnh báo nếu backup thất bại.
    
- Kiểm thử khôi phục định kỳ (drill) để đảm bảo khi có sự cố thật sẽ biết đúng quy trình.
    

---

# 3. Các trường hợp có thể cứu được / phù hợp

Dưới đây là những kịch bản mà Mondo Rescue phù hợp và có thể cứu được:

- Máy chủ vật lý bị hỏng hoàn toàn hệ điều hành (OS corruption), không boot được, muốn khôi phục toàn bộ hệ thống từ “bare-metal”.
    
- Ổ đĩa hệ thống bị hỏng và thay bằng ổ mới: có image backup thì có thể restore lên ổ mới.
    
- HDD/SSD bị lỗi nhưng các phân vùng dữ liệu vẫn có thể tái tạo từ backup image.
    
- Cần nhân bản nhanh một cấu hình máy chủ chuẩn ra nhiều máy khác (clone). Mondo hỗ trợ clone/deployment. [landley.net](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Cần thực hiện “migration” từ một máy vật lý sang máy vật lý khác (hoặc vật lý → ảo) nếu phần cứng tương thích và driver hỗ trợ.
    
- Phục hồi toàn bộ hệ thống sau khi có sự cố như ransomware, hoặc lỗi cấu hình nghiêm trọng mà không thể sửa được.
    

Kèm theo, cũng nên biết những **trường hợp khó hoặc không đảm bảo**:

- Nếu phần cứng thay đổi quá lớn (như loại controller khác, ổ đĩa khác, chuyển từ BIOS sang UEFI) mà môi trường rescue không hỗ trợ driver mới thì có thể boot lỗi.
    
- Máy chủ sử dụng những công nghệ đặc biệt (boot từ SAN/iSCSI, controller cực kì riêng, thiết kế rất customised) mà môi trường rescue không có driver.
    
- Nếu chỉ backup image nhưng dữ liệu thay đổi thường xuyên và cần khôi phục từng file hoặc incremental thì Mondo không phải là công cụ chuyên cho incremental file-level backup.
    
- Nếu backup image bị lỗi hoặc media bị hỏng → restore sẽ không thành công. Do đó kiểm thử backup là rất quan trọng.
    

---

# 4. Đề xuất các test-case (kịch bản kiểm thử)

Dưới đây là đề xuất các test case để bạn triển khai trong lab hoặc môi trường thử nghiệm, phù hợp với đồ án “bảo mật doanh nghiệp” (như phần “Triển khai thực tế”) — bạn có thể đưa vào Chương triển khai thực tế.

| Test ID | Mục tiêu                                                 | Mô tả chi tiết                                                                                                                        | Kết quả mong đợi                                                                                     |
| ------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| TC-01   | Kiểm thử tạo môi trường rescue                           | Cài Mondo/Mindi trên máy Linux vật lý, tạo USB hoặc ISO rescue, khởi động máy từ USB.                                                 | Máy boot vào môi trường rescue thành công, nhận đúng driver ổ đĩa, phân vùng hiển thị đúng.          |
| TC-02   | Backup full hệ thống                                     | Trên máy chủ thử nghiệm (vật lý hoặc VM mô phỏng vật lý): chạy `mondoarchive` lưu vào ổ đĩa ngoài/NFS. Thực hiện backup thành công.   | Image backup được tạo đầy đủ, log không báo lỗi, kích thước hợp lý.                                  |
| TC-03   | Restore trên cùng phần cứng                              | Sau khi backup, giả lập xóa phân vùng hệ thống hoặc dùng ổ mới, khởi từ USB rescue, restore image.                                    | Hệ thống khởi động lại thành công, các dịch vụ chạy, dữ liệu nguyên vẹn.                             |
| TC-04   | Restore trên phần cứng khác (ổ cứng khác/RAID khác)      | Thay ổ mới, hoặc đổi RAID config (như từ RAID-1 sang RAID-5), khởi từ môi trường rescue, restore image, điều chỉnh phân vùng nếu cần. | Hệ thống khởi lại ổn định, driver ổ đĩa nhận đúng, boot loader hoạt động.                            |
| TC-05   | Clone máy chủ chuẩn                                      | Tạo máy chủ chuẩn, backup image, restore lên nhiều máy vật lý khác với cấu hình phần cứng tương đồng.                                 | Các máy clone khởi động và hoạt động giống máy chuẩn.                                                |
| TC-06   | Kiểm thử khôi phục trong tình huống sự cố thật           | Giả lập tình huống: OS bị xâm nhập, hệ thống không boot; hoặc ổ hệ thống hỏng. Chạy restore trong thời gian giới hạn.                 | Khôi phục trong thời gian được định trước, dịch vụ hoạt động lại đúng.                               |
| TC-07   | Kiểm thử thay đổi phần cứng lớn                          | Giả lập chuyển từ BIOS → UEFI, hoặc controller khác, restore image.                                                                   | Nếu hỗ trợ driver thì khởi động thành công; nếu không thì ghi nhận lỗi và nghiên cứu cách khắc phục. |
| TC-08   | Kiểm thử backup định kỳ và kiểm tra tính toàn vẹn        | Lên lịch backup định kỳ, và chạy `mondorestore -T` (compare mode) hoặc tương đương để xác minh image.                                 | Backup được tạo đúng lịch, verify image thành công, báo cáo log lưu trữ.                             |
| TC-09   | Kiểm thử bảo mật lưu trữ image                           | Kiểm tra quyền truy cập tới backup media, mã hóa nếu cần, và khả năng khởi động từ backup nếu media bị đánh cắp.                      | Đảm bảo image backup được bảo vệ, nếu bị truy cập trái phép sẽ không dễ bị sử dụng.                  |
| TC-10   | Kiểm thử khôi phục dữ liệu ứng dụng/ dịch vụ sau restore | Sau restore, kiểm tra các ứng dụng/ dịch vụ (ví dụ mail server, web server) hoạt động, kết nối cơ sở dữ liệu, logs.                   | Dịch vụ hoạt động như trước khi tạo backup, tính năng không bị ảnh hưởng.                            |


# 5. Các tài liệu trước khi triển khai

Link tài liệu gốc của nhà phát triển: http://www.mondorescue.org/docs/mondorescue-howto.html

Trang chủ: http://mondorescue.org

Link downloads: http://ftp.mondorescue.org/ubuntu/
# 6. Triển khai


# 7. FAQ

## 1. Nếu ta có một máy chủ vậy lý dell r630 hoặc r730,... Cấu hình như sau: RAID1 cho OS và RAID5 cho các ổ Data thì mondorescue chạy có ổn không và nó có giữ nguyên raid nếu các ổ cứng không thay đổi gì như vị trí, dung lượng,... Nó hoạt động như nào? + Nếu tôi thay ổ cứng, chẳng hạn tháo ra thêm 1 ổ mới chẳng hạn hoặc thay ổ dung lượng lớn hơn ban đầu,... nó có hoạt động không?

### A. Cách Mondo Rescue xử lý RAID trong trường hợp chuẩn

- Theo tài liệu chính thức: Mondo Rescue hỗ trợ **RAID phần mềm và RAID phần cứng** (software & hardware RAID) và cũng hỗ trợ LVM v1/v2. [archives.pass-the-salt.org+3landley.net+3ospedalesicuro.eu+3](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Khi bạn chạy `mondoarchive`, chương trình sẽ quét cấu trúc ổ đĩa, phân vùng, LVM/RAID, tạo mount-list và ghi lại thông tin này. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Khi restore bằng `mondorestore`, có chế độ interactive cho phép bạn **thay đổi** kiểu phân vùng, kích thu­ớc, layout nếu cần, hoặc để nguyên nếu target giống hệt source. [archives.pass-the-salt.org+2landley.net+2](https://archives.pass-the-salt.org/RMLL%20Security%20Tracks/2009/slides/RMLL-Sec-2009-mondo-rescue.pdf?utm_source=chatgpt.com)
    
- Tài liệu HOWTO nói rõ: “It supports … software & hardware RAID” và “Ability to change FS type, layout, SW. Raid, even HW configuration.” [archives.pass-the-salt.org](https://archives.pass-the-salt.org/RMLL%20Security%20Tracks/2009/slides/RMLL-Sec-2009-mondo-rescue.pdf?utm_source=chatgpt.com)
    
- FAQ của Mondo cũng nói rằng nếu bạn restore lên một target mà RAID chưa được tạo sẵn thì bạn có thể trong chế độ expert tạo lại RAID thủ công trước rồi chạy restore. [trac.mondorescue.org](https://trac.mondorescue.org/wiki/FAQ?utm_source=chatgpt.com)
    

**⇒ Kết luận phần A**: Nếu bạn có máy chủ với RAID1 cho OS và RAID5 cho các ổ data, và nếu setup driver/RAID controller bình thường (Dell/Raid controller chuẩn) thì Mondo Rescue _có khả năng_ backup và khôi phục cấu trúc RAID đó và giữ nguyên layout (nếu target giống source).

---

### B. Trường hợp thay ổ đĩa hoặc thay đổi cấu hình RAID – những gì cần lưu ý

Bạn nêu hai tình huống: (1) “ổ đĩa không thay đổi vị trí/dung lượng” và (2) thay ổ mới hoặc thay dung lượng lớn hơn ban đầu. Mình phân tích:

#### B.1 Trường hợp ổ đĩa **không thay đổi gì** (vị trí, dung lượng, controller đều giữ)

- Trong trường hợp này, quá trình restore sẽ gần như “giữ nguyên” layout: Mondo sẽ ghi lại cấu trúc RAID và phân vùng, rồi khi restore nó sẽ format ổ, tạo lại RAID (nếu cần) và ghi dữ liệu vào. Nếu mọi thứ giống như bản backup thì khả năng thành công rất cao.
    
- Bạn có RAID1 cho OS và RAID5 cho dữ liệu: nếu controller RAID/hardware vẫn giữ, card RAID nhận đúng, driver có trong môi trường rescue thì OS sẽ boot bình thường.
    
- Tuy nhiên, vẫn lưu ý: bạn cần đảm bảo môi trường cứu hộ (mindi) có driver cho card RAID Dell trên R630/R730 — nếu driver thiếu có thể không nhận được ổ đĩa hoặc RAID array. Tài liệu nhấn mạnh “most hardware support issues are from mindi – because it must include the drivers.” [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Nếu mọi thứ giống vậy, thì “giữ nguyên RAID” ở mức logic (RAID array vẫn như backup) là khả thi.
    

#### B.2 Trường hợp thay ổ đĩa mới hoặc dung lượng lớn hơn hoặc thay controller

- **Thêm ổ mới** (ví dụ bạn muốn mở rộng RAID5 hoặc thêm ổ vào pool):
    
    - Nếu bạn chỉ _thêm_ ổ vào array (giữ các ổ cũ + tăng dung lượng RAID5) sau khi backup, thì khi restore từ image cũ: image sẽ ghi lại cấu trúc array thời điểm backup (chưa thêm ổ). Khi restore, nếu bạn đưa lại chính xác các ổ như thời điểm backup thì OK.
        
    - Nhưng nếu bạn muốn restore rồi sau đó mở rộng array — đó là việc sau restore thực hiện mở rộng, chứ Mondo không “thêm ổ” tự động vào RAID mới cho bạn. Mondo restore khôi phục thời điểm backup, không tự “thêm ổ mới” cho cấu trúc RAID (trừ bạn cấu hình thủ công trong môi trường restore).
        
- **Thay ổ đĩa dung lượng lớn hơn**:
    
    - Nếu bạn thay ổ từ dung lượng nhỏ vào ổ dung lượng lớn hơn nhưng vẫn giữ controller và cấu hình RAID giống hệt, thì khả năng thành công là khá cao: bạn restore như thường, và sau đó có thể “dùng thêm” dung lượng chưa dùng. Nhưng lưu ý: Mondo restore sẽ khôi phục phân vùng theo kích thước thời điểm backup — không tự mở rộng phân vùng trừ bạn chỉ định. Tài liệu nói “you will be asked … layout could be modified … size …” khi restore. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
        
    - Nếu dung lượng lớn hơn nhưng bạn giữ nguyên vị trí ổ và controller, driver – xem như OK.
        
- **Thay controller RAID hoặc thay loại RAID**:
    
    - Đây là trường hợp rủi ro cao hơn. Nếu controller thay đổi loại hoặc driver khác, thì môi trường rescue phải có driver cho controller mới — nếu không, array có thể không được nhận hoặc array logic bị mất. Tài liệu khuyến nghị: “Need knowledge of master and target platforms (potential different drivers).” [archives.pass-the-salt.org](https://archives.pass-the-salt.org/RMLL%20Security%20Tracks/2009/slides/RMLL-Sec-2009-mondo-rescue.pdf?utm_source=chatgpt.com)
        
    - Nếu RAID configuration thay đổi (ví dụ từ RAID5 sang RAID6 hoặc từ bộ controller khác) thì bạn phải trong restore chọn interactive và cấu hình lại phân vùng/array cho đúng.
        

#### Những lưu ý thực tế bạn nên kiểm tra

- Trước khi backup: kiểm tra cấu trúc array, note controller (ví dụ Dell PERC model), note driver.
    
- Khi tạo môi trường rescue (mindi): đảm bảo include các module/drivers cần thiết cho RAID controller.
    
- Khi restore: khởi vào môi trường rescue, chọn vs interactive mode, nhìn xem array đã hiển thị chưa bằng `mdadm --detail` hoặc tool tương đương (nếu software RAID) hay xem controller trong hardware RAID đã nhận hay chưa. Nếu chưa thì bạn nên chuẩn bị kịch bản “expert mode” hoặc thủ công tạo lại array rồi restore.
    
- Nếu thay ổ đĩa hoặc mở rộng array, nên **kiểm thử** với môi trường thử nghiệm trước khi vào môi trường production.
    

---

### C. Đối với máy chủ Dell R630/R730 của bạn

Với máy chủ vật lý như Dell R630/R730, cấu hình bạn đưa (RAID1 cho OS, RAID5 cho data) là khá phổ biến. Dưới đây là những lời khuyên và điều bạn cần đặc biệt lưu ý:

- Máy Dell sử dụng controller RAID PERC (ví dụ PERC H730, H730P…) — bạn cần đảm bảo driver cho PERC này có trong môi trường rescue. Nếu không, thời điểm restore có thể máy không “thấy” các ổ hoặc array không được nhận.
    
- Nếu bạn giữ nguyên controller và ổ đĩa (không thay gì) thì Mondo rất có thể hoạt động tốt và giữ nguyên cấu trúc RAID như lúc backup.
    
- Nếu bạn thay ổ hoặc mở rộng array — ví dụ muốn thay ổ dung lượng lớn hơn hoặc thêm ổ vào RAID5 data — thì bạn nên:
    
    1. Trước khi backup/after backup: thực hiện mở rộng array trên production hoặc test môi trường.
        
    2. Trong backup: chạy `mondoarchive` sau khi mở rộng để có backup sát với hiện trạng.
        
    3. Khi restore: nếu dùng ổ lớn hơn, bạn có thể trong interactive mode mở rộng phân vùng sau restore để tận dụng dung lượng lớn hơn.
        
- Nếu bạn **thay controller** hoặc chuyển sang chế độ khác (ví dụ từ RAID hardware sang software RAID) thì bạn nên ít nhất test restore trong môi trường test để chắc chắn driver/workflow.
    
- Tốt nhất: có **nhật ký backup + kiểm thử restore** định kỳ — bởi vì chỉ backup mà không thể restore khi sự cố là vô ích.

## 2. Tôi có thể backup toàn bộ server sang nhiều ổ cứng cùng lúc không? Ví dụ dữ liệu của toàn server là 1T nhưng tôi chỉ có 3 ổ 500GB để backup chẳng hạn.

### ✅ Khả thi trong phạm vi nào

- Mondo Rescue hỗ trợ lưu bản backup (image) lên nhiều loại media: đĩa cứng (hard disk), USB, mạng (NFS), CD/DVD, tape. [Linux Security+3mondorescue.org+3landley.net+3](https://www.mondorescue.org/?utm_source=chatgpt.com)
    
- Trong tài liệu HOWTO: “the size of the image is a parameter … mondoarchive will create the number of media needed automatically” when using e.g. CD/DVD. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Điều đó cho thấy rằng Mondo có khả năng **chia dữ liệu backup** ra thành nhiều tập tin/khối nhỏ hơn (ví dụ khi bạn dùng CD size giới hạn, nó sẽ tự tạo nhiều đĩa) — nghĩa là concept “chia ra nhiều media vì mỗi media nhỏ hơn toàn dữ liệu” là được hỗ trợ.
    

→ Như vậy: nếu bạn có vài ổ đĩa nhỏ hơn tổng dữ liệu cần backup thì **về nguyên tắc** có thể dùng Mondo để backup, nếu bạn sắp xếp đúng — ví dụ phân chia image hoặc backup từng phần rồi lưu qua từng ổ.

---

### ⚠️ Những giới hạn / điều cần lưu ý

Tuy khả thi nhưng có nhiều điểm cần chú ý:

1. **Tổng dung lượng backup lớn hơn media**: Nếu dữ liệu toàn server ~1 TB nhưng mỗi ổ bạn có chỉ 500 GB (3 ổ = tổng 1.5 TB) thì tổng media đủ dung lượng. Nhưng cần kiểm tra rằng backup image sẽ không lớn hơn tổng media khả dụng (1.5 TB) và phân chia phù hợp. Nếu backup image >1.5 TB thì không đủ.
    
2. **Cách Mondo phân chia media**: Mondo cho phép chỉ định kích thước tối đa mỗi “khối media” (ví dụ size = 4500m, tức ~4.5 GB khi dùng DVD) trong lệnh `-s`. [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com) Nhưng khi dùng ổ đĩa (hard disk) làm destination, bạn phải kiểm tra xem Mondo có hỗ trợ “multi-disk” theo kiểu “khi ổ đầy chuyển sang ổ khác” một cách tự động hay không — tài liệu không rõ ràng là nó _tự động_ chuyển giữa nhiều ổ riêng biệt hay bạn phải chỉ định từng destination.
    
3. **Quản lý backup location**: Nếu bạn có 3 ổ 500 GB, bạn cần đảm bảo mỗi ổ mount được, đủ dung lượng, và bạn cấu hình Mondo để đặt destination hoặc chia backup ra cho từng mount. Có thể bạn sẽ phải trực tiếp cấu hình để backup phần first ~500 GB lên ổ A, phần tiếp theo ~500 GB lên ổ B, v.v., hoặc dùng thư mục chung và Mondo tạo nhiều tập tin image rồi bạn phân phối chúng sang các ổ.
    
4. **Restore phức tạp hơn**: Khi backup được chia ra nhiều ổ, khi restore bạn phải đảm bảo rằng **tất cả** các phần image (trên tất cả các ổ) được truy cập. Nếu một trong các ổ mất hoặc không mount được thì toàn bộ image có thể hỏng hoặc không thể restore hoàn chỉnh. Điều này làm tăng rủi ro.
    
5. **Media redundancy & reliability**: Sử dụng nhiều ổ nhỏ thay vì một ổ lớn có thể làm tăng điểm thất bại (một ổ hỏng là mất phần image). Cần nghĩ tới backup đồng thời hoặc checksum kiểm tra.
    
6. **Thời gian & thao tác**: Có thể bạn sẽ mất thời gian hơn để mount/unmount từng ổ, cấu hình Mondo, kiểm tra trạng thái.
    

---

### 🔍 Gợi ý cách thực hiện với trường hợp của bạn (1 TB dữ liệu + 3 ổ mỗi ổ 500 GB)

Dưới đây là cách bạn có thể thực hiện để tối ưu:

- Bước 1: Xác định rõ dung lượng cần backup hiện tại (ví dụ ~1 TB) và xác định dung lượng trống trên mỗi ổ (500 GB). Tổng media (3×500 GB = 1.5 TB) là đủ lý thuyết.
    
- Bước 2: Mount 3 ổ đĩa vào máy chủ backup (gắn ổ A, B, C).
    
- Bước 3: Cấu hình Mondo để lưu destination đến một thư mục chung hoặc chỉ định lần lượt:
    
    `mondoarchive -d /mnt/backupA –s 490000m …`  
    
    và nếu tới giới hạn ổ A thì chuyển sang backupB, v.v. (tùy hỗ trợ).
    
- Bước 4: Trong quá trình backup, nếu Mondo hỗ trợ option chia khối tự động (`-s size`), bạn đặt kích thước mỗi khối sao cho <500 GB, ví dụ 450000m (~450 GB) để đảm bảo mỗi phần image vừa một ổ. (Tài liệu nói `-s` là “size of the images created”). [landley.net+1](https://www.landley.net/kdocs/ols/2008/ols2008v1-pages-77-84.pdf?utm_source=chatgpt.com)
    
- Bước 5: Sau khi backup xong, validate rằng tất cả phần image trên 3 ổ đều tạo đầy đủ, kiểm tra log `/var/log/mondoarchive.log` để chắc backup thành công.
    
- Bước 6: Thực hiện thử nghiệm restore từ các phần image: mount lại 3 ổ, boot môi trường rescue, chọn các phần image để restore. Ghi lại xem quá trình restore có hỏi nhiều lần, có lỗi không.
    
- Bước 7: Lập kế hoạch kiểm thử định kỳ (như test-case ở phần trước) và lưu ý rằng nếu một ổ xuống cấp (media lỗi), bạn vẫn có bản lữu lưu khác (ví dụ copy image sang off-site).

