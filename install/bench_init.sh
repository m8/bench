#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $APP_DIR
if [ -z "${APP_DIR}" ]; then
    echo "set APP_DIR, exiting..."
    exit 1
fi
SETUP_DIR=$APP_DIR/${BENCHMARK}
mkdir -p $SETUP_DIR

