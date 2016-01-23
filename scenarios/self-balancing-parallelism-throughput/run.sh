#!/bin/bash
set -e

base="$(cd "$(dirname "$0")"; pwd)/$(basename "$0")"

# build image
docker build -t horchata/self-balance-fcl image

# this container needs to be collocated with the controller
target_node=$(docker inspect -f '{{ .Node.Name }}' controller)

docker \
  $(docker-machine config $target_node) \
  run \
  -it \
  --rm \
  --volumes-from controller \
  -v $(docker inspect -f '{{ (index .Mounts 0).Source }}' controller):/controller/collectd \
  -v $(docker inspect -f '{{ (index .Mounts 1).Source }}' controller):/controller/hadoop \
  --net hadoop-net \
  --name self-balance-fcl \
  -h self-balance-fcl \
  horchata/self-balance-fcl \
  bash
