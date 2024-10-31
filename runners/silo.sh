#!/bin/bash
# ============================
BENCHMARK="silo"
THREADS=16
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
    taskset -c 0-$(echo "$THREADS - 1" | bc)  \
        ./out-perf.masstree/benchmarks/dbtest \  
            --verbose --bench tpcc \ 
            --num-threads $THREADS \
            --scale-factor --runtime 60  \
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
        --runtime 30 \
        --scale 32000 \
        --numa-memory 24G \
        2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    popd
}


# Return formatt
# agg_throughput: xxx ops/sec
function silo_parser {
    local file=$RES_DIR/${BENCHMARK}${SUFFIX}.log
    local result=$(grep "agg_throughput" $file | awk '{print $2}')
    echo $result
}