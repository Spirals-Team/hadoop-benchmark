#!/bin/bash
set -e
source $(dirname $0)/../common.sh

base=$(dirname "$(cd "$(dirname "$0")"; pwd)/$(basename "$0")")
docker $controller_conn build -t hadoop-benchmark-swim "$base/image"

docker $controller_conn run \
  -it \
  --rm \
  --net hadoop-net \
  --name hadoop-benchmark-swim \
  -h hadoop-benchmark-swim \
  hadoop-benchmark-swim
