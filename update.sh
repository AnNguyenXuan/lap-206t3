#!/bin/bash
# ===============================
#  Git commit & push helper
# ===============================

# Nếu không truyền message thì báo cách dùng
if [ -z "$1" ]; then
    echo
    echo "Usage: $0 commit_message"
    echo
    echo "Ví dụ: $0 cap nhat CPU-SV"
    echo
    exit 1
fi

# Lấy toàn bộ tham số làm commit message
MESSAGE="$*"

# Xoá dấu ngoặc kép nếu có
MESSAGE="${MESSAGE//\"/}"

echo
echo "=========================="
echo "Commit message: $MESSAGE"
echo "=========================="
echo

git status
echo
read -p "Nhấn Enter để tiếp tục..."

# Add tất cả file thay đổi
git add .

# Commit
git commit -m "$MESSAGE"

# Push lên nhánh main
git push origin main

echo
echo "Đã push lên GitHub xong!"
echo
read -p "Nhấn Enter để thoát..."
