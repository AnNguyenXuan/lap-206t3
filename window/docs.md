## Tổng hợp một số mẹo quản trị Window

### Các thư mục quan  trọng

![alt text](image.png)

### Một số lệnh hữu ích
```
manage-bde -status
manage-bde -protectors -disable C:

Xóa cache dns
ipconfig /flushdns (Windows)
```

### Cách tắt tiếng chuông khi ấn tab trên terminal
```
Tạo thư mục profile
New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force

Tạo profile
New-Item -ItemType File -Path $PROFILE -Force

Truy cập
notepad $PROFILE

Thêm dòng
Set-PSReadLineOption -BellStyle None
```
### Kiểm tra bản ghi dns
```
nslookup dcjourneys.com dnssec1.pavietnam.vn
nslookup dcjourneys.com dnssec2.pavietnam.vn
nslookup dcjourneys.com dnssecbak.pavietnam.net
ipconfig /displaydns
```

### Cấp quyền chạy script ở mức độ user
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Một số lệnh chạy policy
```
rsop.msc : load cấu hình chính sách máy window hiện tại
gpresult /r
```

### Format usb
```
Chạy diskpart
DISKPART>

DISKPART> list disk

  Disk ###  Status         Size     Free     Dyn  Gpt
  --------  -------------  -------  -------  ---  ---
  Disk 0    Online          476 GB  1000 MB        *
  Disk 1    Online           57 GB    57 GB

DISKPART> select disk 1

Disk 1 is now the selected disk.

DISKPART> attributes disk clear readonly

Disk attributes cleared successfully.

DISKPART> clean

DiskPart succeeded in cleaning the disk.

DISKPART> convert mbr

DISKPART> convert gpt

DISKPART> create partition primary

DiskPart succeeded in creating the specified partition.

DISKPART> format fs=ntfs quick

  100 percent completed

DiskPart successfully formatted the volume.

DISKPART>


```

## Lỗi Sysprep Window
```
Truy cập C:\Windows\System32\Sysprep\Panther\setupact.log
```

## Cách gỡ bỏ các App Windows
```
Truy cập và nhập lệnh
C:\Program Files (x86)\Microsoft\Edge\Application\83.0.478.58\Installer\setup.exe --uninstall --system-level --verbose-logging --force-uninstall

get-appxpackage *store | remove-appxpackage

Off Reserved Storage
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager

ShippedWithReserves = 0
```

## Đóng gói ISO
```
Tải bộ cài đóng gói
Windows Assessment and Deployment Kit (ADK)

```

