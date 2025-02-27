#!/bin/bash
# ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RES_DIR=$SCRIPT_DIR/../results/
DATASET_DIR=$SCRIPT_DIR/../datasets/
# ---
source $SCRIPT_DIR/_runner.sh

BENCHMARK="memcached"
MEMCACHED_BIN="memcached"

# Initial checks
if ! command -v memtier_benchmark &> /dev/null
then
    echo "memtier_benchmark could not be found"
    exit
fi


runner_init_bench


# $1: Size of db: default 200MB
# $2: Size of the object: default 64B
function setup_memcached_database {
    size_db=200
    obj_size=64

    # check if parameters are passed
    if [ ! -z "$1" ]; then
        size_db=$1
    fi
    if [ ! -z "$2" ]; then
        obj_size=$2
    fi

    sudo killall -9 memcached
    sudo systemctl stop memcached

    TOTAL_KEYS=$((size_db * 1024 * 1024 / obj_size))
    MEMCACHED_MEMORY=$((size_db+200))
    echo "mem: $MEMCACHED_MEMORY"

    $MEMCACHED_BIN -d -m $MEMCACHED_MEMORY -p 11211 -t 32 &
    sleep 2
    memcached_pid=$(pidof memcached)
    echo "Memcached PID: $memcached_pid"
    sleep 5

    memtier_benchmark \
    --protocol=memcache_binary \
    --server=localhost \
    --port=11211 \
    --clients=8 \
    --threads=64 \
    --data-size=$obj_size \
    --key-minimum=1 \
    --key-maximum=$TOTAL_KEYS \
    --key-pattern=R:R \
    --ratio=1:0 \
    --requests=$TOTAL_KEYS \
    --pipeline=1000

    sleep 2
}