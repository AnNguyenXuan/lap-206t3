## Hướng dẫn setup môi trường code cho C/C++
```
Truy cập trang web và cài đặt bộ công cụ
https://www.msys2.org/

Sau khi cài đặt thành công gõ lệnh
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain

Chọn all bằng cách enter rồi yes

Truy cập edit the system environment, mục environment variables -> mục user varialbes -> path
Tại đây thêm biến đường dẫn tới thư mục cài msys2\ucrt64\bin
Mở terminal : gcc --version

Sau đó, truy cập visual studio code, cài đặt extension C/C++
```
