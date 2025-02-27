#!/bin/bash
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SETUP_DIR="$APP_DIR/nas"
mkdir -p $SETUP_DIR

pushd $SETUP_DIR
wget https://www.nas.nasa.gov/assets/npb/NPB3.4.3.tar.gz
tar -xvf NPB3.4.3.tar.gz
rm NPB3.4.3.tar.gz
mv NPB3.4.3 NPB

pushd NPB/NPB3.4-OMP
cp config/suite.def.template config/suite.def
cp config/make.def.template config/make.def

make ft CLASS=W
make ft CLASS=A
make ft CLASS=D

popd
