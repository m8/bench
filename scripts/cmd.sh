#!/bin/bash

# ==================
# GAPBS CMDs
# ==================
numactl --membind 0 --cpunodebind 0 bin/gapbs bfs -n 1000000 -e 10000000 -p 16 -r 1
numactl --membind 0 --cpunodebind 0 bin/gapbs pr -g 29 -n 20 -i 20
numactl --membind 0 --cpunodebind 0 bin/gapbs cc -g 29 -n 20 -i 20

# ==============
# NAS CMDs
# ==============
numactl --membind 0 --cpunodebind 0 bin/nas_bt.D.x
numactl --membind 0 --cpunodebind 0 bin/nas_cg.D.x
numactl --membind 0 --cpunodebind 0 bin/nas_ep.D.x
numactl --membind 0 --cpunodebind 0 bin/nas_ft.D.x
numactl --membind 0 --cpunodebind 0 bin/nas_lu.D.x
numactl --membind 0 --cpunodebind 0 bin/nas_mg.D.x
numactl --membind 0 --cpunodebind 0 bin/nas_sp.D.x
numactl --membind 0 --cpunodebind 0 bin/nas_ua.D.x


# ==============
# Btree CMDs
# ==============
numactl --membind 0 --cpunodebind 0 bin/btree_omp


# ============
# Silo CMDs
# ============
numactl --membind 0 --cpunodebind 0 bin/silo_dbtest --verbose --bench tpcc --num-threads 20 --scale-factor 20 --retry-aborted --ops-per-worker 10000000
# YCSB-A
numactl --membind 0 --cpunodebind 0 bin/silo_dbtest --verbose --bench ycsb --num-threads 20 --runtime 60 --scale-factor 32000 --numa-memory 24G -o "-w 50,50,0,0"
# YCSB-B
numactl --membind 0 --cpunodebind 0 bin/silo_dbtest --verbose --bench ycsb --num-threads 20 --runtime 60 --scale-factor 32000 --numa-memory 24G -o "-w 95,5,0,0"
# YCSB-E
numactl --membind 0 --cpunodebind 0 bin/silo_dbtest --verbose --bench ycsb --num-threads 20 --runtime 60 --scale-factor 32000 --numa-memory 24G -o "-w 0,5,95,0"
numactl --membind 0 --cpunodebind 0 bin/silo_dbtest --verbose --bench ycsb --num-threads 20 --runtime 60 --scale-factor 32000 --numa-memory 24G -o "--zipfian-alpha 0.99"


# ==============
# XSBench CMDs
# ==============
numactl --membind 0 --cpunodebind 0 bin/XSBench 
# ==============

# ==============
# GUPS CMDs
# ==============
numactl --membind 0 --cpunodebind 0 bin/gupstoy 32 5000000 1024


# ==============
# Parsec CMDs
# ==============
# -p: thread count
numactl --membind 0 --cpunodebind 0 bin/parsec_ocean_cp -n4098 -p 16 -e1e-07 -r10000 -t14400
numactl --membind 0 --cpunodebind 0 bin/parsec_ocean_ncp -n4098 -p 16 -e1e-07 -r10000 -t14400


# ==============
# Multichase CMDs
# ==============
numactl --membind 0 --cpunodebind 0 ./multichase -m 2147483648 -s64;
numactl --membind 0 --cpunodebind 0 ./multichase -m 2147483648 -s64 -o;

numactl --membind 2 --cpunodebind 0 ./multichase -m 2147483648 -s64;
numactl --membind 2 --cpunodebind 0 ./multichase -m 2147483648 -s64 -o;
