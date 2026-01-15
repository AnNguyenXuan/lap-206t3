## Tài liệu vận hành glance

Tạo image cho máy ảo : 

openstack image create "Debian12" --file /path/images/debian12.img --disk-format qcow2 --container-format bare --public 

openstack image create test-iso --disk-format iso --container-format bare --file /path/to/file.iso --public

Dọn các image trong hàng chờ

openstack image list --status queued -f value -c ID | xargs -r openstack image delete
