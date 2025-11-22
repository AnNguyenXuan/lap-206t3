## Các thông số ảnh hưởng tới website, app và các dịch vụ

### 1. Latency ổ đĩa
```
Latency ảnh hưởng trực tiếp đến tốc độ đọc, ghi dữ liệu
Dùng ioping lệnh 
ioping -c 10 /dev/nvme0n1
ioping -c .
```

### 2. Connection pooling
```
Là cơ chế tạo sẵn một nhóm (pool) các kết nối tới database và tái sử dụng những kết nối này cho các request tiếp theo, thay vì mở–đóng kết nối liên tục.

Nguyên nhân gây chậm :
Vì mở một kết nối DB mới tốn thời gian (vài ms đến vài trăm ms), và còn tốn tài nguyên (handshake, auth, socket…).
Nếu app có nhiều request/giây, hoặc query liên tục thì mỗi lần mở kết nối mới sẽ ảnh hưởng hiệu năng.

Nhược điểm :
Cấu hình này sẽ giữ kết nối của web app tới database, làm tăng tải tới database

Cấu hình :
- Trong nodejs
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: 5432,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  max: 10,           // max connections in pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

module.exports = pool;

- Trong php
Đặc thù của PHP: không có connection pool theo kiểu Java/.NET

Với các ứng dụng web PHP (Laravel, WordPress, framework khác…) chạy dưới Apache + mod_php hoặc PHP-FPM:

Mỗi request HTTP được xử lý bởi một process / worker riêng.
Sau khi xử lý xong request, phần lớn tài nguyên tạm (biến, object…) sẽ bị giải phóng.
Do đó, PHP không duy trì một connection pool sống lâu dài trong ứng dụng theo kiểu một process giữ một pool và share cho nhiều request như Java.

Thay vào đó, PHP sử dụng 2 cơ chế chính:

Kết nối bình thường (non-persistent):

   Mỗi request: `connect → query → close`.
   Không có pool, không tái sử dụng kết nối giữa các request.

Kết nối persistent (persistent connection):

   Mỗi PHP-FPM worker có thể giữ lại kết nối sau khi xử lý xong request.
   Request tiếp theo dùng lại kết nối đó (vẫn trong cùng worker).
   Đây không phải là connection pool toàn cục, mà là kết nối được giữ lại theo từng worker.

Cấu hình connection và pooling trong PHP

Ở mức code: PDO / MySQLi / framework

Ví dụ với PDO (MySQL):

$pdo = new PDO(
    'mysql:host=127.0.0.1;dbname=test;charset=utf8mb4',
    'username',
    'password',
    [
        PDO::ATTR_PERSISTENT => true, // bật persistent connection
    ]
);


Tuỳ chọn `PDO::ATTR_PERSISTENT => true` cho phép PHP-FPM worker giữ kết nối mở và tái sử dụng trong các request tiếp theo.
Cấu hình này thường được đặt tại:

  file `db.php`, `database.php`
  hoặc trong các framework: class `Database`, `Connection`, service container…

Laravel:

Kết nối được cấu hình tại `config/database.php`, giá trị lấy từ `.env`:

  `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, ...
Nếu muốn persistent connection, có thể cấu hình thêm tuỳ chọn PDO trong `config/database.php`.

Connection pool thực sự: ở tầng hạ tầng (PgBouncer, ProxySQL, …)

Nếu cần connection pooling đúng nghĩa nhiều process/share pool, quản lý pool tập trung người ta không làm ở trong PHP, mà làm ở ngoài:

PostgreSQL: sử dụng PgBouncer làm connection pooler.
MySQL/MariaDB: sử dụng ProxySQL, MaxScale, hoặc các middle layer khác.

Khi đó:

PHP/Laravel chỉ kết nối tới DB trung gian (PgBouncer/ProxySQL).
Pool size, timeout, policy… được cấu hình trong file cấu hình của PgBouncer/ProxySQL, không phải trong code PHP.
DB thật (PostgreSQL/MySQL) chỉ thấy một số kết nối ít hơn, đã được pool lại.

Vai trò của database server

Database server (MySQL, PostgreSQL…) không tạo pool cho ứng dụng, mà chỉ:
Giới hạn tổng số kết nối (`max_connections`, v.v.).
Đặt timeout cho kết nối idle.
Quản lý tài nguyên phía DB.
```