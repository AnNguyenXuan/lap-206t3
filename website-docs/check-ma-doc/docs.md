# Hướng xử lý mã độc wp bị chèn mã nguồn

### Nếu có thể truy cập shell
```
find public_html -type f -printf "%TY-%Tm-%Td %TT %p\n" | sort

grep -R --include="*.php" -n "base64_decode" /home/tuanbang/domains/baobituanbang.vn/public_html/
grep -R --include="*.php" -n "eval(" /home/tuanbang/domains/baobituanbang.vn/public_html/
grep -R --include="*.php" -n "gzinflate" /home/tuanbang/domains/baobituanbang.vn/public_html/
grep -R --include="*.php" -n "system(" /home/tuanbang/domains/baobituanbang.vn/public_html/
```

# Hướng xử lý mã độc wp bị chèn site
### Quy trình tìm kiếm trong database
```
SELECT ID, post_date, post_type, post_status, post_title, post_name, guid
FROM daw_posts
WHERE post_status = 'publish'
  AND post_type IN ('post', 'page')
  AND (
    post_title     REGEXP 'casino|bet|22bet|slot|roulette|football'
    OR post_content REGEXP 'casino|bet|22bet|slot|roulette|football'
    OR post_name    LIKE '%casino%'
    OR post_name    LIKE '%bet%'
    OR post_name    LIKE '%football%'
  )
ORDER BY post_date DESC
LIMIT 200;


SELECT ID, post_title, LEFT(post_content, 200) AS snip
FROM daw_posts
WHERE post_status = 'publish'
  AND (
    post_content LIKE '%<script%'
    OR post_content LIKE '%iframe%'
    OR post_content LIKE '%casino%'
    OR post_content LIKE '%22bet%'
  )
ORDER BY post_date DESC
LIMIT 200;


SELECT ID, post_title, post_name, post_date
FROM daw_posts
WHERE post_status = 'publish'
  AND post_type IN ('post', 'page')
  AND (
    post_title   REGEXP 'casino|bet|22bet|slot|roulette|football|depozyt|graczy'
    OR post_name REGEXP 'casino|bet|22bet|football'
    OR post_content REGEXP 'casino|22bet|online.*bet'
  )
ORDER BY post_date DESC;

UPDATE daw_posts
SET post_status = 'trash'
WHERE post_status = 'publish'
  AND post_type IN ('post', 'page')
  AND (
    post_title   REGEXP 'casino|bet|22bet|slot|roulette|football|depozyt|graczy'
    OR post_name REGEXP 'casino|bet|22bet|football'
    OR post_content REGEXP 'casino|22bet|online.*bet'
  );


SELECT ID, post_title, post_name, LEFT(post_content, 200) AS snip
FROM daw_posts
WHERE post_status = 'publish'
  AND post_type IN ('post', 'page')
  AND (
    post_title   REGEXP 'xì tố|xi to|nhà cái|cá cược|game bài|đổi thưởng'
    OR post_content REGEXP '188BET|88BET|nhà cái|cá cược|game bài|đổi thưởng|xì tố|xi to'
  )
ORDER BY post_date DESC;

UPDATE daw_posts
SET post_status = 'trash'
WHERE post_status = 'publish'
  AND post_type IN ('post', 'page')
  AND (
    post_title   REGEXP 'xì tố|xi to|nhà cái|cá cược|game bài|đổi thưởng'
    OR post_content REGEXP '188BET|88BET|nhà cái|cá cược|game bài|đổi thưởng|xì tố|xi to'
  );


Truy cập trang quản trị wp-admin, tìm tới plugin lưu cache và xóa

Tải plugin wp control và tìm kiếm backdoor để xử lý

Tiếp đến, cập nhập lại link index
Gửi yêu cầu xóa toàn bộ URL bẩn trong Google Search Console (GSC)


```