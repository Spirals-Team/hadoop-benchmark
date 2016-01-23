#!/bin/bash
set -e

if [[ ! -d images/swim ]]; then
  echo "Run from the directory from which images/SWIM is reachable"
  exit 1
fi

docker build -t hadoop-benchmark-swim image

docker run \
  -it \
  --rm \
  --net hadoop-net \
  --name hadoop-benchmark-swim \
  -h hadoop-benchmark-swim \
  hadoop-benchmark-swim
