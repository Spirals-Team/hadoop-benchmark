#!/bin/bash
set -e
source $(dirname $0)/../../common.sh

base=$(dirname "$(cd "$(dirname "$0")"; pwd)/$(basename "$0")")

# build the image at the controller node
docker $controller_conn build -t spark-benchmark-wordcount "$base/image"

docker $controller_conn run \
  -t \
  --rm \
  --net hadoop-net \
  --name hadoop-mapreduce-examples \
  -h hadoop-mapreduce-examples \
  spark-benchmark-wordcount
