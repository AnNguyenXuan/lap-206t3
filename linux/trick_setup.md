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

