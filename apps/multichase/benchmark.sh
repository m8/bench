#!/bin/bash

strides="4096 2048 1024 512 256 128 64 32 16 8"

echo "DRAM"

for stride in $strides; do
    res=$(numactl --membind 0 --cpunodebind 0 ./multichase -m 2147483648 -s$stride);
    res2=$(numactl --membind 0 --cpunodebind 0 ./multichase -m 2147483648 -s$stride -o);
    echo "$stride $res $res2"
done

echo ""
echo "CXL"

for stride in $strides; do
    res=$(numactl --membind 2 --cpunodebind 0 ./multichase -m 2147483648 -s$stride);
    res2=$(numactl --membind 2 --cpunodebind 0 ./multichase -m 2147483648 -s$stride -o);
    echo "$stride $res $res2"
done