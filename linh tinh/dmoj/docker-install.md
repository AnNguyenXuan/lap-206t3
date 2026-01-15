## Hướng dẫn cài đặt dmoj
```
# Đăng nhập bằng user root
adduser dmoj
usermod -aG sudo dmoj 

# Đăng nhập bằng user root tạo
nano /home/dmoj/install_docker.sh
----
#!/bin/bash
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release
apt-get remove -y docker docker-engine docker.io containerd runc || true
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker
docker --version
----

# Cài đặt
chmod 744 install_docker.sh
./install_docker.sh

# Clone mã nguồn và cài đặt
cd /home/dmoj/
git clone https://github.com/Ninjaclasher/dmoj-docker
cd dmoj-docker
git submodule update --init --recursive 
cd dmoj

# Cấu hình 3 file môi trường
cd environment
mysql-admin.env  
mysql.env  
site.env

# Cấu hình nginx servr
nano nginx/conf.d/nginx.conf

# Chạy lệnh
./scripts/initialize
----
#!/bin/bash
cd $(dirname $(dirname $0)) || exit
mkdir problems media
mv ../config.js repo/websocket/
mv ../local_settings.py repo/dmoj/
mv ../uwsgi.ini repo/
----

# Truy cập và sửa file
nano local_settings.py
----
DEFAULT_USER_TIME_ZONE = 'Asia/Ho_Chi_Minh'
----

# Sửa lại docker của mathoid/Dockerfile
FROM node:18-bullseye
WORKDIR /usr/src/app
RUN npm install mathoid && \
    ln -sf /usr/src/app/node_modules/mathoid/app.js /usr/src/app/node_modules/app.js
WORKDIR /usr/src/app/node_modules/mathoid
EXPOSE 10044
CMD ["node", "server.js"]

# Sửa lại mount point mathoid trong docker-compose.yaml
- ./mathoid/config.yaml:/usr/src/app/node_modules/mathoid/config.yaml

# Build docker
docker compose build --no-cache
docker compose up -d site
docker ps

# Migrate dữ liệu
./scripts/migrate
./scripts/copy_static
./scripts/manage.py loaddata navbar
./scripts/manage.py loaddata language_small
./scripts/manage.py loaddata demo

# Up toàn bộ container
docker compose up -d

# Tại trang web admin, tạo máy chấm tại mục Ngôn ngữ
judge1
I0yOVWKGyYSNlJMgLB0Ha2oXSNdyENjpM2hypu+/2LFPYs/hA24frTEJGvW1LucugN3PCVKwuRvr3fwym9EQvpsXnzvBcUNMSMWZ
I0yOVWKGyYSNlJMgLB0Ha2oXSNdyENjpM2hypu+/2LFPYs/hA24frTEJGvW1LucugN3PCVKwuRvr3fwym9EQvpsXnzvBcUNMSMWZ
# Cài máy chấm
cd /home/dmoj/
git clone --recursive https://github.com/DMOJ/judge.git
cd judge/.docker
apt-get install make
make judge-tier1
nano /home/dmoj/dmoj-docker/dmoj/problems/judge1.yml
----
id: judge1
key: "I0yOVWKGyYSNlJMgLB0Ha2oXSNdyENjpM2hypu+/2LFPYs/hA24frTEJGvW1LucugN3PCVKwuRvr3fwym9EQvpsXnzvBcUNMSMWZ"

problem_storage_globs:
  - /problems/*
----

# Chạy máy chấm
docker run -d --name judge1 \
  --restart=always \
  --cap-add=SYS_PTRACE \
  -v /home/dmoj/dmoj-docker/dmoj/problems:/problems \
  -p 10.10.240.171:9996:9996 \
  dmoj/judge-tier1:latest \
  run -p 9999 -c /problems/judge1.yml \
  "10.10.240.171" "judge1" "I0yOVWKGyYSNlJMgLB0Ha2oXSNdyENjpM2hypu+/2LFPYs/hA24frTEJGvW1LucugN3PCVKwuRvr3fwym9EQvpsXnzvBcUNMSMWZ"

docker stop judge1 && docker rm judge1
docker logs


```