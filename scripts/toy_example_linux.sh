#!/bin/bash

nvme_dev='/dev/nvme1n1';
echo 0 > /sys/module/blk_mq/parameters/blk_switch_on

# Run L-app
fio --filename=$nvme_dev \
	--name=random_read \
	--ioengine=libaio \
	--direct=1 \
	--rw=randread \
	--gtod_reduce=0 \
	--cpus_allowed_policy=split \
	--size=1G \
	--bs=4k \
	--time_based \
	--runtime=7 \
	--iodepth=1 \
	--cpus_allowed=0 \
	--numjobs=1 \
	--group_reporting > output_linux_lapp &

# Run T-app
fio --filename=$nvme_dev \
        --name=random_read \
        --ioengine=libaio \
        --direct=1 \
        --rw=randread \
        --gtod_reduce=0 \
        --cpus_allowed_policy=split \
        --size=1G \
        --bs=64k \
        --time_based \
        --runtime=7 \
        --iodepth=32 \
        --cpus_allowed=0 \
        --numjobs=1 \
        --group_reporting > output_linux_tapp &

sleep 10

echo "Done."

