## Tổng hợp một số tools trên window
```
Công cụ chỉnh sửa ảnh : Skitch
Công cụ kiểm tra ổ cứng :  Hard Disk Sentinel 
Công cụ quét file : SpaceSniffer
Công cụ quản lý driver : DriverStoreExplorer
Công cụ sysadmin : Sysinternals
Công cụ SDK : Windows Assessment and Deployment Kit (ADK)
```


## Pooltag Memory leak check
```
Truy cập cài đặt công cụ WDK trên Microsoft

C:\Program Files (x86)\Windows Kits\10\Tools\64\poolmon.exe
Chạy trong thư mục Program x86
Nhấn P  → lọc Nonpaged Pool
Nhấn B  → sort theo Bytes

findstr /m /l "VFil" c:\Windows\System32\drivers\*.sys
fltmc filters
fltmc unload vsepflt
```

## Disable Services 
```
Cách tắt anti malware services

Computer Configuration -> Administrative Templates -> Windows Components -> Microsoft Defender Antivirus

Turn off Microsoft Defender Antivirus -> Enable
Real-time Protection -> Turn off real-time protection -> Enable
```

## Optimized Windows
```
powercfg /hibernate off
powercfg /hibernate on
powercfg /a

DISM /Online /Set-ReservedStorageState /State:Disabled
DISM /Online /Set-ReservedStorageState /State:Enabled
DISM /Online /Get-ReservedStorageState

Get-AppxPackage | Select Name, PackageFullName
Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*tên_app*" | Remove-AppxProvisionedPackage -Online

$apps = @(
  "Microsoft.GetHelp","Microsoft.Getstarted","Microsoft.BingWeather","Microsoft.BingSearch",
  "Microsoft.WindowsFeedbackHub","Microsoft.549981C3F5F10","Microsoft.Wallet","Microsoft.People",
  "Microsoft.WindowsMaps","microsoft.windowscommunicationsapps","Microsoft.Microsoft3DViewer",
  "Microsoft.MixedReality.Portal","Microsoft.MicrosoftSolitaireCollection","Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo","Microsoft.XboxApp","Microsoft.YourPhone","MicrosoftWindows.CrossDevice",
  "Microsoft.Windows.DevHome"
)

foreach ($a in $apps) {
  Get-AppxPackage -AllUsers -Name $a | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
  Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $a | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

$apps = @(
  "Microsoft.GetHelp","Microsoft.Getstarted","Microsoft.BingWeather","Microsoft.BingSearch",
  "Microsoft.WindowsFeedbackHub","Microsoft.549981C3F5F10","Microsoft.Wallet","Microsoft.People",
  "Microsoft.WindowsMaps","microsoft.windowscommunicationsapps","Microsoft.Microsoft3DViewer",
  "Microsoft.MixedReality.Portal","Microsoft.MicrosoftSolitaireCollection","Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo","Microsoft.XboxApp","Microsoft.YourPhone","MicrosoftWindows.CrossDevice",
  "Microsoft.Windows.DevHome"
)

foreach ($a in $apps) {
  Get-AppxPackage -Name $a | Remove-AppxPackage -ErrorAction Continue
}
```