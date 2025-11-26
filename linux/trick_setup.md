## Một số setup mẹo với hệ thống

### Tắt tiếng beep khi ấn tab
```
1. Dùng cho 1 profile duy nhất
nano ~/.inputrc
set bell-style none
bind -f ~/.inputrc

2. Dùng cho toàn bộ hệ thống
nano /etc/inputrc
set bell-style none
```

### Clear cấu hình ổ đĩa
```
sgdisk --zap-all /dev/sdb
sgdisk --zap-all /dev/sdc
sgdisk --zap-all /dev/sdd
wipefs -a /dev/sdb
wipefs -a /dev/sdc
wipefs -a /dev/sdd
```

### Kiểm tra inodes
```
Một hệ thống file trong Linux được chia làm hai phần, đó là phần khối dữ liệu (data block) và phần inode. Phần block thì được cố định và không thể thay đổi, còn phần inode thì bạn có thể thay đổi được


```

### Cấu hình custom jobs định kỳ
```
Logrotate giúp tự động xoay vòng (rotate), nén, hoặc xóa log theo thời gian.
/etc/logrotate.d/custom


Thiết lập cron job.
crontab -e
```

