# Tools test hiệu năng s3
```
# Truy cập đường dẫn
https://github.com/minio/warp

# Tải file binary về để bắt đầu cài đặt
https://github.com/minio/warp/releases

# Lựa chọn phiên bản và tải về
wget https://github.com/minio/warp/releases/download/v1.3.0/warp_Linux_x86_64.deb

# Cài đặt
apt install ./warp.deb

# Chuẩn bị 4 host như vậy, trong đó 1 host admin, 3 host worker, chạy lệnh tại node worker
warp client 0.0.0.0

# Chạy lệnh tại admin node
warp mixed \
  --duration=5m \
  --concurrent=128 \
  --obj.size=0.1MiB \
  --host=10.10.210.20:8080 \
  --access-key=test --secret-key=test \
  --warp-client=10.10.240.{66...68}:7761
```