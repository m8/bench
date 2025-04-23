#!/bin/bash
# ============================
BENCHMARK="hpcg"
THREADS=20
# ============================

# == Do not edit ==
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RES_DIR=$SCRIPT_DIR/../results/
DATASET_DIR=$SCRIPT_DIR/../datasets/
source $SCRIPT_DIR/_runner.sh

APP_DIR=$APP_DIR/${BENCHMARK}
RES_DIR=$RES_DIR/${BENCHMARK}
DATASET_DIR=$DATASET_DIR/${BENCHMARK}
SUFFIX=""
PRE_CMD=""
# == ==

runner_init_bench

running_program="hpcg"

hpcg_default() {
    pushd $APP_DIR/build/bin
    
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    $PRE_CMD \
    /usr/bin/time -v \
    taskset -c 0-$(echo "$THREADS - 1" | bc) ./xpchg 384 384 384 >> $RES_DIR/${BENCHMARK}${SUFFIX}.log 2>&1

    popd
}

function hpcg_get_wss {
   declare -A T_RSS_HPCG (
        ["huge"]=45
    )

    local graph=${1}
    echo ${T_RSS_GAPBS[$graph]}
}

function get_result_dir {
    echo $RES_DIR/${BENCHMARK}${SUFFIX}.log
}
