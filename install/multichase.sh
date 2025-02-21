#!/bin/bash
BENCH="multichase"

# ==============
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SETUP_DIR="../app_dir/$BENCH"

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi
mkdir -p $SETUP_DIR
# ==============

pushd $SETUP_DIR
git clone https://github.com/google/multichase .
make