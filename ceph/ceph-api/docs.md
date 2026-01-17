## Quy trình chạy code trong môi trường venv
```
Tạo một thư mục ceph-api
cd ceph-api

Tạo môi trường ảo
python -m venv venv

Truy cập môi trường ảo
venv\Scripts\activate

Cài đặt jupyter notebook
pip install jupyter ipykernel

Đăng ký venv làm kernal cho jupyter
python -m ipykernel install --user --name ceph-venv --display-name "Python (ceph-venv)"

Mở jupyter notebook
jupyter notebook

Chọn kernel trên giao diện web
Kernel → Change Kernel → Python (ceph-venv)

Chạy code kiểm tra
import sys
sys.executable

Kết quả có dạng dưới đây là đang chạy đúng
'...\\ceph-api\\venv\\Scripts\\python.exe'

Cách cài thư viện vào môi trường đang chạy
%pip install boto3
```