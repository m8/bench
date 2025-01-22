# Memory Intensive Benchmarking Suite (MIBS)

Benchmarks for understanding memory related bottleneceks and optimizations.

- gapbs: graph benchmarks
- liblinear: linear classification
- phoenix2: map-reduce workloads
- xsbench: monte carlo neutron transport simulation
- silo: in memory database / builtin tcpp / ycsb benchmark

install:
```bash 
cd install
bash gapbs.sh
```

usage:
```bash
cd runners
source gapbs.sh && gapbs_pr && gapbs_parser
```
