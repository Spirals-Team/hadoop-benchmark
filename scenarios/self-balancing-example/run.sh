#!/bin/bash
set -e

#base="$(cd '$(dirname '$0')'; pwd)/$(basename '$0')"

# this container needs to be collocated with the controller
target_node=$(docker inspect -f '{{ .Node.Name }}' controller)

# build image
docker $(docker-machine config $target_node) build -t horchata/self-balance-fcl image


docker \
  $(docker-machine config $target_node) \
  run \
  -it \
  --rm \
  --net hadoop-net \
  --name self-balance-fcl \
  -h self-balance-fcl \
  horchata/self-balance-fcl \
  bash
