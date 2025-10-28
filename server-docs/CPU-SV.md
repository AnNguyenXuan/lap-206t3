## Phân loại CPU Intel
```
Dòng cho máy tính cá nhân : Intel Core Series
Dòng cho máy trạm (Workstation) : Intel Xeon W-Series
Dòng cho máy chủ (Server) : Intel Xeon Scalable (Platium, Gold, Silver, Bronze)
```

## Phân loại CPU AMD
```
Dòng cho máy tính cá nhân : AMD Ryzen 
Dòng cho máy trạm (workstation) : AMD Ryzen Threadripper
Dòng cho máy chủ (server) : AMD EPYC
```

## Phân loại ổ cứng
```
HDD : 
Gồm đĩa từ (platter) quay tốc độ cao (5400–7200 vòng/phút),
Và đầu đọc/ghi (read/write head) di chuyển để truy cập dữ liệu.
Dữ liệu được ghi bằng từ tính trên mặt đĩa.

SSD : 
Không có bộ phận cơ học.
Lưu dữ liệu trong chip nhớ flash NAND.
Truy xuất bằng điện tử nên nhanh gấp hàng chục lần HDD.

Các chuẩn kết nối ổ cứng :
1. SATA (Serial ATA)
Băng thông tối đa: 6 Gbps (~550 MB/s)
Độ trễ (latency): khoảng 100–200 µs
Dùng cho: HDD, SSD SATA 2.5", SSD M.2 SATA

2. PCI Express (PCIe)
Là chuẩn kết nối tốc độ cao nhất hiện nay (truyền dữ liệu trực tiếp đến CPU).
Dạng cắm: khe PCIe hoặc khe M.2. 

PCIe có các kích thước như X1, X4, X8 và X16, mỗi kích thước đại diện cho số lượng lane (đường truyền dữ liệu độc lập) được sử dụng trong giao tiếp.

Chuẩn NVMe (Non-Volatile Memory Express) được thiết kế riêng cho SSD chạy trên PCIe.
NVMe không chỉ nhanh ở tốc độ truyền mà còn ở độ trễ rất thấp (10–20 µs) nhờ giao tiếp trực tiếp với CPU qua bus PCIe.
PCIe 3.0~3.5 GB/s
PCIe 4.0~7.0 GB/s
PCIe 5.0~14.0 GB/s

Phân loại theo bộ nhớ (NAND Type)
Đây là yếu tố ảnh hưởng lớn nhất đến độ bền (TBW), tốc độ và giá thành của SSD.
Tất cả SSD hiện nay (trừ Intel Optane) đều dùng NAND Flash, lưu trữ dữ liệu bằng cách nạp điện tích vào transistor gọi là Floating Gate hoặc Charge Trap.

NAND là một Chip nhớ flash được tích hợp trong các thiết bị lưu trữ, với các loại NAND phổ biến là :

1. NAND SLC (Single-Level Cell)
NAND SLC là loại chip bộ nhớ flash đơn mức, có nghĩa là mỗi cell chỉ chứa một bit dữ liệu. Vì vậy, tốc độ đọc và ghi của NAND SLC cao hơn các loại NAND khác. Tuy nhiên, giá thành của NAND SLC lại rất đắt do chi phí sản xuất cao.

2. NAND MLC (Multi-Level Cell)
NAND MLC là một loại chip bộ nhớ flash đa mức, cho phép lưu trữ từ 2 đến 4 bit dữ liệu trên mỗi cell. Điều này có nghĩa là mỗi ô nhớ trên chip NAND MLC có thể lưu trữ nhiều hơn một bit thông tin. Vì vậy, NAND MLC giúp giảm chi phí sản xuất so với NAND SLC, loại chip chỉ lưu trữ một bit trên mỗi cell.

3. NAND TLC (Triple-Level Cell)
NAND TLC là một loại chip bộ nhớ flash ba mức, có nghĩa là mỗi ô nhớ trên chip này có thể lưu trữ từ 3 đến 4 bit dữ liệu. Mỗi ô nhớ trên NAND TLC có khả năng lưu trữ nhiều hơn so với NAND SLC hoặc MLC.

4. NAND 3D
NAND 3D là một loại NAND mới nhất trong công nghệ lưu trữ dữ liệu. Với NAND 3D, các cell được xếp chồng lên nhau để tạo ra một không gian lưu trữ dữ liệu lớn hơn. Điều này có nghĩa là NAND 3D có thể lưu trữ nhiều dữ liệu hơn trên một chip và tăng tốc độ truy xuất so với các loại NAND trước đó.

Trong quá trình sản xuất NAND 3D, các cell được xếp chồng lên nhau, tạo thành một cấu trúc ba chiều giúp tăng tối đa khả năng lưu trữ dữ liệu trên một chip. Ngoài ra, việc xếp chồng cell còn giúp tăng tốc độ truy xuất dữ liệu, do dữ liệu có thể được lưu trữ và truy xuất từ nhiều vị trí trên cùng một chip.

NAND 3D được coi là sự tiến bộ trong công nghệ lưu trữ dữ liệu, giúp cho các thiết bị được nhanh chóng lưu trữ và truy xuất dữ liệu một cách hiệu quả hơn. Chính vì thế, NAND 3D đang được sử dụng rộng rãi trong các thiết bị di động như smartphone và máy tính bảng, giúp cải thiện khả năng lưu trữ và truy xuất dữ liệu của chúng.
```

