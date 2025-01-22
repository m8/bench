#!/bin/bash
# Source: https://github.com/ANL-CESAR/XSBench.git
# Description: Monte Carlo neutron transport simulation code

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR=$SCRIPT_DIR/../app_dir/graph500

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR

pushd $SETUP_DIR
git clone https://github.com/graph500/graph500 .
git checkout v2-spec

patch -p1 < $SCRIPT_DIR/../patches/graph500.diff
make

# ===========