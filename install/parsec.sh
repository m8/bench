#!/bin/bash

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="../app_dir/parsec"

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR && pushd $SETUP_DIR
git clone https://github.com/bamos/parsec-benchmark .
patch -p1 < $SCRIPT_DIR/../patches/parsec.diff
source env.sh

# Don't forget to set PARSECPLAT and PARSECDIR
export PARSECPLAT=x86_64-linux.gcc
export PARSECDIR=$(pwd)

echo "export PARSECDIR=$(pwd)"
echo "export PARSECPLAT=x86_64-linux.gcc"

# == Get inputs script ===
# wget https://raw.githubusercontent.com/damonitor/parsec-benchmark/refs/heads/master/get-inputs
# bash get-inputs -n
# ========================


# Adapted from: https://github.com/sjp38/parsec3_on_ubuntu/blob/master/_build.sh

# == Build the benchmarks ==
# Parsec Benchmarks
for bench in streamcluster blackscholes canneal facesim fluidanimate \
    freqmine raytrace vips x264
do
    parsecmgmt -a build -p "$bench"
done

# Spash2x Benchmarks
for bench in barnes fft lu_cb lu_ncb ocean_cp ocean_ncp \
    radiosity radix volrend water_nsquared water_spatial
do
    parsecmgmt -a build -p "splash2x.$bench"
done


echo "Done installing Parsec benchmarks."

popd
