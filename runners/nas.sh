#!/bin/bash
# ============================
BENCHMARK="nas"
THREADS=${THREADS:-48}
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

function nas_ft {
    pushd $APP_DIR
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    $PRE_CMD taskset -c 0-$(echo "$THREADS - 1" | bc) ./NPB/NPB3.4-OMP/bin/ft.W.x >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    $PRE_CMD taskset -c 0-$(echo "$THREADS - 1" | bc) ./NPB/NPB3.4-OMP/bin/ft.A.x >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    $PRE_CMD taskset -c 0-$(echo "$THREADS - 1" | bc) ./NPB/NPB3.4-OMP/bin/ft.D.x >> $RES_DIR/${BENCHMARK}${SUFFIX}.log
    popd
}