##
```
@echo off
setlocal EnableExtensions EnableDelayedExpansion
cls

title Install Windows Update MSU via CAB - Windows Server 2016

echo =====================================================================
echo    CAI DAT WINDOWS UPDATE: EXPAND MSU -^> INSTALL CAB
echo    Dung cho Windows Server 2016 / Windows 10 1607
echo =====================================================================
echo.

:: Check Administrator
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo [ERROR] Vui long chay file .bat bang quyen Administrator.
    echo Click chuot phai file .bat -^> Run as Administrator.
    echo.
    pause
    exit /b 1
)

cd /d "%~dp0"

:: Tao timestamp log
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"

set "LOG=%~dp0Install_Update_%TS%.log"
set "TEMP_ROOT=%TEMP%\KB_Extract_%RANDOM%_%RANDOM%"
set /a COUNT=0
set /a FAIL=0
set /a REBOOT_REQUIRED=0

echo [OK] Dang chay voi quyen Administrator.
echo [INFO] Thu muc script: %CD%
echo [INFO] File log: %LOG%
echo.

echo ===================================================================== >> "%LOG%"
echo INSTALL WINDOWS UPDATE LOG - %DATE% %TIME% >> "%LOG%"
echo Script folder: %CD% >> "%LOG%"
echo ===================================================================== >> "%LOG%"
echo. >> "%LOG%"

if not exist "*.msu" (
    echo [WARNING] Khong tim thay file .msu nao trong thu muc hien tai.
    echo [WARNING] Khong tim thay file .msu nao trong thu muc hien tai. >> "%LOG%"
    pause
    exit /b 0
)

echo =====================================================================
echo  BAT DAU XU LY CAC FILE .MSU
echo =====================================================================
echo.

for %%F in (*.msu) do (
    set /a COUNT+=1
    echo ---------------------------------------------------------------------
    echo [!COUNT!] Dang xu ly: %%~nxF
    echo [!COUNT!] Dang xu ly: %%~nxF >> "%LOG%"

    set "EXTRACT_DIR=%TEMP_ROOT%\%%~nF"

    if exist "!EXTRACT_DIR!" rd /s /q "!EXTRACT_DIR!" >nul 2>&1
    md "!EXTRACT_DIR!" >nul 2>&1

    echo - Dang expand MSU...
    echo - Expand: %%~fF >> "%LOG%"

    expand -F:* "%%~fF" "!EXTRACT_DIR!" >> "%LOG%" 2>&1
    set "RC=!errorlevel!"

    if not "!RC!"=="0" (
        echo [FAILED] Loi expand file %%~nxF. Ma loi: !RC!
        echo [FAILED] Loi expand file %%~nxF. Ma loi: !RC! >> "%LOG%"
        set /a FAIL+=1
    ) else (
        echo - Expand thanh cong.

        :: 1. Cai SSU*.cab truoc neu co
        for /f "delims=" %%C in ('dir /b /a-d "!EXTRACT_DIR!\SSU*.cab" 2^>nul') do (
            call :InstallCab "!EXTRACT_DIR!\%%C"
        )

        :: 2. Cai cac CAB con lai, bo qua WSUSSCAN.cab va SSU*.cab
        for /f "delims=" %%C in ('dir /b /a-d "!EXTRACT_DIR!\*.cab" 2^>nul ^| findstr /v /i "^WSUSSCAN.cab$" ^| findstr /v /i "^SSU"') do (
            call :InstallCab "!EXTRACT_DIR!\%%C"
        )
    )

    echo ---------------------------------------------------------------------
    echo.
)

echo Dang don dep thu muc tam...
if exist "%TEMP_ROOT%" rd /s /q "%TEMP_ROOT%" >nul 2>&1

echo.
echo =====================================================================
echo  TONG KET
echo =====================================================================
echo Da xu ly: %COUNT% file .msu
echo So loi: %FAIL%
echo Log: %LOG%

if "%FAIL%"=="0" (
    echo.
    echo [DONE] Qua trinh cai dat hoan tat.
    if "%REBOOT_REQUIRED%"=="1" (
        echo [INFO] Co goi update yeu cau restart.
    )
    echo.
    echo Nen restart server de hoan tat update.
    choice /m "Ban co muon restart ngay bay gio khong"
    if "!errorlevel!"=="1" (
        shutdown /r /t 5 /c "Restart sau khi cai Windows Update"
    ) else (
        echo Ban da chon restart sau.
    )
) else (
    echo.
    echo [WARNING] Co loi trong qua trinh cai dat. Hay kiem tra file log truoc khi restart.
)

pause
exit /b


:InstallCab
set "CAB_PATH=%~1"
set "CAB_NAME=%~nx1"

echo - Dang cai CAB: %CAB_NAME%
echo - DISM install: %CAB_PATH% >> "%LOG%"

dism.exe /Online /Add-Package /PackagePath:"%CAB_PATH%" /Quiet /NoRestart >> "%LOG%" 2>&1
set "RC=%errorlevel%"

if "%RC%"=="0" (
    echo   [SUCCESS] %CAB_NAME%
    echo   [SUCCESS] %CAB_NAME% >> "%LOG%"
    exit /b 0
)

if "%RC%"=="3010" (
    echo   [SUCCESS] %CAB_NAME% - Yeu cau restart.
    echo   [SUCCESS] %CAB_NAME% - Yeu cau restart. >> "%LOG%"
    set /a REBOOT_REQUIRED=1
    exit /b 0
)

echo   [FAILED] %CAB_NAME% - Ma loi: %RC%
echo   [FAILED] %CAB_NAME% - Ma loi: %RC% >> "%LOG%"
set /a FAIL+=1
exit /b %RC%
```

