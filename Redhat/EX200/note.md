## Khóa RHCSA cho Linux Administrator

### SELinux
```
DAC (Discretionary Access Control) là cơ chế phân quyền truyền thống của Linux, trong đó chủ sở hữu tự quyết định ai được truy cập tài nguyên của mình.
Dựa trên : UID, GID, rwx, ACL -> Mặc định : Quyền tùy theo mode bit, ACL, umask -> Chủ yếu là đọc, ghi, thực thi


MAC (Mandatory Access Control) của SELinux thì áp dụng policy chung của hệ thống. Process và chủ sở hữu file không tự ý vượt qua được policy này.
Dựa trên : Security context (label) user:role:type:level -> Mặc định : Không có rule allow thì bị từ chối -> Rất chi tiết: open, append, name_bind, name_connect

Cách 2 cơ chế phối hợp
SELinux không thay thế DAC mà bổ sung thêm một lớp. Kernel thường kiểm tra DAC trước:
DAC từ chối thì bị chặn luôn, SELinux không cần xét.
DAC cho phép thì SELinux xét tiếp.

Để xem quyền MAC trên Linux
Với folder ls -ldZ
Với file ls -lZ
Với Process ps -AfZ

Các mode SELinux : 
Enforcing : Kích hoạt -> Chặn truy cập vi phạm -> Ghi AVC log -> Mode production
Permissive : Kích hoạt -> Không chặn Chặn truy cập vi phạm -> Ghi AVC log -> Mode debug
Disabled : Kích hoạt -> Không chặn Chặn truy cập vi phạm -> Không Ghi AVC log -> SELinux tắt, không áp dụng policy
Để xem mode đang sử dụng :
getenforce
sestatus 
Để đổi mode trong runtime :
setenforce 0
setenforce 1
Thư mục cấu hình /etc/selinux/config
```

## Boot Process & Change Root Pass
```
Cơ chế boot
1. BIOS/UEFI   Khởi tạo phần cứng, chọn thiết bị boot
      ▼
2. GRUB2       Nạp kernel và initramfs, truyền tham số kernel
      ▼
3. Kernel      Khởi tạo, giải nén initramfs vào RAM
      ▼
4. initramfs   Nạp driver, mở LUKS, kích hoạt LVM,
      │        mount root thật vào /sysroot
      │  ◄──── rd.break dừng ở đây
      ▼
5. switch_root Chuyển / sang root thật
      ▼
6. init thật   Mặc định là systemd: nạp SELinux policy,
      │        khởi động dịch vụ, hiện màn hình đăng nhập
      └──◄──── init=/bin/bash thay systemd bằng bash

Cách đổi pass root 
Với Redhat 9
1. Vào giao diện Grub nhấn e
2. Cuối dòng Linux nhập rd.break
3. Nhấn Ctrl + X để boot
4. mount -o remount,rw /sysroot
5. chroot /sysroot
6. passwd root
7. touch /.autorelabel
8. exit & exit

Với Redhat 10
1. Vào giao diện Grub nhấn e
2. Cuối dòng Linux nhập init=/bin/bash
3. Nhấn Ctrl + X để boot
4. mount -o remount,rw /
5. passwd root
6. touch /.autorelabel
7. exec /sbin/init

Systemd : Pid 1 được khởi chạy sau khi hệ thống boot kernal thành công
Cả 2 phương thức này đều ngăn Systemd khởi động, do đó các tiến trình xác thực như login, PAM đều chưa được load
```

## Managing Software
```
DNF là trình quản trị package thay thế YUM cũ, hỗ trợ từ RHEL 8, chạy mặc định từ RHEL 9, 10. Phân phối 2 loại repo chính
1. BaseOS : chứa RPM package cung cấp dịch vụ lớp OS
2. AppStream : chứa các package chạy ở lớp người dùng

Application Stream là các thành phần phần mềm, có 3 dạng
RPM : Gói truyền thống, File được cài vào các vị trí chuẩn như /usr/bin và /usr/lib64. Các thư viện phụ thuộc thường được dùng chung trong hệ thống.
SCL : Vẫn dùng gói RPM, nhưng cài vào khu vực riêng, thường là /opt/rh/. Nhờ vậy một phiên bản khác có thể tồn tại song song với bản mặc định.
    sudo dnf install gcc-toolset-N
    scl enable gcc-toolset-N bash   # mở shell dùng bản này
    gcc --version
    exit                            # quay về môi trường cũ
Flatpak : Thường dùng cho ứng dụng desktop có giao diện. Ứng dụng chạy trong sandbox và dùng một runtime (bộ thư viện nền) tách khỏi thư viện của hệ thống. Mức cách ly phụ thuộc vào quyền cấp cho từng ứng dụng.
    flatpak remotes                 # các nguồn đã cấu hình
    flatpak remote-ls <tên-remote>  # ứng dụng có trong nguồn
    flatpak install <tên-remote> <app-id>
    flatpak run <app-id>

Lớp module bị loại bỏ trên RHEL 10 mà được phát hành dưới dạng RPM thường hoặc Software Collection, với Ứng dụng desktop có Flatpak
Ví dụ với RHEL 8,9:
    dnf module list
    sudo dnf module install nodejs:<stream>
Tuy nhiên với RHEL 10:
    dnf list 'nodejs*'
    sudo dnf install <tên-gói>

Đăng ký repo RHEL 10
subscription-manager register
subscription-manager repos --list-enabled

Local DNF Repo
Mount ISO DVD vào hệ thống

```