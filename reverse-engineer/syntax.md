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

Kiến trúc của RAM

địa chỉ cao
   |
   v
-------------------
|   dữ liệu cũ     |
-------------------
|   dữ liệu cũ     |
-------------------
|   top of stack   |   <-- rsp
-------------------
|   free space     |
-------------------
|   free space     |
-------------------
địa chỉ thấp


Cách tính số hex sang bytes
Thực chất nó là từ hex sang thập phân
Muốn chuyển từ thập phân sang hex thì ta chia 16
Muốn chuyển từ hex sang thập phân thì nhân 16


Phân loại byte trong string
0A : byte xuống dòng, thường là dấu enter


Chip Intel
Tập lệnh điều khiển
je : jump if equal
jmp : jump (nhảy vô điều kiện)
cmp : so sánh 2 giá trị a,b
call : trỏ đến hàm thực thi của code được lưu tại địa chỉ nào trên thanh ghi
lea : Load Effective Address (Tính địa chỉ thanh ghi rồi gán)
mov : dùng để gán giá trị nào đó vào thanh ghi
sub : dùng để trừ (sub a,b -> a = a - b), ngoài ra khi sub rsp, 32 thì ta có thể hiểu là giảm con trỏ rsp xuống 32 bytes trong stack (VD nếu ta có int *p = arr + 5 thì nếu p = p - 2 tức là sub p, 8 do int có 4 bytes)
add : dùng để cộng

Giá trị các thanh ghi
rsp là thanh ghi con trỏ trên x64, nó sẽ được dùng để đánh dấu gốc (base) của khung stack của một hàm
rbp là Base Pointer (còn gọi là Frame Pointer) trong kiến trúc x86-64 được dùng để giữ một “điểm cố định” trong stack frame,
để truy cập tham số và biến local một cách ổn định.
rip là Instruction Pointer, là địa chỉ trong bộ nhớ của lệnh kế tiếp sẽ bị CPU giải mã và chạy

rdi là 

rax là thanh ghi tham số trả về
RAX  (64 bit)
└─ EAX (32 bit)
   └─ AX (16 bit)
      ├─ AH (8 bit cao)
      └─ AL (8 bit thấp)

rbx là thanh ghi tham số tạm, tức là than số được giữ tạm trong quá trình tính toán

rcx là thanh ghi tham số truyền
RCX  (64 bit)
└─ ECX  (32 bit –  thấp của RCX)
   └─ CX (16 bit)
      ├─ CH (8 bit cao)
      └─ CL (8 bit thấp)

rdx là thanh ghi tham số truyền 
RDX  (64 bit)
└─ EDX (32 bit)
   └─ DX (16 bit)
      ├─ DH (8 bit cao)
      └─ DL (8 bit thấp)
Thứ tự thanh ghi tham số truyền RCX, RDX, R8, R9




push rbp        ; lưu giá trị rbp cũ vào stack
mov rbp, rsp    ; đặt rbp = rsp (đánh dấu đầu khung stack mới)

Từ đây, mọi biến cục bộ, tham số... đều được truy cập theo độ lệch so với rbp, ví dụ:

Khi hàm kết thúc:

pop rbp
ret

phục hồi giá trị rbp cũ, trả stack về trạng thái trước khi hàm được gọi
```