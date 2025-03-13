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

_APP_DIR=$APP_DIR/${BENCHMARK}
_RES_DIR=$RES_DIR/${BENCHMARK}
DATASET_DIR=$DATASET_DIR/${BENCHMARK}
SUFFIX=""
PRE_CMD=""
# == ==

runner_init_bench

# $1: pass: ft bt lu cg mg sp
# $2: workloads: A B C D E
function nas_run {
    __benchmark=$1
    __workload=$2

    pushd $_APP_DIR
    pwd
    echo "Starting benchmark..." > $_RES_DIR/${BENCHMARK}${SUFFIX}.log
    echo "Pre command: $PRE_CMD" >> $_RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $_RES_DIR/${BENCHMARK}${SUFFIX}.log
    $PRE_CMD /usr/bin/time -v taskset -c 0-$(echo "$THREADS - 1" | bc) \
        ${_APP_DIR}/NPB/NPB3.4-OMP/bin/$__benchmark.$__workload.x >> $_RES_DIR/${BENCHMARK}${SUFFIX}.log 2>&1
    popd
}

function nas_get_result_file {
    echo $_RES_DIR/${BENCHMARK}${SUFFIX}.log
}