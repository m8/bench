#!/bin/bash

# ==
# This is a script to maintain 
# common graphs and datasets
# for the benchmarks
# ==

DATASET_DIR=/scratch/musa/datasets
BENCHS="liblinear"

if [[ $BENCHS =~ "gapbs" ]]; then
    mkdir -p $DATASET_DIR/gapbs
    mkdir -p $DATASET_DIR/gapbs/raw
    pushd gapbs/benchmark    
    make GRAPH_DIR=$DATASET_DIR/gapbs RAW_GRAPH_DIR=$DATASET_DIR/gapbs/raw -f bench.mk bench-graphs;
fi

if [[ $BENCHS =~ "liblinear" ]]; then
    mkdir -p $DATASET_DIR/liblinear
    pushd liblinear
    wget https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/kdd12.xz
    unxz -d kdd12.xz
    popd
fi



