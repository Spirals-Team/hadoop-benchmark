#!/bin/bash
set -e

if [[ ! -d images/swim ]]; then
  echo "Run from the directory from which images/SWIM is reachable"
  exit 1
fi

docker build -t hadoop-benchmark/swim images/swim

docker run \
  -it \
  --rm \
  --net hadoop-net \
  --name hadoop-swim \
  -h hadoop-swim \
  hadoop-benchmark/swim
