#!/bin/bash

function spark_install() {
    sudo apt-get install -y openjdk-11-jdk openjdk-11-jre openjdk-11-jre-headless
    wget -q https://downloads.apache.org/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz
    tar -xzf spark-3.5.5-bin-hadoop3.tgz
    sudo mv spark-3.5.5-bin-hadoop3 /opt/spark
}

function spark_scala_install() {
    sudo apt-get install -y openjdk-11-jdk openjdk-11-jre openjdk-11-jre-headless
    wget -q https://downloads.apache.org/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3-scala2.13.tgz
    tar -xzf spark-3.5.5-bin-hadoop3-scala2.13.tgz
    sudo mv spark-3.5.5-bin-hadoop3-scala2.13 /opt/spark
}

spark_scala_install
