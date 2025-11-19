### Hướng xử lý mã độc wp
```
find public_html -type f -printf "%TY-%Tm-%Td %TT %p\n" | sort

grep -R --include="*.php" -n "base64_decode" /home/tuanbang/domains/baobituanbang.vn/public_html/
grep -R --include="*.php" -n "eval(" /home/tuanbang/domains/baobituanbang.vn/public_html/
grep -R --include="*.php" -n "gzinflate" /home/tuanbang/domains/baobituanbang.vn/public_html/
grep -R --include="*.php" -n "system(" /home/tuanbang/domains/baobituanbang.vn/public_html/

```