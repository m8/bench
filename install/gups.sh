#!/bin/bash
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="$APP_DIR/gupbs"

sudo apt install libopenmpi-dev


mkdir -p $SETUP_DIR

pushd $SETUP_DIR
git clone https://github.com/alexandermerritt/gups .

make -f Makefile.linux

popd
