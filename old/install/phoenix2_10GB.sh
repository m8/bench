#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

DATASET_DIR=$SCRIPT_DIR/../datasets/phoenix

if [ "$#" -eq 1 ]; then
    SETUP_DIR=$1
fi

pushd $DATASET_DIR

cd word_count_datafiles

if [ ! -f "word_100MB.txt" ]; then
    echo "First download the 100MB file"
    exit 1
fi

rm -f word_5GB.txt

for i in {1..50}; do
    cat word_100MB.txt >> word_5GB.txt
    truncate -s -1 word_5GB.txt
done

popd
