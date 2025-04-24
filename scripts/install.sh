#!/bin/bash
mkdir -p bin

APPS_DIR="/home/unal/Documents/memory_behaviors/bench/apps"

if [ -z "$APPS_DIR" ]; then
    echo "APPS_DIR is not set."
    exit 1
fi

cd $APPS_DIR
mkdir -p bin

installs="nas"

# ================
# == Gapbs  ==
# ================
if [[ $installs =~ "gapbs" ]]; then
pushd gapbs
make clean
make -j16
cp bfs ../bin/gapbs_bfs
cp pr ../bin/gapbs_pr
cp cc ../bin/gapbs_cc
cp sssp ../bin/gapbs_sssp
cp tc ../bin/gapbs_tc
popd
fi


# ================
# == Parsec  ==
# ================
if [[ $installs =~ "parsec" ]]; then
pushd parsec

source env.sh
export PARSECPLAT=x86_64-linux.gcc
export PARSECDIR=$(pwd)
for bench in streamcluster blackscholes canneal facesim fluidanimate \
    freqmine raytrace vips x264
do
    parsecmgmt -a build -p "$bench"
    cp pkgs/apps/$bench/inst/x86_64-linux.gcc.gcc/bin/$bench ../bin/parsec_$bench
    cp pkgs/kernels/$bench/inst/x86_64-linux.gcc.gcc/bin/$bench ../bin/parsec_$bench
done

# Spash2x Benchmarks
for bench in barnes fft lu_cb lu_ncb ocean_cp ocean_ncp \
    radiosity radix volrend water_nsquared water_spatial
do
    parsecmgmt -a build -p "splash2x.$bench"
    cp ext/splash2x/apps/$bench/inst/x86_64-linux.gcc.gcc/bin/$bench ../bin/parsec_$bench
    cp ext/splash2x/kernels/$bench/inst/x86_64-linux.gcc.gcc/bin/$bench ../bin/parsec_$bench
done

popd
fi

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
benchs="mg bt cg ep ft is lu sp ua dc"
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
# cp gups ../bin/gups
fi