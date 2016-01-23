#!/bin/bash
set -e

docker run \
  -it \
  --rm \
  --net hadoop-net \
  --name hadoop-console \
  -h hadoop-console \
  hadoop-benchmark/hadoop \
  console
