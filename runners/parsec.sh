#!/bin/bash
# ============================
BENCHMARK="parsec"
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

runner_init_bench

# $1: benchmark
# $2: input size, default: simdev | available: test, simdev, simsmall, simmedium, simlarge
function parsec_default_run {
    pushd $APP_DIR
    
    source env.sh
    export PARSECPLAT=x86_64-linux.gcc
    export PARSECDIR=$APP_DIR

    PROG_NAME=$1
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    # === Check this ====
    # Setting thread to 16 for splash benchmarks
    THREADS=16
    # ====================

    $PRE_CMD \
    taskset -c 0-$((THREADS-1)) \
    parsecmgmt -a run -p $1 -i $2 -n $THREADS >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    popd
}

function parsec_splash_run {
    pushd $APP_DIR
    
    source env.sh
    
    export PARSECPLAT=x86_64-linux.gcc
    export PARSECDIR=$APP_DIR


    # === Check this ====
    # Setting thread to 16 for splash benchmarks
    THREADS=16
    # ====================

    PROG_NAME=$1
    echo "Starting benchmark..." > $RES_DIR/${BENCHMARK}${SUFFIX}.log
    runner_log_basics >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    $PRE_CMD \
    taskset -c 0-$((THREADS-1)) \
    parsecmgmt -a run -p splash2x.$1 -i $2 -n $THREADS >> $RES_DIR/${BENCHMARK}${SUFFIX}.log

    popd
}

function get_runtime_ms {
    local logfile=$1
    # grep "real" "$logfile" | awk '{print $2}' | sed 's/s//'
    val=$(grep "real" "$logfile" | awk '{print $2}' | sed 's/s//')    
    echo $(convert_to_ms "$val")
}


# Example usage:
# parsec_run_average "blackscholes" "native" 5
# parsec_run_average "fft" "native" 5 <true>  # For splash benchmarks, remove <>
function parsec_run_average {
    local benchmark=$1
    local input=$2
    local n_runs=$3
    local is_splash=${4:-false}
    local sum=0
    local times=()

    echo "Running $benchmark $n_runs times..."
    
    PREV_SUFFIX=$SUFFIX
    for ((i=1; i<=$n_runs; i++)); do
        echo "Run $i/$n_runs"
        SUFFIX="$PREV_SUFFIX-$i"

        if [ "$is_splash" = true ]; then
            parsec_splash_run "$benchmark" "$input"
        else
            parsec_default_run "$benchmark" "$input"
        fi
        
        local runtime=$(get_runtime_ms "$(get_result_dir)")
        echo "Runtime: $runtime"
        times+=($runtime)
        sum=$(echo "$sum + $runtime" | bc -l)
    done

    local avg=$(echo "scale=3; $sum / $n_runs" | bc -l)
    avg=$(echo "scale=3; $avg / 1000" | bc -l)
    
    local logfile=$(get_result_dir)
    echo -e "\nResults from $n_runs runs:" >> "$logfile"
    echo "Individual times: ${times[*]}" >> "$logfile"
    echo "Average runtime: $avg seconds" >> "$logfile"

    SUFFIX=$PREV_SUFFIX
    combine_logs "$PREV_SUFFIX" "$n_runs"
}

function combine_logs {
    local prev_suffix=$1
    local n_runs=$2
    local logfile=$(get_result_dir)
    echo -e "\nCombining logs..." > "$logfile"
    for ((i=1; i<=$n_runs; i++)); do
        cat $RES_DIR/${BENCHMARK}${prev_suffix}-${i}.log >> "$logfile"
        rm $RES_DIR/${BENCHMARK}${prev_suffix}-${i}.log
    done
}

function convert_to_ms() {
    local time_str="$1"
    local minutes=$(echo "$time_str" | cut -d'm' -f1)
    local seconds=$(echo "$time_str" | cut -d'm' -f2)    
    local ms=$(echo "scale=0; ($minutes * 60 + $seconds) * 1000" | bc)
    echo "$ms"
}

function get_result_dir {
    echo $RES_DIR/${BENCHMARK}${SUFFIX}.log
}