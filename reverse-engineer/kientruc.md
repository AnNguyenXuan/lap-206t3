## Công cụ
```
Tools IDA, Ghidra

https://github.com/ReversingID/Awesome-Reversing
```
## Lộ trình
```
### 🧱 1. Hiểu “máy tính thực sự chạy gì”

Mục tiêu: hiểu quy trình từ mã nguồn → mã máy.

* Viết 1 chương trình C hoặc Python cực ngắn, rồi biên dịch nó (`gcc -S hello.c -o hello.s`) để xem file `.s` là **assembly**.
* Thấy rằng: mỗi lệnh cấp cao (như `print("hi")`) biến thành hàng loạt chỉ thị rất cụ thể (mov, call, push, ret…).

> 👉 Gợi ý: học cách đọc vài dòng assembly thôi, ví dụ:
> `mov eax, 1` = đưa giá trị 1 vào thanh ghi `eax`.

---

### 🧩 2. Làm quen assembly (ở mức đọc hiểu)

* Học sơ qua **registers**, **stack**, **calling convention** (ai truyền tham số cho ai).
* Chỉ cần hiểu logic: “nó lấy dữ liệu ở đâu – xử lý thế nào – trả về ở đâu”.
* Dễ học nhất: xem song song C và assembly (`objdump -d hello.o` để xem disassembly).

> 📚 Gợi ý: “x86 Assembly Crash Course” của OpenSecurityTraining hay “Godbolt Compiler Explorer” — bạn nhập code C và xem assembly tương ứng ngay trên web.

---

### 🔍 3. Quan sát thay vì giải mã

Đừng cố dịch ngược hẳn một chương trình thật ngay.
Hãy **xem** nó hoạt động:

* Dùng **Procmon** (Windows) hoặc `strace` (Linux) để xem chương trình đọc/ghi file nào, gọi API gì.
* Dùng **GDB** hoặc **x64dbg** để đặt breakpoint và quan sát biến thay đổi.

Tư duy lúc này: *“Chương trình đang làm gì?”* chứ không phải *“Nó viết ra sao?”*

---

### 🧠 4. Học hiểu cấu trúc file thực thi

Khi bạn biết một file `.exe` hay `.elf` có **section code (.text)**, **data (.data)**, **import (.plt/.got)** — bạn sẽ đọc được 80% log khi RE.

* Công cụ: `readelf`, `objdump`, hoặc **PE-bear / PEview**.
* Thực hành: so sánh 2 bản build cùng code, khác compiler flag (`-O0` và `-O2`).

---

### ⚙️ 5. Dụng cụ học thân thiện

* **Ghidra** (miễn phí): giao diện rõ, có decompiler song song assembly.
* **IDA Free** (bản nhỏ).
* **Cutter** (GUI của radare2).

Tập mở file `.exe` nhỏ tự build, đọc xem decompiler cho ra gì — rename, comment, thử hiểu luồng.
```