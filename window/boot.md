## Fix lỗi Boot trong Window
```
Truy cập Safe mode bằng các power on -> power off -> power on 2-3 lần để vào chế độ boot đặc biệt

Chọn F8 > chọn Safe mode

Boot vào safe mode, chạy CMD
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```

## Cách hạn chế lỗi khi build image
```
Truy cập C:\Windows\System32\Sysprep

Chạy file sysprep.exe

Chọn như sau
System Cleanup Action: Enter System Out-of-Box Experience (OOBE)
Tick: Generalize
Shutdown Options: Shutdown

```

## Cách boot vào recovery
```
Giữ phím Shift rồi bấm:
Start > Power > Restart

Choose an option > Troubleshoot > Advanced options > Command Prompt

diskpart
list vol

Ổ Windows: thường NTFS, dung lượng lớn
Phân vùng EFI: FAT32, khoảng 100–300MB
Tìm phân vùng EFI là volume mấy, chạy lệnh dưới

sel vol 3
assign letter=S
exit

Rebuild, sau đó restart
bcdboot C:\Windows /s S: /f UEFI
wpeutil reboot

```