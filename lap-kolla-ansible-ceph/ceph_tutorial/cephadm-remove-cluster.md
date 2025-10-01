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
DEV=/dev/sdc   # thay cho đúng
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