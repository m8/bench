#!/bin/bash

mkdir -p datasets
wget http://files.grouplens.org/datasets/movielens/ml-latest.zip
wget http://files.grouplens.org/datasets/movielens/ml-latest-small.zip

unzip ml-latest.zip -d datasets
unzip ml-latest-small.zip -d datasets
