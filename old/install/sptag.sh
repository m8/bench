#!/bin/bash
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -z ${APP_DIR+x} ]; then
    echo "APP_DIR is not set. Please set APP_DIR in your environment"
    exit 1
fi

SETUP_DIR="$APP_DIR/sptag"

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR && cd $SETUP_DIR

git clone --recursive https://github.com/microsoft/SPTAG .
mkdir build && cd build && cmake .. && make -j 16 && cd ..

