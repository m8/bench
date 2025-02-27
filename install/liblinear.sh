#!/bin/bash
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="$APP_DIR/liblinear"
DATASET_DIR="/scratch/musa/datasets/liblinear"

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR
mkdir -p $DATASET_DIR

# ====
pushd $SETUP_DIR
wget https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/multicore-liblinear/liblinear-multicore-2.48.zip
unzip liblinear-multicore-2.47.zip 
mv liblinear-multicore-2.47/* .

make
popd
# ====

# ====
pushd $DATASET_DIR
wget https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/kdd12.xz
unxz -d kdd12.xz
popd
# ====