#!/bin/bash
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="$APP_DIR/silo"

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR

pushd $SETUP_DIR

sudo apt-get install \
    libdb++-dev \
    libaio-dev 

if [ -z "$(ls -A $SETUP_DIR)" ]; then
    git clone https://github.com/stephentu/silo .
fi

patch -p1 < $SCRIPT_DIR/../patches/silo.diff

# For some reasons, newer g++ is not working while compiling the code
# use g++-9
CXX=g++-9 MODE=perf make -j dbtest

popd

