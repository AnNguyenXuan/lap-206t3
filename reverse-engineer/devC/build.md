
| Mục tiêu          | Lệnh                      | Kết quả                        |
| ----------------- | ------------------------- | ------------------------------ |
| Tạo file thực thi | `gcc test.c -o test.exe`  | File chạy được                 |
| Tạo object file   | `gcc -c test.c -o test.obj` | Mã máy nhị phân, chưa liên kết |
| Tạo mã Assembly   | `gcc -S test.c -o test.s` | File assembly dễ đọc           |
| Xem mã máy        | `objdump -d test.exe`     | Mã máy và lệnh disassembly     |

Biên dịch byte code : objdump -d test.exe
Lưu ý : File .o với linux

Mã máy Intel : 
gcc -S -masm=intel test.c
gcc -m64 -S -masm=intel test.c
---
Quy trình biên dịch từ file .c về .exe

1. Preprocessing (Tiền xử lý)

- Chuyển đổi các biến, thư viện thành mã nguồn hoàn chỉnh #include, #define, #if,..
- Công cụ: preprocessor (cpp)

2. Compilation (Biên dịch sang Assembly)

- Chuyển logic C thành Assembly (mã cho CPU, dạng người đọc được).
- Công cụ: compiler proper (bộ phân tích từ vựng, cú pháp, sinh mã trung gian, rồi thành Assembly)

3. Assembly (Dịch sang mã máy thô)

- Tạo object file .o — chứa mã máy chưa liên kết, cùng bảng symbol và relocation
- Công cụ: assembler (as)

4. Linking (Liên kết)

- Gộp tất cả .o (và thư viện như libc.a) thành một file hoàn chỉnh.
- Giải quyết các symbol undefined (printf, malloc, …).
- Tạo entry point (_start) và header cho OS (ELF hoặc PE).
- Công cụ: linker (ld, do gcc gọi ngầm).