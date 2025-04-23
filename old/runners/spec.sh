#!/bin/bash
# This benchmark requires a license from SPEC.
# https://www.spec.org/cpu2017/

# ============================
BENCHMARK="spec"
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
# == ==

runner_init_bench

# Benchmarks:
# 603.bwaves_s

# $1: benchmark
function spec_run {
    pushd $APP_DIR
    source shrc

    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    runcpu --config=my.cfg --config=my.cfg --tune=base --size=ref $1 2&>> $RES_DIR/${BENCHMARK}${SUFFIX}.log
}

# $1: benchmark
function spec_custom_run {

    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}/$1.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}/$1.log

    pushd $APP_DIR/benchspec/CPU/$1/run/run_base_refspeed_mytest-m64.0000/

    case $1 in
        "603.bwaves_s")
            killall $(get_bwaves_pid)
            sleep 1
            ./speed_bwaves_base.mytest-m64 bwaves_2.in > $RES_DIR/${BENCHMARK}/${$1}.log 2>&1 &
            ;;
        *)
            echo "Benchmark not found" >&2
            return 1
            ;;
    esac

    pid=$!
    echo $pid
}


function get_bwaves_pid {
    pid=$(ps ax | grep "[s]peed_bwaves_base.mytest-m64 bwaves_2" | grep -v "sh -c" | awk '{print $1}')
    
    if [ -n "$pid" ]; then
        echo "$pid"
        return 0
    else
        echo "Benchmark process not found" >&2
        return 1
    fi
}

function get_result_dir {
    echo $RES_DIR/${BENCHMARK}${SUFFIX}.log
}
