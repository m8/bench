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

function silo_default {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    taskset -c 0-$(echo "$THREADS - 1" | bc) ./out-perf.masstree/benchmarks/dbtest  --verbose --bench tpcc --num-threads 8 --scale-factor 28 --runtime 30 --numa-memory 24G
}


# Return formatt
# Average Time:        xxx.xx
function silo_parser {
    grep "Average Time" $RES_DIR/gapbs${SUFFIX}.log | awk '{print $3}'       
}