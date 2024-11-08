#!/bin/bash
# ============================
BENCHMARK="silo"
THREADS=20
# ============================

# == Do not edit ==
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APP_DIR=$SCRIPT_DIR/../app_dir/
RES_DIR=$SCRIPT_DIR/../results/
DATASET_DIR=$SCRIPT_DIR/../datasets/
source $SCRIPT_DIR/_runner.sh

APP_DIR=$APP_DIR/${BENCHMARK}
RES_DIR=$RES_DIR/${BENCHMARK}
DATASET_DIR=$DATASET_DIR/${BENCHMARK}
SUFFIX=""
# == ==

runner_init_bench

function silo_tpcc {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    taskset -c 0-$(echo "$THREADS - 1" | bc) \
        ./out-perf.masstree/benchmarks/dbtest \
        --verbose --bench tpcc \
        --num-threads 32 \
        --scale-factor 20 \
        --retry-aborted-transactions \
        --ops-per-worker 10000000 \
        2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    popd
}

function silo_ycsb {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    taskset -c 0-$(echo "$THREADS - 1" | bc) \
        ./out-perf.masstree/benchmarks/dbtest \
        --verbose --bench ycsb \
        --num-threads $THREADS \
        --runtime 60 \
        --scale-factor 32000 \
        --numa-memory 24G 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    popd
}

# $1: zipfian constant
# Values: 0.0, 0.1, 0.99, 1.5, -1
# Default: 0.99
function silo_ycsb_zipfian {
    local zipfian=${1:-0.99}
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    taskset -c 0-$(echo "$THREADS - 1" | bc) \
        ./out-perf.masstree/benchmarks/dbtest \
        --verbose --bench ycsb \
        --num-threads $THREADS \
        --runtime 60 \
        --scale-factor 32000 \
        --numa-memory 24G \
        -o "--zipfian-alpha $zipfian" 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    popd
}


# Return format
# agg_throughput: xxx ops/sec
function silo_parser {
    local file=$RES_DIR/${BENCHMARK}${SUFFIX}.log
    local result=$(grep "agg_throughput" $file | awk '{print $2}')
    echo $result
}