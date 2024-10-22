#!/bin/bash
# Source: https://github.com/ydmao/Metis
# Description: In-memory map reduce benchmark

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR=$SCRIPT_DIR/../app_dir/metis

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR

pushd $SETUP_DIR
git clone https://github.com/ydmao/Metis .
./configure --with-malloc=jemalloc
make -j
popd

# ===========