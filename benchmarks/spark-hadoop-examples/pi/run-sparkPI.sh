#!/bin/bash
set -e
source $(dirname $0)/../../common.sh

docker $controller_conn run \
  -t \
  --rm \
  --net hadoop-net \
  --name spark-PI-example \
  -h spark-PI-example \
  hadoop-benchmark/spark \
  run \
  spark-submit --class org.apache.spark.examples.SparkPi /usr/local/spark/examples/jars/spark-examples_2.11-2.1.0.jar "$@"
