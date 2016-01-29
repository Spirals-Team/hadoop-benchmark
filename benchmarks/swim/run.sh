#!/bin/bash
set -e

base=$(dirname "$(cd "$(dirname "$0")"; pwd)/$(basename "$0")")
docker build -t hadoop-benchmark-swim "$base/image"

docker run \
  -it \
  --rm \
  --net hadoop-net \
  --name hadoop-benchmark-swim \
  -h hadoop-benchmark-swim \
  spirals/hadoop-benchmark:hadoop-benchmark-swim
