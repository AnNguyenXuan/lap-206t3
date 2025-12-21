## Cấu hình tham số cho special work
```
Cấu trúc :
<work type="init|prepare|cleanup|dispose|delay" workers="<number>" 
config="<key>=<value>;<key>=<value>" /> 

workers : số kết nối song song đồng thời

Với init (chuẩn bị bucket)
Thuộc tính :
containers : Xác định tập container (bucket) mà COSBench sẽ dùng để tạo object hoặc truy xuất object trong stage đó
có 4 tham số khả dĩ : 
c(1) Chọn container chỉ số 1
r(1,100) Chọn range từ 1 đến 100 container (tạo thành container1–container100)
u(1,50)	Chọn uniform random 1–50 container (mỗi worker pick random)
s(1,10)	Chọn sequential 1–10 container (chọn tuần tự)

Với prepare (chuẩn bị dữ liệu)
Thuộc tính :
containers : giống init
object : xác định tập object, có 4 lựa chọn c,r,u,s
sizes : kích thước mỗi object, có 4 lựa chọn c (constant),u (uniform random),s (sequential),h (histogram)
chunked : set true (false), COSBench sẽ upload object theo nhiều phần (multi-part/chunk) — cụ thể là chia object thành các phần nhỏ và upload từng phần.
content : Values: "random" (default) | "zero", xác định kiểu nội dung trong object
hashCheck : set true (false), đảm bảo dữ liệu upload không bị corruption, dùng cho quality test

Với cleanup (dọn các đối tượng đã tạo)
Thuộc tính :
containers : giống prepare
objects : giống prepare
deleteContainer : set true (false), COSBench sẽ xóa luôn container (bucket) sau khi xóa object trong bước cleanup

Với dispose (xóa cuối)
Thuộc tính :
containers : giống prepare

Với delay (chờ)
Thuộc tính :
closuredelay : chờ bao nhiêu giây
```

## Cấu hình tham số cho main work
```
Cấu trúc :
<work name="main" type="normal" workers="128" interval="5" division="none" runtime="60" 
rampup="0" rampdown="0" totalOps="0" totalBytes="0" afr=”200000” config="" > . . . </work> 

Thuộc tính :
name : tên
type : loại
workers : số lượng workers thread chạy song song
interval : khoảng thời gian giữa các lần thống kê
division : [“none”| “container”| “object”] : container (=bucket), object (=file)
runtime : chạy bao lâu
rampup : thời gian tăng đến bắt đầu
rampdown : thời gian giảm đến kết thúc
totalOps : tổng số operations (các request read/write), giá trị nên là bội số của workers để chia đều cho các worker
totalBytes : tổng bytes sẽ được truyền qua trong work này, nên là bội số của (workers × size)
driver : chỉ định driver nào chạy task
afr : tỉ lệ lỗi hợp lệ, tính theo phần triệu (0-1000000)
```

## Cấu hình tham số cho vận hành (Operation)
```
Cấu trúc :
<operation type="read|write|delete" ratio="<1-100>" 
config="<key>=<value>;<key>=<value>" />

Thuộc tính :
type : kiểu
ratio : tỉ lệ giữa các operation
config : cấu hình theo type

Phân loại config
read : containers;objects;hashCheck
write : containers;objects;sizes((B/KB/MB/GB));chunked;content;hashCheck
filewrite : containers;fileselection;files;chunked;hashCheck
delete : containers;objects
list : containers;objects
```

