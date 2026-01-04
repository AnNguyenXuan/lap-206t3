## Các lệnh xử lý trên cụm
```
ceph health detail : xem chi tiết lỗi
ceph osd stat : xem trạng thái osd
ceph orch daemon restart osd.8 : restart osd
ceph orch daemon redeploy osd.8 : triển khai lại
ceph osd out 8 : loại bỏ osd ra cụm
ceph orch daemon rm osd.8 --force : xóa daemon
ceph osd purge 8 --yes-i-really-mean-it : xóa khỏi CRUSH map
ceph osd pool ls detail : xem cấu hình pool
```

## Quy trình loại bỏ osd 
```
Trong TH ta muốn loại bỏ toàn bộ cụm
ceph fsid
ls /var/lib/ceph/
cephadm rm-cluster --force --zap-osds --fsid 3d350dc8-e972-11f0-8f70-005056ac5a6e
rm -rf /etc/ceph/ceph.client.admin.keyring 
ls /var/lib/ceph/

ceph orch ls --service_type osd
ceph orch rm <service_name> --force
ceph orch osd rm <osd_id> --zap --force
ceph orch device zap openstack-data-2 /dev/sdc --force
ceph -s
```

## Để thực hiện xóa 1 cụm Ceph (Đảm bảo không có dữ liệu nào cần lưu)
```
# Tải gdisk
apt-get update && apt-get install -y gdisk util-linux 

# Xóa cấu hình trên node admin
# Ngắt module mgr 
ceph mgr module disable cephadm

# Lấy FSID cụm
cephadm shell -- ceph fsid
echo $FSID   

# Xóa cụm
cephadm rm-cluster --force --zap-osds --fsid <FSID>

# Xóa cấu hình trên các node còn lại
# Kiểm tra service liên quan đến ceph
systemctl list-unit-files --type=service | grep -E '^ceph-|^docker-ceph' || true

# Xóa system file
for u in $(systemctl list-unit-files --type=service --no-legend | awk '/^ceph-|^docker-ceph/{print $1}'); do
  systemctl stop "$u" 2>/dev/null || true
  systemctl disable "$u" 2>/dev/null || true
  rm -f "/etc/systemd/system/$u" 2>/dev/null || true
done

# Xóa container 
docker ps -aq --filter "name=ceph"
docker rm -f $(docker ps -aq --filter "name=ceph") 2>/dev/null || true

# Xóa thư mục cấu hình 
rm -rf /etc/ceph/* /var/lib/ceph/* /var/log/ceph/* 2>/dev/null || true

# Tùy chọn dọn rác Docker
docker volume ls | awk '/ceph/{print $2}' | xargs -r docker volume rm
docker network ls | awk '/ceph/{print $2}' | xargs -r docker network rm
docker system prune -a --volumes -f

# Xóa OSD 
DEV=/dev/sdc ư  # thay cho đúng
docker run --rm --privileged -v /dev:/dev -v /run/udev:/run/udev quay.io/ceph/ceph:v19 \
  ceph-volume lvm zap --destroy "$DEV"
sgdisk --zap-all "$DEV" || true
wipefs -a "$DEV" || true

DEV=/dev/sdd   # thay cho đúng
docker run --rm --privileged -v /dev:/dev -v /run/udev:/run/udev quay.io/ceph/ceph:v19 \
  ceph-volume lvm zap --destroy "$DEV"
sgdisk --zap-all "$DEV" || true
wipefs -a "$DEV" || true

DEV=/dev/sde   # thay cho đúng
docker run --rm --privileged -v /dev:/dev -v /run/udev:/run/udev quay.io/ceph/ceph:v19 \
  ceph-volume lvm zap --destroy "$DEV"
sgdisk --zap-all "$DEV" || true
wipefs -a "$DEV" || true

DEV=/dev/sdh   # thay cho đúng
docker run --rm --privileged -v /dev:/dev -v /run/udev:/run/udev quay.io/ceph/ceph:v19 \
  ceph-volume lvm zap --destroy "$DEV"
sgdisk --zap-all "$DEV" || true
wipefs -a "$DEV" || true

cephadm shell -- ceph orch host drain openstack-node-1 --force
cephadm shell -- ceph orch host drain openstack-node-2 --force

# Xóa host khỏi cụm
cephadm shell -- ceph orch host rm openstack-node-1 --force
cephadm shell -- ceph orch host rm openstack-node-2 --force
```