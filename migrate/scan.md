## Lệnh quản trị phần cứng
```
for host in /sys/class/scsi_host/host*; do
    echo "- - -" > "$host/scan"
done

lspci -nn | grep -i -E 'raid|sas|sata|smart|perc|lsi|megaraid|mpt|pqi|adaptec|areca'
lspci -nnk | grep -A3 -i -E 'raid|sas|smart|perc|lsi|megaraid|mpt|pqi|adaptec|areca'
lsmod | grep -E 'megaraid_sas|mpt3sas|hpsa|smartpqi|aacraid|aic94xx|isci'
dmesg | grep -i -E 'megaraid|mpt3sas|hpsa|smartpqi|aacraid|scsi|raid'
modinfo megaraid_sas | grep version
uname -r
lspci -nn | grep -i raid
uname -r

JBOD là viết tắt của “Just a Bunch Of Disks” — nghĩa là từng ổ đĩa vật lý được xuất hiện riêng lẻ ra hệ điều hành, không gộp lại thành mảng RAID.

# Cài đặt công cụ quản lý raid của Broadcom / LSI
# storcli hỗ trợ tất cả các loại LSI MegaRAID SAS (SAS2–SAS4)
# Lên trang chủ cài đặt file zip

# Với lệnh cài đặt
sudo dpkg -i storcli_1.21.12-2_all.deb

# Với lệnh update
dpkg -i ./storcli_007.3503.0000.0000_all.deb

# Nạp vào môi trường
sudo chmod +x /opt/MegaRAID/storcli/storcli64
sudo ln -s /opt/MegaRAID/storcli/storcli64 /usr/local/bin/storcli
hash -r
storcli show

# Bộ lệnh
storcli /c0 show all : Xem thông tin chi tiết trạng thái
storcli /c0 /fall show : Xem danh sách cấu hình của key cũ
storcli /c0 /eall /sall show : Xem danh sách mọi ổ với EID:slot
storcli /c0 /fall delete

# (tùy fw) bật quyền JBOD toàn cục
storcli /c0 set jbod=on || storcli /c0 set allowjbod=on

# Chuyển từng ổ sang JBOD
storcli /c0 /eall /sall set good
storcli /c0 /eall /sall set jbod
storcli /c0 /e<id> /s<id> set jbod

# Format trắng lại ổ đĩa
sgdisk --zap-all /dev/sda
sgdisk -o /dev/sda

# Tạo GPT mới
sudo parted -s /dev/sda mklabel gpt
sudo parted -s /dev/sda mkpart primary ext4 1MiB 1GiB
sudo parted -s /dev/sda mkpart primary 1GiB 101GiB
```