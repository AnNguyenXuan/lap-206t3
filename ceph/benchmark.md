## Công cụ COSBench

### Trên tất cả các node (1 node controller, 4 node driver ubuntu 22.04)
```
apt-get update

apt-get install -y wget curl unzip gnupg ca-certificates netcat-openbsd

wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public \
| gpg --dearmor -o /usr/share/keyrings/adoptium.gpg

echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb jammy main" \
> /etc/apt/sources.list.d/adoptium.list

apt-get update

apt-get install -y temurin-8-jdk

java -version

unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY

wget -O 0.4.2.c4.zip https://github.com/intel-cloud/cosbench/releases/download/v0.4.2.c4/0.4.2.c4.zip

unzip -o 0.4.2.c4.zip

cd 0.4.2.c4

chmod +x *.sh
```

### Cấu hình node controller (thay ip)
```
nano conf/controller.conf

[controller]
concurrency=1
drivers=4
log_level = INFO
log_file = log/system.log
archive_dir = archive

[driver1]
name=driver1
url=http://10.10.240.66:18088/driver

[driver2]
name=driver2
url=http://10.10.240.67:18088/driver

[driver3]
name=driver3
url=http://10.10.240.68:18088/driver

[driver4]
name=driver4
url=http://10.10.240.69:18088/driver
```

### Cấu hình driver trên các node (thay ip, name)
```
nano conf/driver.conf 
# node driver1
[driver]
name=driver1
url=http://10.10.240.66:18088/driver

# node driver2
[driver]
name=driver2
url=http://10.10.240.67:18088/driver

# node driver3
[driver]
name=driver3
url=http://10.10.240.68:18088/driver

# node driver4
[driver]
name=driver4
url=http://10.10.240.69:18088/driver
```

### Chạy driver, controller
```
# Trên node driver
./start-driver.sh

# Truy cập
http://10.10.240.66:18088/driver/index.html 
http://10.10.240.67:18088/driver/index.html 
http://10.10.240.68:18088/driver/index.html 
http://10.10.240.69:18088/driver/index.html 

# Trên node controller
sh start-controller.sh 

# Truy cập
http://10.10.240.70:19088/controller/index.html 
```

### Đọc thông số
```
Avg-ResTime : Thời gian từ lúc request được gửi → nhận xong response HTTP
Avg-ProcTime : Thời gian COSBench xử lý operation ở tầng client (driver)
```

## Test API S3
```


```

