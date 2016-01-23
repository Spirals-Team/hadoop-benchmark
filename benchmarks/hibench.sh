#!/bin/bash
set -e

ALL_BENCHMARKS="wordcount sort terasort sleep"

if [[ ! -d images/hibench ]]; then
  echo "Run from the directory from which images/hibench is reachable"
  exit 1
fi

# if ! docker inspect hadoop-benchmark/hibench:latest > /dev/null 2>&1; then
docker build -t hadoop-benchmark/hibench images/hibench
# fi

if [[ $# -lt 1 ]]; then
  BENCHMARKS=$ALL_BENCHMARKS
else
  BENCHMARKS="$@"
fi

docker run \
  -t \
  --rm \
  --net hadoop-net \
  --name hadoop-hibench \
  -h hadoop-hibench \
  hadoop-benchmark/hibench \
  --benchmarks "$BENCHMARKS"
