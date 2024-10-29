#!/bin/bash
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="../app_dir/memcached"

sudo apt-get install memcached libmemcached-tools -y


if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

mkdir -p $SETUP_DIR

pushd $SETUP_DIR
popd
