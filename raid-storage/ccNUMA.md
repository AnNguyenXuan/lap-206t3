## Khái niệm
```
NUMA là một chủ đề liên quan đến kiến trúc phần cứng, nó ảnh hưởng rất thật tới hiệu năng ghi vì ghi (đặc biệt ghi nhanh) thường bị giới hạn bởi đường đi dữ liệu trong RAM + CPU + bus + NIC/HBA/NVMe, chứ không chỉ đĩa.

Máy nhiều CPU socket thường có kiến trúc:
Mỗi CPU (NUMA node) có RAM gần của nó (local memory).
CPU vẫn truy cập được RAM của node khác (remote memory) nhưng chậm hơn vì phải đi qua liên kết CPU↔CPU (UPI/QPI trên Intel, Infinity Fabric trên AMD)

Vậy: 
Local memory access: nhanh hơn, băng thông cao hơn
Remote memory access: latency cao hơn, băng thông thấp hơn, tốn interconnect

ccNUMA = NUMA nhưng cache coherence được phần cứng đảm bảo, nên toàn hệ vẫn nhìn như một máy thống nhất. Nhưng hiệu năng phụ thuộc bạn có để đúng dữ liệu gần đúng CPU không

Keyword : Processor Affinity
resync :

o sata va sas
```

## Chiến lược cải thiện hiệu năng với NUMA
```
1. CPU gần thiết bị, RAM cũng gần CPU
Nếu workload ghi đi qua một thiết bị cụ thể (NIC/HBA/NVMe), mục tiêu là:
IRQ/softirq của thiết bị chạy trên CPU cores của cùng node
tiến trình chính (Ceph OSD, process backup, v.v.) cũng chạy trên cores đó
RAM cấp phát ưu tiên node đó

Công cụ:
taskset / systemd CPUAffinity=
numactl --cpunodebind= --membind=
irqbalance (tự động) hoặc manual IRQ affinity

2. Tránh cross-NUMA cho VM/IO-heavy process
Trong ảo hóa (KVM/OpenStack), nếu VM vCPU ở node0 nhưng memory ở node1 (hoặc ngược lại) → IO path thường kém.
Giải pháp học thuật:
vCPU pinning + memory binding (hugepages thường giúp cố định locality)
tránh để một VM lớn tràn qua 2 NUMA node (trừ khi thật cần)

3. Đừng để kernel auto NUMA balancing làm bạn bất ngờ
Linux có AutoNUMA (kernel.numa_balancing) cố gắng di chuyển pages để tăng locality. Đôi lúc nó giúp, đôi lúc tạo overhead trong workload nặng IO.
(Đây là chủ đề nâng cao; khi bạn đo benchmark nghiêm túc mới đụng.)
```

## Lệnh thao tác
```
Xem topology NUMA
apt install numactl
lscpu | egrep -i "NUMA|Socket|Core|Thread"
numactl --hardware

Xem thiết bị PCIe thuộc NUMA node nào
lspci -D | egrep -i "ethernet|nvme|sas|raid"
cat /sys/bus/pci/devices/0000:xx:yy.z/numa_node

Xem tiến trình dùng RAM chạy tại node nào
numastat -p <pid>

Xem phân bố IRQ theo CPU (rất quan trọng với NIC/HBA)
cat /proc/interrupts

Kiểm tra cơ chế cân bằng linux 
systemctl status irqbalance --no-pager
```

## Kiểm tra NIC
```
ethtool -l eno1
```

## Với Block
```
cat /sys/block/sdb/queue/scheduler
cat /sys/block/sdb/queue/nr_requests
cat /sys/block/sdb/queue/read_ahead_kb
```

## Kiến trúc RAM
```
Do cơ chế truy cập Local memory access, CPU sẽ ưu tiên truy cập RAM gần nó   
Kiến trúc cắm RAM nên ưu tiên full kênh trước -> Sau đó sẽ đẩy full slot theo thứ tự 1,2,3
```