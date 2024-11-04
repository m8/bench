#!/bin/bash

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="../app_dir/parsec"

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR

pushd $SETUP_DIR

git clone https://github.com/bamos/parsec-benchmark .

source env.sh

parsecmgmt -a build -p streamcluster
parsecmgmt -a run -p streamcluster -i test -n 2

popd
