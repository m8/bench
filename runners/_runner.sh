#!/bin/bash

function log_basics {
    echo "++++++++++++++++++++"
    echo "Time: $(date)"
    echo "APP_DIR: $APP_DIR"
    echo "SCRIPT_DIR: $SCRIPT_DIR"   
    echo "Benchmark: $BENCHMARK"
    echo "Threads: $THREADS"

    get_machine_details

    echo "++++++++++++++++++++"
}

function get_machine_details {
    echo "----------------"
    echo "Machine details:"
    echo "----------------"
    echo "Host: $(hostname)"
    echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo "Cores: $(lscpu | grep 'CPU(s):' | awk '{print $2}')"
    echo "Kernel: $(uname -r)"
    echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Performance governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
    echo "Scaling min frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)"
    echo "Scaling max frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)"
    echo "Transparent Huge Pages: $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
    echo "Numa hardware: $(numactl --hardware)"
    echo "Prefetcher at core 0:" $(sudo rdmsr 0x1a4)
    echo ""
}

function init_bench {
    mkdir -p $RES_DIR
    mkdir -p $APP_DIR
}

function runner_set_performance {
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    echo 2600000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
    echo 2600000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
}

function runner_restore_system_settings {
    echo "madvise" | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
    echo "Benchmark ended at $(date)"
    echo "Runner exiting ..."
}