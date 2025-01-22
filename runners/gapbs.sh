#!/bin/bash
# ============================
BENCHMARK="gapbs"
THREADS=${THREADS:-20}
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
PRE_CMD=""
# == ==
GRAPHS=("twitter.sg" "kron.sg" "urand.sg" "road.sg" "web.sg" "webU.sg")
# == ==

# Commands 
# bfs-twitter pr-twitter cc-twitter bc-twitter sssp-twitter  \
# bfs-web pr-web cc-web bc-web sssp-web\
# bfs-road pr-road cc-road bc-road sssp-road\
# bfs-kron pr-kron cc-kron bc-kron tc-kron sssp-kron\
# bfs-urand pr-urand cc-urand bc-urand tc-urand sssp-urand\
runner_init_bench

running_program=""
function run_gapbs {
    local cmd=$1
    local graph=$2
    local log_suffix=$3
    local extra_args=$4
    running_program=$cmd


    pushd $APP_DIR
    echo "Starting $cmd with graph $graph..." > $RES_DIR/${BENCHMARK}_${cmd}_${log_suffix}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}_${cmd}_${log_suffix}.log

    $PRE_CMD \
    /usr/bin/time -v \
    taskset -c 0-$(echo "$THREADS - 1" | bc) \
    ./$cmd -f benchmark/graphs/$graph $extra_args >> $RES_DIR/${BENCHMARK}_${cmd}_${log_suffix}.log 2>&1
    popd
}

function gapbs_pr {
    run_gapbs "pr" "${1:-"twitter.sg"}" "$SUFFIX" "-n 5 -i1000 -t1e-4"
}

function gapbs_bc {
    run_gapbs "bc" "${1:-"twitter.sg"}" "$SUFFIX" "-i4 -n16"
}

function gapbs_bfs {
    run_gapbs "bfs" "${1:-"twitter.sg"}" "$SUFFIX" "-n64"
}

function gapbs_cc {
    run_gapbs "cc" "${1:-"twitter.sg"}" "$SUFFIX" "-n16"
}

function gapbs_sssp {
    local graph=${1:-"twitter.wsg"}
    local extra_args="-n64 -d2"
    if [ "$graph" == "road.wsg" ]; then
        extra_args="-d50000"
    fi
    run_gapbs "sssp" "$graph" "$SUFFIX" "$extra_args"
}

function gapbs_all {
    SUFFIX="twitter" gapbs_pr "twitter.sg"
    SUFFIX="kron" gapbs_pr "kron.sg"
    SUFFIX="urand" gapbs_pr "urand.sg"
    SUFFIX="road" gapbs_pr "road.sg"

    SUFFIX="twitter" gapbs_bc "twitter.sg"
    SUFFIX="kron" gapbs_bc "kron.sg"
    SUFFIX="urand" gapbs_bc "urand.sg"
    SUFFIX="road" gapbs_bc "road.sg"

    SUFFIX="twitter" gapbs_bfs "twitter.sg"
    SUFFIX="kron" gapbs_bfs "kron.sg"
    SUFFIX="urand" gapbs_bfs "urand.sg"
    SUFFIX="road" gapbs_bfs "road.sg"

    SUFFIX="kron" gapbs_sssp "kron.wsg"
    SUFFIX="urand" gapbs_sssp "urand.wsg"
    SUFFIX="road" gapbs_sssp "road.wsg"
    SUFFIX="web" gapbs_sssp "web.wsg"
}

function get_result_dir {
    echo $RES_DIR/gapbs_${running_program}_${SUFFIX}.log
}