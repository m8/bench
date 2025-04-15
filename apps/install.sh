#!/bin/bash
mkdir -p bin

installs="hashjoin"

# ================
# == Liblinear  ==
# ================
if [[ $installs =~ "liblinear" ]]; then
pushd liblinear
make clean
make -j8
cp train ../bin/liblinear_train
cp predict ../bin/liblinear_predict
popd
fi
# ================

# ================
# == Multichase ==
# ================
if [[ $installs =~ "multichase" ]]; then
pushd multichase
make clean && make -j8
cp multichase ../bin/multichase
cp multiload ../bin/multiload
popd
fi
# ================

# ===============
# == Hash Join ==
# ===============
if [[ $installs =~ "hashjoin" ]]; then
pushd hashjoin
make clean
make -j8
cp hashjoin ../bin/hashjoin
cp hashjoin ../bin/hashjoin2
popd
fi
# ===============


# ================
# == XSBench ==
# ================
if [[ $installs =~ "xsbench" ]]; then
pushd xsbench/openmp-threading
make clean && make -j8
cp XSBench ../../bin/xsbench
popd
fi
# ================


# ================
# == Metis ==
# ================
if [[ $installs =~ "metis" ]]; then
pushd metis
./configure
make clean && make -j8
objs="wrmem kmeans pca matrix_mult hist linear_regression"
for obj in $objs; do
    cp obj/$obj ../bin/metis_$obj
done
popd
fi
# ================


# ===============
# == NAS ==
# ===============
if [[ $installs =~ "nas" ]]; then
pushd nas/NPB3.4-OMP
benchs="bt cg ep ft is lu mg sp ua dc"
workloads="D"
# workloads="E D F"
for bench in $benchs; do
    for workload in $workloads; do
        make $bench CLASS=$workload
        cp bin/$bench.$workload.x ../../bin/nas_$bench.$workload.x
    done
done
popd
fi
# ==============


# ==============
# == Btree ==
# ==============
if [[ $installs =~ "btree" ]]; then
pushd btree
make clean
make -j8
cp btree ../bin/btree
cp btree_omp ../bin/btree_omp
popd
fi
# ==============


# ==============
# == Silo ==
# ==============
if [[ $installs =~ "silo" ]]; then
rm ../bin/silo
pushd silo
make clean
CXX=g++-9 MODE=perf make -j dbtest
cp out-perf.masstree/benchmarks/dbtest ../bin/silo
popd
fi
# ==============


# ==============
# == GUPS ==
# ==============
if [[ $installs =~ "gups" ]]; then
pushd gups
make clean
make -j8
cp gupstoy ../bin/gupstoy
cp gups ../bin/gups
fi