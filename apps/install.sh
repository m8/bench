#!/bin/bash
mkdir -p bin

installs="btree"

# == Metis ==

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

# == NAS ==

if [[ $installs =~ "nas" ]]; then

pushd nas/NPB3.4-OMP
benchs="bt cg ep ft is lu mg sp ua dc"
workloads="E D F"
for bench in $benchs; do
    for workload in $workloads; do
        make $bench CLASS=$workload
        cp bin/$bench.$workload.x ../bin/nas_$bench$workload.x
    done
done
popd

fi

# == Btree ==
if [[ $installs =~ "btree" ]]; then

pushd btree
make clean
make -j8
cp btree ../bin/btree
cp btree_omp ../bin/btree_omp
popd

fi
