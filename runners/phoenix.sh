#!/bin/bash
# ============================
BENCHMARK="phoenix"
THREADS=8
# ============================

# == Do not edit ==
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

RES_DIR=$SCRIPT_DIR/../results/
DATASET_DIR=$APP_DIR/datasets/phoenix
source $SCRIPT_DIR/_runner.sh

APP_DIR=$APP_DIR/${BENCHMARK}
RES_DIR=$RES_DIR/${BENCHMARK}
DATASET_DIR=$DATASET_DIR/${BENCHMARK}
SUFFIX=""
# == ==

runner_init_bench

inner_benchmarks="histogram linear_regression string_match reverse_index word_count"

# $1: size
function run_benchmark {
    local benchmark=$1
    local size=$2

    command="export MR_NUMPROCS=$THREADS MR_NUMTHREADS=$THREADS; LD_PRELOAD=/usr/local/lib/libjemalloc.so $APP_DIR/tests/$benchmark/$benchmark $DATASET_DIR/${benchmark}_datafiles/$size"
    echo $command
    { time eval $command >> $RES_DIR/${BENCHMARK}${SUFFIX}.log; } 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
}

function run_kmeans {
    command="export MR_NUMPROCS=$THREADS MR_NUMTHREADS=$THREADS; LD_PRELOAD=/usr/local/lib/libjemalloc.so $APP_DIR/tests/kmeans/kmeans -d 8 -c 8192 -p 5000000 -s 40"
    echo $command
    { time eval $command >> $RES_DIR/${BENCHMARK}${SUFFIX}.log; } 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
}

function run_histogram {
    local sizes=("small.bmp" "med.bmp" "large.bmp")
    run_benchmark "histogram" "${sizes[$1]}"
}

function run_word_count {
    local sizes=("word_10MB.txt" "word_100MB.txt" "word_5GB.txt")
    run_benchmark "word_count" "${sizes[$1]}"
}


function phoenix_default {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    run_word_count 2
}