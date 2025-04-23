#!/bin/bash
# ==
# This is a script to maintain 
# common graphs and datasets
# for the benchmarks
# ==
DATASET_DIR=/scratch/musa/datasets
BENCHS="canneal"
APPS_DIR="/home/unal/Documents/memory_behaviors/bench/apps"

if [ -z "$APPS_DIR" ]; then
    echo "APPS_DIR is not set."
    exit 1
fi
cd $APPS_DIR


if [[ $BENCHS =~ "gapbs" ]]; then
    mkdir -p $DATASET_DIR/gapbs
    mkdir -p $DATASET_DIR/gapbs/raw
    pushd gapbs/benchmark    
    make GRAPH_DIR=$DATASET_DIR/gapbs RAW_GRAPH_DIR=$DATASET_DIR/gapbs/raw -f bench.mk bench-graphs;
fi

if [[ $BENCHS =~ "liblinear" ]]; then
    mkdir -p $DATASET_DIR/liblinear
    pushd liblinear
    wget https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/kdd12.xz
    unxz -d kdd12.xz
    popd
fi

if [[ $BENCHS =~ "canneal" ]]; then
    mkdir -p $DATASET_DIR/canneal
    CANNEAL_GEN_SCRIPT=$APPS_DIR/parsec/canneal_netlist.pl

    pushd $DATASET_DIR/canneal
    $CANNEAL_GEN_SCRIPT 10000 11000 100000000 > canneal.netlist

    popd
fi



if [[ $BENCHS =~ "blast" ]]; then
    BLAST_BIN=$APPS_DIR/blast/bin
    
    # WORKDIR /data/refseq_protein

    # RUN update_blastdb.pl --source gcp refseq_protein

    # WORKDIR /data/cho_protein

    # RUN wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/668/045/GCF_003668045.1_CriGri-PICR/GCF_003668045.1_CriGri-PICR_protein.faa.gz && gunzip *.gz && makeblastdb -in GCF_003668045.1_CriGri-PICR_protein.faa -dbtype prot

    # RUN useradd -ms /bin/bash benchmarking
    # USER benchmarking
    # WORKDIR /home/benchmarking
    # https://github.com/hhefzi/blast_benchmarking/blob/master/docker/benchmarking.dockerfile
    mkdir -p $DATASET_DIR/blast/
    mkdir -p $DATASET_DIR/blast/refseq_protein/
    mkdir -p $DATASET_DIR/blast/cho_protein/
    
    pushd $DATASET_DIR/blast/refseq_protein/
    ${BLAST_BIN}/update_blastdb.pl --source gcp refseq_protein
    popd

    pushd $DATASET_DIR/blast/cho_protein/
    wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/668/045/GCF_003668045.1_CriGri-PICR/GCF_003668045.1_CriGri-PICR_protein.faa.gz
    gunzip GCF_003668045.1_CriGri-PICR_protein.faa.gz
    ${BLAST_BIN}/makeblastdb -in GCF_003668045.1_CriGri-PICR_protein.faa -dbtype prot 
    popd
fi



