#!/bin/bash


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
numactl --membind 0 --cpunodebind 0 bin/gupstoy
