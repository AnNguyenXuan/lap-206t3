
---

## 1) CPU ↔ RAM ↔ NUMA

* **NUMA / ccNUMA**
* **Memory locality** (local vs remote memory)
* **NUMA node / socket**
* **Interconnect**: Intel **QPI/UPI**, AMD **Infinity Fabric**
* **NUMA affinity / CPU pinning / memory binding**
* **NUMA balancing** (`kernel.numa_balancing`)
* **Thread/CPU topology**: **SMT/Hyper-Threading**, **core**, **thread siblings**
* **Cache hierarchy**: L1/L2/L3, **LLC**, **cache line** (thường 64B)
* **Cache coherence**, **MESI**
* **False sharing** (rất hay phá hiệu năng multi-thread)

---

## 2) I/O path: Disk/NIC/PCIe (tối ưu “đường dữ liệu”)

* **PCIe topology**, **PCIe root complex**
* **DMA** (Direct Memory Access)
* **IOMMU / VT-d / AMD-Vi**
* **MSI/MSI-X interrupts**
* **IRQ affinity / interrupt pinning**
* **Softirq / NAPI** (network)
* **RSS/RPS/XPS** (network queue steering)
* **Queue depth** (**QD**, **IO depth**)
* **I/O scheduler**: **mq-deadline**, **none**, **bfq**
* **Workqueue affinity** (một số driver dùng workqueue)

---

## 3) Storage performance (đúng “keyword” bạn hay gặp)

* **IOPS vs throughput vs latency**
* **Sequential vs random** (và “fragmented sequential”)
* **Block size / IO size** (4K/64K/1M…)
* **Readahead** (filesystem/block layer readahead)
* **Writeback / dirty pages** (page cache)
* **Stripe size / strip size / stripe width**
* **Full-stripe write**
* **Read-Modify-Write (RMW)** (RAID5/6)
* **Write penalty** (RAID)
* **Cache policy**: write-through vs write-back
* **BBU/CacheVault/PLP** (bảo vệ write-back cache)
* **NCQ** (SATA), **TCQ** (SAS), **Multiqueue** (blk-mq)

---

## 4) RAID/HBA/Controller tuning

* **RAID levels**: 0/1/5/6/10/50/60
* **Controller cache** (WB/WT)
* **Disk cache policy**
* **Read policy** (read-ahead / adaptive)
* **Cache bypass**
* **Battery-backed write cache (BBWC)** / **CacheVault**
* **Patrol read** / **Consistency check** (ảnh hưởng performance background)

---

## 5) Filesystem & VM/Virtualization (nếu bạn học OpenStack/KVM)

* **vCPU pinning**
* **Hugepages** (2M/1G)
* **NUMA topology for VM**
* **virtio-blk vs virtio-scsi**
* **IO thread / vhost**
* **OpenStack CPU policy**: dedicated vs shared
* **Overcommit** (CPU/memory)
* **Write amplification** (thin provisioning, COW)

---

## 6) Benchmark/observability keyword (để “đo đúng bệnh”)

* **fio** (block I/O benchmark)
* **iostat**, **pidstat**, **vmstat**
* **perf**, **pmu** (Performance Monitoring Unit)
* **numastat**
* **sar**
* **ethtool -S** (NIC stats)
* **irq / interrupts / softirqs**
* **topology view**: `lstopo` (hwloc)

---

## 7) “Keyword combo” để Google/đọc tài liệu hiệu quả (rất thực dụng)

Bạn ghép theo mẫu sau:

* `NUMA IRQ affinity MSI-X storage performance`
* `megasas MSI-X interrupt affinity numa node`
* `Linux softirq NAPI RSS RPS XPS tuning`
* `RAID5 read-modify-write full stripe write stripe size`
* `readahead stripe size backup workload sequential throughput`
* `fio iodepth numjobs direct=1 aio engine`
* `PCIe numa node root complex device locality`

---

## 8) Nếu bạn muốn 1 nhãn “bao trùm”

Ngành hay gọi mảng này là:

* **Systems Performance Engineering**
* **Linux Performance Tuning**
* **Storage Performance Tuning**
* **Hardware/Platform Optimization**
* **IO Path Optimization**
* **NUMA-aware tuning**

---

Nếu bạn muốn, mình sẽ đề xuất cho bạn **lộ trình học keyword theo tuần** (mỗi ngày 30–45 phút): ngày 1 NUMA+affinity, ngày 2 IRQ/MSI-X, ngày 3 IO scheduler+readahead, ngày 4 RAID stripe/RMW, ngày 5 fio+đọc kết quả… để bạn học “có hệ thống” chứ không lan man.
