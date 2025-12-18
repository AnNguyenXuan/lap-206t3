## Kiểm tra hiệu năng
```
# Random Read
fio --name=randread_4k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randread \
    --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 \
    --norandommap --group_reporting

fio --name=randread_64k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randread \
    --bs=64k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 \
    --norandommap --group_reporting  --output=randread_64k.txt

fio --name=randread_256k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randread \
    --bs=256k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 \
    --norandommap --group_reporting  --output=randread_256k.txt

# Random Write
fio --name=randwrite_4k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randwrite \
    --bs=4k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 \
    --norandommap --group_reporting  --output=randwrite_4k.txt

fio --name=randwrite_64k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randwrite \
    --bs=64k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 \
    --norandommap --group_reporting  --output=randwrite_64k.txt

fio --name=randwrite_256k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randwrite \
    --bs=256k --time_based --runtime=180 --ramp_time=20 --randrepeat=0 \
    --norandommap --group_reporting  --output=randwrite_256k.txt

# Sequential Read
fio --name=seqread_4k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=read \
    --bs=4k --time_based --runtime=180 --ramp_time=20 \
    --group_reporting  --output=seqread_4k.txt

fio --name=seqread_64k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=read \
    --bs=64k --time_based --runtime=180 --ramp_time=20 \
    --group_reporting  --output=seqread_64k.txt

fio --name=seqread_256k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=read \
    --bs=256k --time_based --runtime=180 --ramp_time=20 \
    --group_reporting  --output=seqread_256k.txt

# Sequential Write
fio --name=seqwrite_4k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=write \
    --bs=4k --time_based --runtime=180 --ramp_time=20 \
    --group_reporting  --output=seqwrite_4k.txt

fio --name=seqwrite_64k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=write \
    --bs=64k --time_based --runtime=180 --ramp_time=20 \
    --group_reporting  --output=seqwrite_64k.txt

fio --name=seqwrite_256k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=write \
    --bs=256k --time_based --runtime=180 --ramp_time=20 \
    --group_reporting  --output=seqwrite_256k.txt

# Random Read/Write 70/30
fio --name=randrw_7030_4k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=70 --bs=4k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_7030_4k.txt

fio --name=randrw_7030_64k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=70 --bs=64k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_7030_64k.txt

fio --name=randrw_7030_256k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=70 --bs=256k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_7030_256k.txt

# Random Read/Write 50/50
fio --name=randrw_5050_4k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=50 --bs=4k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_5050_4k.txt

fio --name=randrw_5050_64k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=50 --bs=64k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_5050_64k.txt

fio --name=randrw_5050_256k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=50 --bs=256k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_5050_256k.txt

# Random Read/Write 4k 30/70
fio --name=randrw_3070_4k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=30 --bs=4k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_3070_4k.txt

fio --name=randrw_3070_64k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=30 --bs=64k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_3070_64k.txt

fio --name=randrw_3070_256k --filename=/dev/sdd --ioengine=libaio --direct=1 \
    --invalidate=1 --iodepth=64 --numjobs=4 --size=4G --rw=randrw \
    --rwmixread=30 --bs=256k --time_based --runtime=180 --ramp_time=20 \
    --randrepeat=0 --norandommap --group_reporting  \
    --output=randrw_3070_256k.txt


Lệnh chạy tất cả trong 1 cấu hình 
fio --output-format=json+ --output=ssd_test.json ssd.fio

```