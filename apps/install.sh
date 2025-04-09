#!/bin/bash

mkdir -p bin


# == Metis ==

pushd metis
./configure
make clean && make -j8
objs="wrmem kmeans pca matrix_mult hist linear_regression"
for obj in $objs; do
    mv obj/$obj ../bin/metis_$obj
done
popd

# == NAS ==

pushd nas/NPB3.4-OMP
# bt", "cg", "ep", "ft", "is", "lu",
#                              "mg", "sp", "ua", or "dc"
benchs="bt cg ep ft is lu mg sp ua dc"
workloads="E D F"
for bench in $benchs; do
    for workload in $workloads; do
        make $bench CLASS=$workload
        mv bin/$bench.$workload.x ../bin/nas_$bench$workload.x
    done
done
popd

popd