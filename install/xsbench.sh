#!/bin/bash
# Source: https://github.com/ANL-CESAR/XSBench.git
# Description: Monte Carlo neutron transport simulation code

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR=$SCRIPT_DIR/$APP_DIR/xsbench

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR

pushd $SETUP_DIR
git clone https://github.com/ANL-CESAR/XSBench.git .
cd openmp-threading
make -j
popd

# ===========