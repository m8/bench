#!/bin/bash
# ============================
BENCHMARK="liblinear"
THREADS=20
# ============================

# == Do not edit ==
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RES_DIR=$SCRIPT_DIR/../results/
DATASET_DIR=/scratch/musa/datasets/
source $SCRIPT_DIR/_runner.sh

APP_DIR=$APP_DIR/${BENCHMARK}
RES_DIR=$RES_DIR/${BENCHMARK}
DATASET_DIR=$DATASET_DIR/${BENCHMARK}
SUFFIX=""
PRE_CMD=""
# == ==


runner_init_bench

function liblinear_default {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    
    { $PRE_CMD /usr/bin/time taskset -c 0-$(echo "$THREADS - 1" | bc) ./train -s 6 -m 20 $DATASET_DIR/kdd12 >> $RES_DIR/${BENCHMARK}${SUFFIX}.log 2>&1; } >> $RES_DIR/${BENCHMARK}${SUFFIX}.log 2>&1

}

function liblinear_parser {
    grep "system" $RES_DIR/${BENCHMARK}${SUFFIX}.log | awk '{print $1}' | sed 's/elapsed//g'
}

function get_result_dir {
    echo $RES_DIR/${BENCHMARK}${SUFFIX}.log
}