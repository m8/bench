#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SPARK=/opt/spark/bin/spark-submit
BENCHMARK_JAR=$SCRIPT_DIR/target/scala-2.13/movielens-als-2.0.jar
DATASET=$SCRIPT_DIR/datasets/ml-latest-small/
RATINGS=$SCRIPT_DIR/datasets/ml-latest-small/myratings.csv


$SPARK --class MovieLensALS \
       ${BENCHMARK_JAR} \ 
       $DATASET $RATINGS