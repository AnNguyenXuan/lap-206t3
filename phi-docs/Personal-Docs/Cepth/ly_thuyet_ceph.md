## 1. Giới thiệu tổng quan về CEPH

**CEPH** là một nền tảng lưu trữ phần mềm định nghĩa (software-defined storage) mã nguồn mở, được thiết kế để cung cấp **khả năng mở rộng vô hạn**, **độ tin cậy cao** và **hiệu suất ấn tượng**. CEPH ra đời từ năm 2005 như một dự án mùa hè và đã phát triển thành giải pháp lưu trữ được sử dụng rộng rãi trong các doanh nghiệp lớn như DigitalOcean, OVH và thậm chí cả CERN - tổ chức nghiên cứu vật lý hạt nhân lớn nhất thế giới.

**Điểm đặc biệt** của CEPH là khả năng cung cấp **ba giao diện lưu trữ** trong một hệ thống thống nhất: **lưu trữ đối tượng (object)**, **lưu trữ khối (block)** và **hệ thống tệp (file)**6. Kiến trúc phân tán của CEPH cho phép nó chạy trên phần cứng thông thường mà không cần các thiết bị đặc biệt, giúp giảm đáng kể chi phí triển khai và vận hành.

## 2. Kiến trúc và các thành phần cơ bản

### 2.1 Thành phần chính trong cụm CEPH

CEPH được xây dựng dựa trên nền tảng **RADOS** (Reliable Autonomic Distributed Object Store) - một dịch vụ lưu trữ đối tượng phân tán đáng tin cậy. Một cụm CEPH hoàn chỉnh bao gồm các thành phần daemon sau:

| **Thành phần**    | **Ký hiệu** | **Chức năng chính**       | **Vai trò**                                                        |
| ----------------- | ----------- | ------------------------- | ------------------------------------------------------------------ |
| **Ceph Monitor**  | ceph-mon    | Theo dõi trạng thái cụm   | Duy trì bản đồ cụm (cluster map) và đảm bảo tính nhất quán         |
| **Ceph Manager**  | ceph-mgr    | Quản lý và giám sát       | Cung cấp monitoring, orchestration, và giao diện web dashboard     |
| **Ceph OSD**      | ceph-osd    | Lưu trữ dữ liệu thực tế   | Quản lý việc đọc/ghi dữ liệu và nhân bản trên các thiết bị lưu trữ |
| **Ceph MDS**      | ceph-mds    | Quản lý metadata          | Phục vụ metadata cho CephFS (chỉ cần thiết khi sử dụng CephFS)     |
| **RADOS Gateway** | ceph-rgw    | Cung cấp giao diện object | Cung cấp API RESTful tương thích với S3/Swift9                     |

### 2.2 Các khái niệm quan trọng trong CEPH

- **RADOS (Reliable Autonomic Distributed Object Store)**: Là lớp lưu trữ đối tượng phân tán đáng tin cậy, tạo nên nền tảng của toàn bộ hệ thống CEPH. Tất cả dữ liệu trong CEPH đều được lưu trữ dưới dạng đối tượng trong RADOS.
    
- **CRUSH (Controlled Replication Under Scalable Hashing)**: Thuật toán độc đáo giúp CEPH phân phối dữ liệu một cách linh hoạt và hiệu quả trong cụm. CRUSH cho phép clients tính toán vị trí lưu trữ dữ liệu mà không cần tra cứu tập trung, loại bỏ điểm nghẽn trong kiến trúc phân tán.
    
- **Pool**: Là vùng lưu trữ logic cho dữ liệu. Mỗi pool có thể được cấu hình với các chính sách nhân bản (replication) hoặc mã xóa (erasure coding) riêng. Các đối tượng được lưu trữ trong các pool này.
    
- **Placement Groups (PGs)**: Là thành phần của pool giúp phân phối dữ liệu trong cụm. PGs đóng vai trò trung gian giữa objects và OSDs, giúp việc quản lý dữ liệu phân tán hiệu quả hơn.
    

## 3. Cơ chế hoạt động của CEPH

### 3.1 Nguyên lý lưu trữ và truy xuất dữ liệu

CEPH hoạt động dựa trên nguyên tắc **phi tập trung hoàn toàn**. Khác với các hệ thống lưu trữ truyền thống có điểm truy cập tập trung (gateway, broker), CEPH cho phép **client tương tác trực tiếp** với các OSD để đọc/ghi dữ liệu6.

**Quy trình ghi dữ liệu**:

1. Client liên hệ với Ceph Monitor để lấy **bản đồ cụm (cluster map)** mới nhất
    
2. Client cung cấp tên object và tên pool cho `librados`
    
3. `librados` sử dụng thuật toán CRUSH để tính toán Placement Group và OSD chính cho việc lưu trữ
    
4. Client kết nối trực tiếp đến OSD chính để thực hiện thao tác ghi
    
5. OSD chính chịu trách nhiệm nhân bản dữ liệu đến các OSD thứ cấp
    

**Quy trình đọc dữ liệu**:

1. Client tính toán vị trí object sử dụng thuật toán CRUSH
    
2. Client kết nối trực tiếp đến OSD lưu trữ object đó
    
3. OSD trả về dữ liệu cho client mà không cần thông qua trung gian
    

### 3.2 Cơ chế đồng thuận và tính nhất quán

