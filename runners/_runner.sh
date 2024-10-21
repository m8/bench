#!/bin/bash

function log_basics {
    echo "===================="
    echo "Time: $(date)"
    echo "===================="
    echo "APP_DIR: $APP_DIR"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    
    echo "Benchmark: $BENCHMARK"
    echo "Threads: $THREADS"
    echo "Numactl:" $(numactl --show)
    echo "Prefetcher at core 0:" $(sudo rdmsr 0x1a4)
    echo "===================="
}

function init_bench {
    mkdir -p $RES_DIR
    mkdir -p $APP_DIR
}

function set_performance {
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    echo 3400000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
    echo 3400000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
}