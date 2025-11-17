@echo off
REM ===============================
REM  Git commit & push helper
REM ===============================

REM Nếu không truyền message thì báo cách dùng
if "%~1"=="" (
    echo.
    echo Usage: %~nx0 commit_message
    echo.
    echo Vi du: %~nx0 cap nhat CPU-SV
    goto :eof
)

REM Lấy toàn bộ tham số làm commit message
set MESSAGE=%*

REM Xoá hết dau ngoac kep neu co
set MESSAGE=%MESSAGE:"=%

echo.
echo ==========================
echo Commit message: %MESSAGE%
echo ==========================
echo.

git status
echo.
pause

REM Add tat ca file thay doi
git add .

REM Commit
git commit -m "%MESSAGE%"

REM Push len nhanh main
git push origin main

echo.
echo Da push len GitHub xong!
echo.
pause