CEPH sử dụng **cơ chế đồng thuận Paxos** giữa các Monitor để đảm bảo tính nhất quán của thông tin cụm. Số lượng Monitor nên là số lẻ (3, 5, 7) để đạt được **quorum** (ít nhất (n/2 + 1) Monitor hoạt động)6.

Đối với xác thực, CEPH sử dụng **cephx** - hệ thống xác thực dựa trên khóa chia sẻ, hoạt động tương tự như Kerberos nhưng không có điểm tập trung, cho phép client xác thực trực tiếp với OSD sau khi nhận "ticket" từ Monitor.

## 4. Các giao diện lưu trữ của CEPH

### 4.1 RADOS Block Device (RBD)

Cung cấp **lưu trữ khối** có khả năng **nhân bản** và **snapshot**. RBD ánh xạ một thiết bị khối ảo thành một loạt các objects được phân phối trên cụm lưu trữ. RBD thường được sử dụng để cung cấp storage cho máy ảo trong OpenStack/KVM.

### 4.2 Ceph File System (CephFS)

Là **hệ thống file POSIX-compliant** được xây dựng trên RADOS. CephFS sử dụng **Metadata Server (MDS)** để quản lý metadata (thông tin thư mục, quyền truy cập) trong khi dữ liệu file được lưu trữ trực tiếp trong RADOS. CephFS phù hợp cho các use-case truyền thống như thư mục home dùng chung, HPC scratch space, và distributed workflow shared storage.

### 4.3 RADOS Gateway (RGW)

Cung cấp **lưu trữ đối tượng** thông qua **RESTful API** tương thích với Amazon S3 và OpenStack Swift. RGW cho phép ứng dụng truy cập dữ liệu trực tiếp thông qua API mà không cần thông qua hệ thống file hay thiết bị khối.

## 5. Chiến lược sao lưu và phục hồi trong CEPH

### 5.1 Tại sao cần sao lưu dù CEPH có dự phòng?

Mặc dù CEPH được thiết kế với **khả năng tự chữa lành** và **dự phòng dữ liệu**, việc sao lưu vẫn rất quan trọng vì các lý do:

- **Disaster recovery**: Thảm họa có thể ảnh hưởng đến toàn bộ cụm lưu trữ
    
- **Ransomware**: Các mã độc tống tiền hiện đại có khả năng ảnh hưởng đến toàn bộ hệ thống dự phòng
    
- **Lỗi người dùng**: Hệ thống nhân bản của CEPH sẽ sao chép cả các thay đổi không mong muốn (như xóa nhầm dữ liệu)
    
- **Lây lan hư hỏng dữ liệu**: Trong một số trường hợp, hư hỏng dữ liệu có thể lan rộng khắp hệ thống
    

### 5.2 Phương pháp sao lưu chính

- **Snapshot-based backups**: Tạo snapshot cho RBD volumes và CephFS, cho phép khôi phục về trạng thái tại thời điểm snapshot. CEPH hỗ trợ cả snapshot đầy đủ và tăng tiến (incremental).
    
- **RBD mirroring**: Đồng bộ hóa dữ liệu giữa các cụm CEPH khác nhau, hỗ trợ cả chế độ đồng bộ và không đồng bộ7.
    
- **Sử dụng công cụ bên thứ ba**: Các giải pháp như **Storware**, **Trilio**, và **Bacula Enterprise** cung cấp khả năng sao lưu nâng cao với features như deduplication, compression, và encryption3.
    

### 5.3 Công cụ sao lưu chuyên dụng

**Storware**:

- Hỗ trợ sao lưu policy-based cho RBD volumes
    
- Giao diện người dùng đơn giản, triển khai agentless
    
- Hỗ trợ extract "snapshot difference" trực tiếp từ CEPH API3
    

**Trilio**:

- Tập trung vào môi trường cloud-native (Kubernetes, OpenStack)
    
- Hỗ trợ kéo RBD snapshots và tạo "snapshot difference" cho incremental backups
    
- Cung cấp disaster recovery và compliance capabilities
    

**Bacula Enterprise**:

- Hỗ trợ sao lưu thông qua RBD exporting kết hợp với bpipe feature
    
- Hiệu suất cao cho cả backup và recovery operations
    
- Hỗ trợ nhiều nền tảng (disk, tape, cloud, VM, applications, databases)3
    

## 6. Triển khai và vận hành thực tế

### 6.1 Thiết lập cụm CEPH cơ bản

Để thiết lập một cụm CEPH cơ bản, có thể sử dụng công cụ `ceph-deploy` hoặc triển khai thủ công các daemon. Các bước cơ bản bao gồm:

1. **Cài đặt các gói CEPH** trên tất cả các node tham gia cụm
    
2. **Khởi tạo cluster** và thiết lập các Monitor đầu tiên
    
3. **Thêm các OSD** để cung cấp không gian lưu trữ vật lý
    
4. **Cấu hình Manager và Metadata Server** (nếu sử dụng CephFS)
    
5. **Tạo storage pools** và thiết lập các chính sách nhân bản/erasure coding
    

### 6.2 Công cụ quản lý và giám sát

CEPH cung cấp nhiều công cụ quản lý và giám sát:

- **Ceph CLI**: Giao diện dòng lệnh để quản lý toàn bộ cụm
    
- **Ceph Dashboard**: Giao diện web trực quan cung cấp thông tin health, performance, và utilization
    
- **Ceph Manager modules**: Các module mở rộng chức năng monitoring, orchestration