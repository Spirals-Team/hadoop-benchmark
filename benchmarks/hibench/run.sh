#!/bin/bash
set -e

ALL_BENCHMARKS="wordcount sort terasort sleep"

docker build -t hadoop-benchmark-hibench image

if [[ $# -lt 1 ]]; then
  BENCHMARKS=$ALL_BENCHMARKS
else
  BENCHMARKS="$@"
fi

docker run \
  -t \
  --rm \
  --net hadoop-net \
  --name hadoop-benchmark-hibench \
  -h hadoop-benchmark-hibench \
  hadoop-benchmark-hibench \
  --benchmarks "$BENCHMARKS"
