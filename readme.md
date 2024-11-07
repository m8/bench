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
source gapbs.sh && gapbs_default && gapbs_parser
```


## Suite 1

```
cd install
bash gapbs.sh && bash metis.sh && bash silo.sh
```

```

```

### Will it scale