# 1. Tình huống

Có một máy chủ vật lý, các ổ cứng tạo RAID-1 chứa OS (Linux...) đã gần đầy, bạn muốn thay ổ dung lượng lớn hơn và mở rộng dung lượng của RAID.

# 2. Tiến hành

Điều kiện: Các ổ đĩa mới phải được format và không còn Foregion Key (Raid cũ). Phải kiểm tra kĩ trước khi thực hiện.

1. Rút 1 ổ duy nhất, khi này đèn ở các ổ còn lại sẽ bắt đầu nháy liên tục và trên IDRAC, ILO,.. sẽ báo lỗi slot ổ (Physical Disk). Và kiểm tra Virtual Disk sẽ thấy chuyển từ Online sang Degraded.

2. Cắm ổ mới vào slot trống vừa tháo, đợi RAID san dữ liệu sang ổ mới. Khi này đèn ở server vẫn sẽ nháy.

	- Kiểm tra trên IDRAC/ILO xem physical disk "phải báo Ready hoặc Online, Ok,..."
	- Phần Virtual Disk vẫn sẽ ở Degraded (Cảnh báo vàng).

3. Sau khi ổ san xong. Phải kiểm tra kĩ
	- Đèn sẽ không nháy nữa (Nhớ tắt tính năng blink)
	- Physical Disk phải xanh (Ready, Online,..) kiểm tra slot ổ tại vị trí mới nhận đúng dung lượng chưa, có online không...
	- Virtual Disk: Raid cũng phải xanh (Ready, online...) không còn Degraded hay lỗi gì.

4. Sau khi chắc chắn bước 3 đã hoàn tất. Rút 1 ổ nữa ra.
	- Đợi cho ổ bắt đầu nháy, kiểm tra như bước 1.

5. Cắm ổ mới vào slot trống vừa tháo, đợi RAID san dữ liệu sang ổ mới. Khi này đèn ở server vẫn sẽ nháy.

	- Kiểm tra trên IDRAC/ILO xem physical disk "phải báo Ready hoặc Online, Ok,..."
	- Phần Virtual Disk vẫn sẽ ở Degraded (Cảnh báo vàng).

6. Sau khi ổ san xong. Phải kiểm tra kĩ
	- Đèn sẽ không nháy nữa (Nhớ tắt tính năng blink)
	- Physical Disk phải xanh (Ready, Online,..) kiểm tra slot ổ tại vị trí mới nhận đúng dung lượng chưa, có online không...
	- Virtual Disk: Raid cũng phải xanh (Ready, online...) không còn Degraded hay lỗi gì.

7. Sau khi thay và san hết các ổ. Dung lượng RAID vẫn sẽ như cũ nếu chưa mở rộng.

	- Confirm với khách hàng, bước này phải tắt server vật lý.
	- Tắt server vật lý -> Vào BiOS -> Chọn System Setup (F2)
	- Chọn Device Setting -> Intergrated RAID Controller...
	- Chọn Virtual Disk Management
	- Chọn RAID cần mở rộng (Cẩn thận không nhầm)
	- Tab sang phần Select Operation -> Chọn Expand Virtual Disk
	- Xuống dưới chọn GO

8. Sẽ có ô nhập số (%) nên để mặc định 100 tức 100% là lấy toàn bộ dung lượng của ổ mới gộp vào RAID.

9. Chọn OK -> Back lại ra phần Virtual Disk Management -> Chọn lại RAID vừa mở rộng xem có tiến trình Background Initialzation đang chạy không (Bắt buộc). Đợi quá trình này hoàn tất (Sẽ khá lâu) -> Khi này back lại Virtual Disk Management sẽ thấy dung lượng tăng lên -> Thoát BIOS -> Vào OS kiểm tra.