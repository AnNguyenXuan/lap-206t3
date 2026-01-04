# Gia hạn SSL trả phí


# Nhớ lưu backup file SSL trước khi thực hiện

https://backup.hostingviet.com.vn/s/RGRXoXwfsxfAKiG

## **1. Mua SSL Windows xuống 2.3**

Truy cập vào: [https://www.gogetssl.com/ssl-certificates/](https://www.gogetssl.com/ssl-certificates/)

Thông tin đăng nhập:

thunn84@gmail.com
ZZFAec7ZXDrdcx

Chọn gói theo yêu cầu, ví dụ SSL 1 năm

![](images/9.png)

Sau khi order vào SSL Certificates -> View Incompleted:
![](images/10.png)

Chọn Generate Certificate

![](images/11.png)

Mở một tab mới Vào CSR Generator


![](images/12.png)

Giao diện như sau

![](images/1.png)

Nhập Common name là web của KH.

![](images/2.png)

Sau khi generate sẽ có 2 key, private và public key

![](images/3.png)

Vào SSL Generation. Copy public key vào rồi validate

![](images/13.png)

![](images/4.png)

Đến đây, xem loại SSL cần cài cho bước 2.
## **2. Cài SSL cho từng dịch vụ**

### **2.1 Cài SSL cho HTTPS DirectAdmin Linux**

Chọn HTTPS

![](images/14.png)

Sau khi validate chọn next step và điền thông tin của IT support

![](images/5.png)

![](images/6.png)

Chọn complete generation -> Tải lại trang, nếu chưa được, đợi một lát.
Sẽ nhìn thấy giao diện như hình.

![](images/7.png)

Tiếp vào domain validation, tải các file cần thiết xuống bằng cách chọn validation file

![](images/8.png)

Làm theo hướng dẫn copy các file theo đường dẫn theo mũi tên ở dưới.

Đối với host linux , DirectAdmin/CPanel

Tìm kiếm khách hàng để đăng nhập vào DirectAdmin/CPanel

![](images/15.png)

Chọn domain mà mình đang muốn cài SSL

![](images/16.png)

Chọn file manager, đi đến đường dẫn: `/domains/<ten mien can cai>/public_html/.well-know`

![](images/17.png)

Copy file vào `pki-validation`

![](images/19.png)

Quay trở lại trang mua ssl, chọn resend/validate

![](images/18.png)

Chọn vào detail, reload lại và check xem được chưa

![](images/20.png)

Chọn tiếp vào All Files để tải file về.

Giải nén ra sẽ như sau:

![](images/21.png)

Copy private key vào file ở cuối cùng và sửa tên file cho dễ nhận dạng sau này

![](images/22.png)

Tiếp theo tại trang panel, từ Advance -> SSL certificates

![](images/23.png)

Copy key của 2 file này dán lần lượt vào

![](images/24.png)

Phải đúng định dạng ngăn cách như này

![](images/25.png)

Sau đó save và quay lại `Advance > SSL certificates > Click Here`

![](images/26.png)

Lấy nội dung các file được đánh dấu như hình

![](images/27.png)

Dán nội dung key của 2 file key này lần lượt như trên -> Lưu lại.

Truy cập vào web và check lại

![](images/28.png)


### **2.2 Cài SSL cho DNS**

Để ý khi ta vào trong thư mục `public_html` không có source code của web hoặc check host hoặc tìm kiếm dịch vụ ra dns.

Đăng nhập vào trang: https://dns.hostingviet.vn/dns

Thông tin đăng nhập tìm lại trong dịch vụ DNS

![[images/29.png]]

Thêm bản ghi mới

![[images/30.png]]

Tại DNS validation ở trang mua SSL, copy lần lượt "host" (đỏ, trước dấu chấm) và "Giá trị" (xanh). "Loại" để thành CNAME

![[images/31.png]]

Lưu lại và quay lại đợi cho đến khi validate thành công

![[images/32.png]]

![[images/33.png]]

Tiếp tục chọn All files để tải file SSL về

![[images/34.png]]

Tương tự dán private key vào một `! PRIVATE KEY INFO...` và đổi tên thành `private-key` cho dễ thao tác.

![[images/35.png]]

Tiến hành cài thủ công trên VPS linux.


### 2.3 Cài SSL cho HTTPS Windows

Vào IIS -> Server Certificate

![[images/36.png]]

Chọn Create Certificate request

![[images/37.png]]

Nhập thông tin

![[images/38.png]]

![[images/39.png]]

Tạo file để lưu key

![[images/40.png]]

![[images/41.png]]

Copy sang GOGETSSL -> Validate

![[images/43.png]]

Chọn DNS -> Next

![[images/42.png]]

Check xem domain có trỏ về dns của mình không nếu không liên hệ khách hàng thêm bản ghi.

Nếu có thêm bản ghi tương tự như 2.2

![](images/44.png)

Đợi như này là được

![[images/45.png]]

Chọn All files -> Download về

![[images/46.png]]

Cuối cùng vào lại Server -> Complete Certificate Request

![[images/47.png]] 

Chọn file .crt

![[images/48.png]]

Đặt tên cho dễ thao tác

![[images/49.png]]

Vào website cần cài SSL -> Bindings...  -> Chọn port 443 -> Chọn chứng chỉ SSL mới.

![[images/50.png]]

### 2.4 Cài SSL cho Plesk

