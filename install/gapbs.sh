#!/bin/bash
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="../app_dir/gapbs"

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR

pushd $SETUP_DIR
git clone https://github.com/sbeamer/gapbs .
patch -p1 < $SCRIPT_DIR/../patches/gapbs.diff
make pr; make pr gen-twitter
popd