
# các node ceph bị shutdown đột ngột

Khi vào lại shell cần đồng bộ lại để đảm bảo đồng nhất tránh bị skew clock

```zsh
systemctl restart chrony
chronyc makestep
```

# failed cephadm daemon(s)

Ví dụ:

```zsh
root@ceph-mgmt01:~# ceph health detail
HEALTH_WARN 7 failed cephadm daemon(s)
[WRN] CEPHADM_FAILED_DAEMON: 7 failed cephadm daemon(s)
    daemon osd.9 on ceph-data01 is in unknown state
    daemon osd.1 on ceph-data01 is in unknown state
    daemon osd.14 on ceph-data01 is in unknown state
    daemon osd.7 on ceph-data04 is in unknown state
    daemon osd.8 on ceph-data04 is in unknown state
    daemon osd.3 on ceph-data04 is in unknown state
    daemon osd.12 on ceph-data04 is in unknown state
root@ceph-mgmt01:~# 
```

Xử lý bằng cách restart lại các  osd...

```zsh
ceph orch daemon restart osd.9
ceph orch daemon restart osd.1
```

Lưu ý nên restart từng cái một sau đó đợi cho osd up hẳn, sẽ có khả năng tự up hết khi restart lại mà không cần phải restart nữa.

# monitor down

Ví dụ như sau:

```zsh
root@ceph-mgmt01:~# ceph health detail                                             
HEALTH_WARN 1/3 mons down, quorum ceph-mgmt02,ceph-mgmt03; 86 slow ops, oldest one blocked for 221 sec, mon.ceph-mgmt01 has slow ops                                  
[WRN] MON_DOWN: 1/3 mons down, quorum ceph-mgmt02,ceph-mgmt03                      mon.ceph-mgmt01 (rank 0) addr [v2:10.20.20.120:3300/0,v1:10.20.20.120:6789/0] is down (out of quorum)                                                               
[WRN] SLOW_OPS: 86 slow ops, oldest one blocked for 221 sec, mon.ceph-mgmt01 has slow ops
```

Check service của mon1

```zsh
systemctl | grep ceph
```

Restart mon service

```zsh
systemctl restart ceph-9184cfae-8c15-11f0-98af-005056acbfbe@mon.ceph-mgmt01.service
```

# failed cephadm daemon(s)

Ví dụ

```zsh
root@ceph-mgmt01:~# ceph health detail                                             
HEALTH_WARN 1 failed cephadm daemon(s)                                             
[WRN] CEPHADM_FAILED_DAEMON: 1 failed cephadm daemon(s)                            
    daemon osd.7 on ceph-data04 is in unknown state
```

```zsh
ceph orch daemon restart osd.7
```

