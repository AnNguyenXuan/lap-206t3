## Ceph storage API

### Phân loại 

Ceph có 2 cấp bậc API phục vụ các vai trò khác nhau

1. S3 API : Dùng cho enduser khi kết nối đến endpoint Ceph

a) Kiểu kết nối đến endpoint Ceph
```
- Kiểu đường dẫn thư mục
GET /mybucket HTTP/1.1
Host: cname.domain.com

- Kiểu đường dẫn domain ảo
GET / HTTP/1.1
Host: mybucket.cname.domain.com

- Có thể cấu hình cname.domain.com với tham số rgw_dns_name 
- Hiện nay AWS thường sử dụng dạng domain ảo
```

b) Các Request Header Client -> Server
```
CONTENT_LENGTH : Kích thước gói tin
DATE : Thời gian
HOST : Endpoint Ceph
AUTHORIZATION : Token xác thực
```

c) AUTHORIZATION
```
Các request lên RGW có thể được xác thực hoặc không xác thực. RGW hiểu các yêu cầu không xác thực là ẩn danh.

Khóa "AWS Signature v4" hoặc "AWS Signature v2" được tạo ra bằng access key và secret key từ người dùng đăng nhập. Thông thường các ứng dụng S3 và AWS SDKs sẽ tự tạo khóa bằng các thông tin mà ta cấp cho khách hàng. 

Lưu ý : Nếu muốn tích hợp vào hệ thống thì ERP nội bộ thì ta cần code chức năng tạo khóa ký để giao tiếp với RGW và khách hàng có thể quản trị dịch vụ trên website. 
```

d) Access Control Lists (ACLs)
RGW phân quyền cho user theo danh sách dưới đây 
```
READ : Bucket (hiển thị danh sách Object), Object (hiển thị nội dung Object)
WRITE : Bucket (có quyền ghi hoặc xóa Object trong Bucket), Object (không có quyền)
READ_ACP : Bucket (có quyền đọc ACL Bucket), Object (có quyền đọc ACL Object)
WRITE_ACP : Bucket (có quyền ghi ACL Bucket), Object (có quyền ghi ACL Object)
FULL_CONTROL : (có full quyền trên)

Các quyền này được MAP thành bảng danh sách theo IAM policy, có thể đọc link dưới đây để biết thêm chi tiết

https://docs.ceph.com/en/latest/radosgw/s3/authentication/
```

e) Danh sách các API cho user
```
Quy ước trong tài liệu chính thức của Ceph viết cấu trúc Response có dạng xml, ví dụ được thể hiện như dưới

- Kiểm tra danh sách bucket 
Request :
GET / HTTP/1.1
Host: cname.domain.com
Authorization: AWS {access-key}:{hash-of-header-and-secret}

Response :
<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Owner>
    <ID>user id</ID>
    <DisplayName>tên hiển thị</DisplayName>
  </Owner>
  <Buckets>
    <Bucket>
      <Name>tên bucket</Name>
      <CreationDate>ngày tạo</CreationDate>
    </Bucket>
    <Bucket>
      <Name>tên bucket</Name>
      <CreationDate>ngày tạo</CreationDate>
    </Bucket>
  </Buckets>
</ListAllMyBucketsResult>

- Lấy thông tin trạng thái bucket
Request :
GET /?usage HTTP/1.1
Host: cname.domain.com
Authorization: AWS {access-key}:{hash-of-header-and-secret}

Response :
<Summary>
  <TotalBytes>dung lượng sử dụng</TotalBytes>
  <TotalBytesRounded>dung lượng sử dụng làm tròn theo block 4k</TotalBytesRounded>
  <TotalEntries>số lượng object</TotalEntries>
</Summary>

- Tạo mới bucket
Request :
PUT /{bucket} HTTP/1.1
Host: cname.domain.com
Parameters : 
Authorization: AWS {access-key}:{hash-of-header-and-secret}

Parameters :
x-amz-acl : Đặt quyền bucket (private, public-read, public-read-write, authenticated-read)
x-amz-bucket-object-lock-enabled : Bật khóa object (true, false)
x-amz-object-ownership : Đặt quyền sở hữu object khi đẩy lên bucket, có 3 quyền là (BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter)

Response :
<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <LocationConstraint>Zonegroup chứa bucket</LocationConstraint>
</CreateBucketConfiguration>

HTTP Response :
409 : Bucket đã tồn tại

- Xóa bucket
Request :
DELETE /{bucket} HTTP/1.1
Host: cname.domain.com
Authorization: AWS {access-key}:{hash-of-header-and-secret}

HTTP Response :
204 : Bucket đã được xóa

- Lấy danh sách dữ liệu bucket
Request :
GET /{bucket}?max-keys=25 HTTP/1.1
Host: cname.domain.com

```

2. Admin Ops API : Dùng cho admin/root, có quyền quản trị hoàn toàn hệ thống Ceph