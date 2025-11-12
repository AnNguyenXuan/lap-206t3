## Kiến thức về assembly
```
Phân loại byte trong string
0A : byte xuống dòng, thường là dấu enter

Tập lệnh điều khiển
je : jump if equal
jmp : jump (nhảy vô điều kiện)
cmp : 

Giá trị các thanh ghi
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