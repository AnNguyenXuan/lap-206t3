# Hướng dẫn cài đặt Cloud Panel
```
apt update && apt -y upgrade && apt -y install curl wget sudo

curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh; \
echo "19cfa702e7936a79e47812ff57d9859175ea902c62a68b2c15ccd1ebaf36caeb install.sh" | \
sha256sum -c && sudo DB_ENGINE=MARIADB_11.4 bash install.sh
```