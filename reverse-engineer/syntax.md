## Kiến thức về assembly
```
Cấu trúc stack
Nguyên lý hoạt động : last in first out (vào cuối ra đầu)
push: Thêm phần tử vào cuối stack
pop: Loại bỏ phần tử cuối stack

StackBase (địa chỉ cao)
   |
   v   (push)
  [-----]  <-- rsp giảm
  [-----]
   ...
StackLimit (địa chỉ thấp)

Cách tính số hex sang bytes
Thực chất nó là từ hex sang thập phân
Muốn chuyển từ thập phân sang hex thì ta chia 16
Muốn chuyển từ hex sang thập phân thì nhân 16


Phân loại byte trong string
0A : byte xuống dòng, thường là dấu enter

Tập lệnh điều khiển
je : jump if equal
jmp : jump (nhảy vô điều kiện)
cmp : 
call : trỏ đến hàm thực thi của code được lưu tại địa chỉ nào trên thanh ghi
lea : Load Effective Address (Tính địa chỉ thanh ghi rồi gán)

Giá trị các thanh ghi
rsb là thanh ghi con trỏ trên x64, nó sẽ trỏ tới 
rbp là Base Pointer (còn gọi là Frame Pointer) trong kiến trúc x86-64.
Nó được dùng để đánh dấu gốc (base) của khung stack của một hàm.

push rbp        ; lưu giá trị rbp cũ vào stack
mov rbp, rsp    ; đặt rbp = rsp (đánh dấu đầu khung stack mới)

Từ đây, mọi biến cục bộ, tham số... đều được truy cập theo độ lệch so với rbp, ví dụ:

Khi hàm kết thúc:

pop rbp
ret

phục hồi giá trị rbp cũ, trả stack về trạng thái trước khi hàm được gọi
```