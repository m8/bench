#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR=$SCRIPT_DIR/../app_dir/phoenix
DATASET_DIR=$SCRIPT_DIR/../datasets/phoenix

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR
mkdir -p $DATASET_DIR


# ===========

# pushd $SETUP_DIR
# git clone https://github.com/kozyraki/phoenix
# mv phoenix/phoenix-2.0/* .
# rm -rf phoenix
# make -j
# popd

# ===========

pushd $DATASET_DIR

benchmarks="histogram linear_regression string_match reverse_index word_count"

# for bm in $benchmarks; do
#     echo "Downloading $bm"
#     wget http://csl.stanford.edu/~christos/data/$bm.tar.gz  
# done

for bm in $benchmarks; do
    echo "Extracting $bm" in $(pwd)
    tar -xzf $bm.tar.gz
done

popd
