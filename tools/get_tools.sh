#!/bin/bash
set -eux

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SOURCE_DIR=$SCRIPT_DIR/source
BIN_DIR=$SCRIPT_DIR/bin

mkdir -p $SOURCE_DIR
mkdir -p $BIN_DIR

tools="wss"

# PCM
if [[ $tools == *"pcm"* ]]; then
    pushd $SOURCE_DIR
    echo "Installing PCM"
    git clone https://github.com/intel/pcm.git
    cd pcm
    mkdir build
    cd build
    cmake ..
    make -j
    echo "PCM installed"
    popd
fi

# CAT
if [[ $tools == *"cat"* ]]; then
    pushd $SOURCE_DIR

    echo "Installing cat"
    git clone https://github.com/intel/intel-cmt-cat
    cd intel-cmt-cat
    make -j

    cp pqos/pqos $BIN_DIR
    echo "cat installed"
    popd
fi

# MLC
if [[ $tools == *"mlc"* ]]; then
    pushd $SOURCE_DIR
    mkdir -p mlc && cd mlc
    
    echo "Installing MLC"

    if [ ! -f mlc_v3.10.tgz ]; then
        wget https://downloadmirror.intel.com/763324/mlc_v3.10.tgz
        tar -xvf mlc_v3.10.tgz
    fi
    
    cp Linux/mlc $BIN_DIR
    echo "MLC installed"
    popd
fi

# WSS
if [[ $tools == *"wss"* ]]; then
    pushd $SOURCE_DIR
    echo "Installing WSS"
    git clone https://github.com/brendangregg/wss/
    popd
fi