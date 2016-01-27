#!/bin/bash
set -e

docker run \
  -t \
  --rm \
  --net hadoop-net \
  --name hadoop-mapreduce-examples \
  -h hadoop-mapreduce-examples \
  hadoop-benchmark/hadoop \
  run \
  hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar "$@"
