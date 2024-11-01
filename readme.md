
several scripts to run different benchmarks

- gapbs: graph benchmarks
- liblinear: linear classification
- phoenix2: map-reduce workloads
- xsbench: monte carlo neutron transport simulation
- silo: in memory database / builtin tcpp / ycsb benchmark

install:
```bash 
cd install
bash install_gapbs.sh
```

usage:
```bash
cd runners
source gapbs.sh && gapbs_default && gapbs_parser
```
