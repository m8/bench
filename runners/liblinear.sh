#!/bin/bash
# ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APP_DIR=$SCRIPT_DIR/../app_dir/
RES_DIR=$SCRIPT_DIR/../results/
DATASET_DIR=$SCRIPT_DIR/../datasets/
# ---
source $SCRIPT_DIR/_runner.sh

BENCHMARK="liblinear"
THREADS=20
APP_DIR=$APP_DIR/liblinear
RES_DIR=$RES_DIR/liblinear
DATASET_DIR=$DATASET_DIR/liblinear
SUFFIX=""

runner_init_bench

function liblinear_default {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    
    { /usr/bin/time taskset -c 0-$(echo "$THREADS - 1" | bc) ./train -s 6 -m 20 $DATASET_DIR/kdd12 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log; } 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
}

function liblinear_parser {
    grep "system" $RES_DIR/${BENCHMARK}${SUFFIX}.log | awk '{print $1}' | sed 's/elapsed//g'
}