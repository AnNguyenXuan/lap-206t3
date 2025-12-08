# Giới thiệu về dịch vụ DMOJ

DMOJ (Don Mills Online Judge) là một nền tảng chấm bài lập trình trực tuyến mã nguồn mở, được thiết kế để hỗ trợ các tổ chức, trường học, câu lạc bộ và cộng đồng lập trình xây dựng hệ thống thi lập trình của riêng mình. DMOJ cung cấp môi trường chấm bài tự động, ổn định và linh hoạt, giúp người dùng tổ chức các kỳ thi, luyện tập thuật toán và đánh giá kỹ năng lập trình một cách công bằng và hiệu quả.

## Đặc trưng

### 1. Hệ thống chấm bài tự động
DMOJ có khả năng biên dịch và chạy code ở nhiều ngôn ngữ lập trình (C++, Python, Java, Go, ...), đánh giá bài nộp dựa trên bộ test chuẩn và trả về phản hồi chi tiết:
- Thời gian chạy
- Mức sử dụng bộ nhớ
- Lỗi runtime, compile
- Kết quả pass/fail theo từng test case

### 2. Tổ chức kỳ thi và bài tập dễ dàng
Người quản trị có thể:
- Tạo contest theo thời gian thực
- Quản lý bài tập, điểm số, bảng xếp hạng
- Thiết lập khóa học lập trình hoặc chương trình luyện thi OI/ICPC

### 3. Giao diện thân thiện
DMOJ hỗ trợ:
- Giao diện web trực quan
- Chế độ dark mode
- Hệ thống bình luận, thảo luận
- Tích hợp Markdown cho mô tả đề bài

### 4. Khả năng tùy chỉnh và mở rộng
DMOJ là dự án open-source, cho phép:
- Tự triển khai trên server riêng
- Sử dụng Docker để triển khai linh hoạt
- Điều chỉnh giao diện, API và chức năng
- Kết nối grader, worker phân tán để tăng tốc độ chấm bài

### 5. Đối tượng phù hợp
- Trường học muốn xây dựng hệ thống luyện tập lập trình
- Câu lạc bộ hoặc đội tuyển OI/ICPC
- Doanh nghiệp cần hệ thống đánh giá năng lực lập trình nội bộ
- Cộng đồng lập trình muốn có nền tảng riêng thay vì phụ thuộc nền tảng thương mại


## Các cách triển khai
DMOJ cung cấp 2 phương án triển khai:
- Sử dụng docker
- Triển khai bằng mã nguồn


