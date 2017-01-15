#!/bin/bash
set -e
source $(dirname $0)/../common.sh

# benchmark settings
ALL_BENCHMARKS="wordcount sort terasort sleep"

base=$(dirname "$(cd "$(dirname "$0")"; pwd)/$(basename "$0")")

# build the image at the controller node
docker $controller_conn build -t hadoop-benchmark-hibench "$base/image"

if [[ $# -lt 1 ]]; then
  BENCHMARKS=$ALL_BENCHMARKS
else
  BENCHMARKS="$@"
fi

# run the benchmark at the controller node
docker $controller_conn run \
  -it \
  --rm \
  --net hadoop-net \
  --name hadoop-benchmark-hibench \
  -h hadoop-benchmark-hibench \
  hadoop-benchmark-hibench \
  --benchmarks "$BENCHMARKS"
