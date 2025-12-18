## Phân biệt Mode Boot
```
LEGACY (BIOS)
UEFI

Với chuẩn truyền thống HDD, SSD ta chạy BIOS + MBR
Với chuẩn mới SSD,NVME ta chạy UEFI + GPT

MBR : phân vùng boot nằm ở 512 byte đầu ổ đĩa, nếu mất sẽ mất boot
GPT : phân vùng boot được nhân bản, chống lỗi mất boot, có chơ chế lưu (CRC32 checksum) để hạn chế mất dữ liệu
```