## Cách chuyển đổi version python khi có nhiều version
```
Tạo file
C:\Users\ADMIN\AppData\Local\py.ini

Cấu hình
[defaults]
python=3.11

Mở PowerShell và kiểm tra
py --version
py -0p
```

## Cài pip
```
py -m pip install --upgrade pip setuptools wheel

Cài thư viện
py -m pip install boto3 pyyaml rgwadmin

```