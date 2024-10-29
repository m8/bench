#!/bin/bash
# ============================
BENCHMARK="liblinear"
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

function liblinear_default {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    
    { /usr/bin/time taskset -c 0-$(echo "$THREADS - 1" | bc) ./train -s 6 -e 0.01 -m 28 $DATASET_DIR/kdda 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log; } 2>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
}

function liblinear_parser {
    grep "system" $RES_DIR/${BENCHMARK}${SUFFIX}.log | awk '{print $1}' | sed 's/elapsed//g'
}