### Một số lệnh hữu ích
```
setsid <task> > <file_logs> 2>&1 & : tạo 1 phiên chạy nền
ps aux | grep <name> : lọc phiên theo tên
kill -TERM <pid> : xóa phiên theo pid
tail -n <số dòng> <file>: xem 50 dòng cuối 1 file
tail -f <file> : theo dõi file
```