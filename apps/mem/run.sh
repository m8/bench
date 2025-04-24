#!/bin/bash

make clean
make

strides="4096 2048 1024 512 256 128 64 32 16 8"

echo "DRAM"

echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

for stride in $strides; do
    res=$(numactl --membind 0 --cpunodebind 0 ./mem_access $stride | grep "Time taken per element:" | awk '{print $NF}');
    res2=$(numactl --membind 0 --cpunodebind 0 ./mem_access $stride -o | grep "Time taken per element:" | awk '{print $NF}');
    echo "$stride $res $res2"
done

echo ""
echo "CXL"
for stride in $strides; do
    res=$(numactl --membind 2 --cpunodebind 0 ./mem_access $stride);
    res2=$(numactl --membind 2 --cpunodebind 0 ./mem_access $stride);
    echo "$stride $res $res2"
done
