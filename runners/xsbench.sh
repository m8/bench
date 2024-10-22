#!/bin/bash
# ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APP_DIR=$SCRIPT_DIR/../app_dir/
RES_DIR=$SCRIPT_DIR/../results/
DATASET_DIR=$SCRIPT_DIR/../datasets/
# ---
source $SCRIPT_DIR/_runner.sh

BENCHMARK="xsbench"
THREADS=20
APP_DIR=$APP_DIR/${BENCHMARK}
RES_DIR=$RES_DIR/${BENCHMARK}
SUFFIX=""

runner_init_bench

run_xsbench_default() {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    taskset -c 0-$(echo "$THREADS - 1" | bc) ./openmp-threading/XSBench -t 20 -g 130000 -p 30000000 >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
}

run_xsbench_default

