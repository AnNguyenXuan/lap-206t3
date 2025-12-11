## Hướng dẫn cài đặt dmoj
```
# Đăng nhập bằng user root
adduser dmoj
usermod -aG sudo dmoj 

# Cài các gói cần thiết
apt update
apt install -y git gcc g++ make python3-dev python3-pip libxml2-dev libxslt1-dev zlib1g-dev gettext curl redis-server python3-venv
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install nodejs
npm install -g sass postcss-cli postcss autoprefixer

# Cài database
apt update
apt install -y mariadb-server libmariadb-dev libmariadb-dev-compat

# Tạo database
mariadb
CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON dmoj.* TO 'dmoj'@'localhost' IDENTIFIED BY 'Ohm_p2)6T3';
exit
mariadb-tzinfo-to-sql /usr/share/zoneinfo | mariadb -u root mysql  # Add time zone data to the database. A few pages require this.

# Tạo môi trường ảo
python3 -m venv dmojsite
. dmojsite/bin/activate

# Clone dự án
git clone https://github.com/DMOJ/site.git
cd site
git checkout v4.0.0  # chỉ chạy khi cài judge từ PyPI, nếu không thì skip
git submodule init
git submodule update

# Cài các thư viện
sudo apt install python3-dev default-libmysqlclient-dev build-essential pkg-config
pip3 install -r requirements.txt
pip3 install mysqlclient redis pymysql

# Cấu hình dmoj/local_settings.py
# Copy https://github.com/DMOJ/docs/blob/master/sample_files/local_settings.py

nano dmoj/local_settings.py

STATIC_ROOT = '/tmp/static'

ALLOWED_HOSTS = ['10.10.240.171']

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    },
}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'dmoj',
        'USER': 'dmoj',
        'PASSWORD': 'Ohm_p2)6T3',
        'HOST': '127.0.0.1',
        'OPTIONS': {
            'charset': 'utf8mb4',
            'sql_mode': 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION',
        },
    },
}

LANGUAGE_CODE = 'vi'
TIME_ZONE = 'Asia/Ho_Chi_Minh'
DEFAULT_USER_TIME_ZONE = 'Asia/Ho_Chi_Minh'
USE_I18N = True
USE_L10N = True
USE_TZ = True


EVENT_DAEMON_POST = 'ws://127.0.0.1:15101/'
EVENT_DAEMON_GET = 'ws://10.10.240.171/event/'
EVENT_DAEMON_POLL = '/channels/'

CELERY_BROKER_URL = 'redis://localhost:6379'
CELERY_RESULT_BACKEND = 'redis://localhost:6379'


# Kiểm tra cấu hình
python3 manage.py check

# Tạo file style mẫu
./make_style.sh
python3 manage.py collectstatic
python3 manage.py compilemessages
python3 manage.py compilejsi18n

# Tạo schema database
python3 manage.py migrate

# Tải một số dữ liệu ban đầu
python3 manage.py loaddata navbar
python3 manage.py loaddata language_small
python3 manage.py loaddata demo

# Tạo superuser 
# user : root, pass : 'Ohm_p2)6T3'
python3 manage.py createsuperuser

# Chạy redis
systemctl start redis-server

# Chạy thử nhiệm
python3 manage.py runserver 0.0.0.0:8000
python3 manage.py runbridged
celery -A dmoj_celery worker

# Cài đặt  uwsgi
pip3 install uwsgi

# Test uwsgi
nano uwsgi.ini
# Copy https://github.com/DMOJ/docs/blob/master/sample_files/uwsgi.ini
----
[uwsgi]
# Socket and pid file location/permission.
uwsgi-socket = /tmp/dmoj-site.sock
chmod-socket = 666
pidfile = /tmp/dmoj-site.pid

# You should create an account dedicated to running dmoj under uwsgi.
uid = dmoj
gid = dmoj

# Paths.
chdir = /home/dmoj/site
pythonpath = /home/dmoj/site
virtualenv = /home/dmoj/dmojsite

# Details regarding DMOJ application.
protocol = uwsgi
master = true
env = DJANGO_SETTINGS_MODULE=dmoj.settings
module = dmoj.wsgi:application
optimize = 2

# Scaling settings. Tune as you like.
memory-report = true
cheaper-algo = backlog
cheaper = 3
cheaper-initial = 5
cheaper-step = 1
cheaper-rss-limit-soft = 201326592
cheaper-rss-limit-hard = 234881024
workers = 7
----

# Test khởi động
uwsgi --ini uwsgi.ini

# Tải supervisord
sudo apt install supervisor

# Copy https://github.com/DMOJ/docs/blob/master/sample_files/site.conf
sudo nano /etc/supervisor/conf.d/site.conf
----
[program:site]
command=/home/dmoj/dmojsite/bin/uwsgi --ini uwsgi.ini
directory=/home/dmoj/site
user=dmoj
group=dmoj
stopsignal=QUIT
stdout_logfile=/tmp/site.stdout.log
stderr_logfile=/tmp/site.stderr.log
----

# Copy https://github.com/DMOJ/docs/blob/master/sample_files/bridged.conf
sudo nano /etc/supervisor/conf.d/bridged.conf
----
[program:bridged]
command=/home/dmoj/dmojsite/bin/python manage.py runbridged
directory=/home/dmoj/site
stopsignal=INT
# You should create a dedicated user for the bridged to run under.
user=dmoj
group=dmoj
stdout_logfile=/tmp/bridge.stdout.log
stderr_logfile=/tmp/bridge.stderr.log
----

# Copy https://github.com/DMOJ/docs/blob/master/sample_files/celery.conf
sudo nano /etc/supervisor/conf.d/celery.conf
----
[program:celery]
command=/home/dmoj/dmojsite/bin/celery -A dmoj_celery worker
directory=/home/dmoj/site
# You should create a dedicated user for celery to run under.
user=dmoj
group=dmoj
stdout_logfile=/tmp/celery.stdout.log
stderr_logfile=/tmp/celery.stderr.log
----

# Cập nhập 
sudo supervisorctl update
supervisorctl status

# Check logs
sudo supervisorctl tail -f site stderr
sudo supervisorctl tail -f site stdout

# Nếu lỗi có thể fix một số hướng sau
rm -f /tmp/dmoj-site.sock /tmp/dmoj-site.pid

# Reload
sudo supervisorctl update
sudo supervisorctl restart celery
sudo supervisorctl restart site
sudo supervisorctl status

# Setup Nginx
sudo apt install nginx
sudo nano /etc/nginx/sites-enabled/dmoj-web
----
server {
    listen       80;
    listen       [::]:80;

    # Change port to 443 and do the nginx ssl stuff if you want it.

    # Change server name to the HTTP hostname you are using.
    # You may also make this the default server by listening with default_server,
    # if you disable the default nginx server declared.
    server_name 10.10.240.171;

    add_header X-UA-Compatible "IE=Edge,chrome=1";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    charset utf-8;
    try_files $uri @icons;
    error_page 502 504 /502.html;

    location ~ ^/502\.html$|^/logo\.png$|^/robots\.txt$ {
        root /home/dmoj/site;
    }

    location @icons {
        root /home/dmoj/site/resources/icons;
        error_page 403 = @uwsgi;
        error_page 404 = @uwsgi;
    }

    location @uwsgi {
        uwsgi_read_timeout 600;
        # Change this path if you did so in uwsgi.ini
        uwsgi_pass unix:///tmp/dmoj-site.sock;
        include uwsgi_params;
        uwsgi_param SERVER_SOFTWARE nginx/$nginx_version;
    }

    location /static {
        gzip_static on;
        expires max;
        # root /;
        # root <django setting STATIC_ROOT, without the final /static>;
        # Comment out root, and use the following if it doesn't end in /static.
        alias /tmp/static/;
    }

    # Uncomment if you are using PDFs and want to serve it faster.
    # This location name should be set to DMOJ_PDF_PROBLEM_INTERNAL.
    #location /pdfcache {
    #    internal;
    #    root <the value of DMOJ_PDF_PROBLEM_CACHE in local_settings.py>;
    #    # Default from docs:
    #    #root /home/dmoj-uwsgi/;
    #}

    # Uncomment if you are allowing user data downloads and want to serve it faster.
    # This location name should be set to DMOJ_USER_DATA_INTERNAL.
    #location /datacache {
    #    internal;
    #    root <path to data cache directory, without the final /datacache>;
    #    # Default from docs:
    #    #root /home/dmoj-uwsgi/;
    #}

    # Uncomment these sections if you are using the event server.
    location /event/ {
        proxy_pass http://127.0.0.1:15100/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }

    location /channels/ {
        proxy_read_timeout          120;
        proxy_pass http://127.0.0.1:15102;
    }
}
----

# Kiểm tra
sudo ln -s /etc/nginx/sites-enabled/dmoj-web /etc/nginx/sites-available/dmoj-web
sudo nginx -t
sudo service nginx reload

# Cấu hình websocket
nano /home/dmoj/site/websocket/config.js
----
module.exports = {
    get_host: '127.0.0.1',
    get_port: 15100,
    post_host: '127.0.0.1',
    post_port: 15101,
    http_host: '127.0.0.1',
    http_port: 15102,
    long_poll_timeout: 29000,
};
----

npm install qu ws simplesets
pip3 install websocket-client

# Cấu hình wsevent
# Copy https://github.com/DMOJ/docs/blob/master/sample_files/wsevent.conf
sudo nano /etc/supervisor/conf.d/wsevent.conf
----
[program:wsevent]
command=/usr/bin/node /home/dmoj/site/websocket/daemon.js
environment=NODE_PATH="/home/dmoj/site/node_modules"
# Should create a dedicated user.
user=dmoj
group=dmoj
stdout_logfile=/tmp/wsevent.stdout.log
stderr_logfile=/tmp/wsevent.stderr.log
----

sudo supervisorctl update
sudo supervisorctl restart bridged
sudo supervisorctl restart site
sudo service nginx restart
sudo supervisorctl status
```