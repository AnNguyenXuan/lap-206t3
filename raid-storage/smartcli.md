## Công cụ smartmontools
```
apt install -y smartmontools
smartctl -i /dev/sdc
smartctl -a /dev/sdc | egrep -i 'power|loss|cap|pli|pwr'
smartctl -x /dev/sdc | egrep -i 'power|loss|cap|pli|pwr'

# Để chắc ăn, chạy lệnh rồi tra firmware part number để tìm datasheet
smartctl -i /dev/sdc

# Tra datasheet xem có các cụm như: Power Loss Protection / PLP, Power Loss Data Protection, Holdup capacitors / power caps, Power Loss Imminent (PLI)
```