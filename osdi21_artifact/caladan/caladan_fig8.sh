#!/bin/bash

# Example usage: ./run_varyload.sh varyload-remoteram 192.168.10.115:5000 192.168.10.116:5000 60 $((32*1024)) 2

config="fig8"
thru_target="192.168.10.115:5000"
lat_target="192.168.10.116:5000"
duration=60
thru_sz=$((32*1024))
thru_qd=2
lat_sz=$((4*1024))
lat_qd=1
num_use_cores=6

# Warmup
echo "Starting warmup"
./run_apps.sh $config-warmup $thru_target $lat_target $duration $thru_sz $thru_qd 6 0 $num_use_cores;

for qd in 1 2 4 8; do

    echo "Starting $config-qd$qd";
    ./run_apps.sh $config-qd$qd $thru_target $lat_target $duration $thru_sz $qd 6 6 $num_use_cores;
    sleep 10;

done
