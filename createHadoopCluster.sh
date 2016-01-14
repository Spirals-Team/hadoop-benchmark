#!/bin/bash

#docker build -t hadoop_yarn .
#docker build -t hadoop_controlnode controlnode/
#docker build -t hadoop_computenode computenode/
#docker build -t hadoop_clientnode clientnode/

mkdir /Users/spirals/data

docker-machine create --driver virtualbox hadoop-control
docker-machine create --driver virtualbox hadoop-hibench
docker-machine create --driver virtualbox hadoop-compute1

eval $(docker-machine env hadoop-control)
docker pull zhangbbo/hadoop-benchmark:hadoop-controlnode-multinodes
docker-compose --x-networking -f hadoopControlNode.yml up -d

eval $(docker-machine env hadoop-hibench)
docker pull zhangbbo/hadoop-benchmark:hadoop-hibenchnode-multinodes
docker-compose --x-networking -f hadoopHibenchNode.yml up -d

eval $(docker-machine env hadoop-compute1)
docker pull zhangbbo/hadoop-benchmark:hadoop-computenode-multinodes
docker-compose --x-networking -f hadoopComputeNode.yml up -d

echo "Collect Hostname IP maping."
echo "$(docker-machine ip hadoop-control) hadoop-control" >> /Users/spirals/data/hosts
echo "$(docker-machine ip hadoop-hibench) hadoop-hibench" >> /Users/spirals/data/hosts
echo "$(docker-machine ip hadoop-compute1) $(docker ps -q -l)" >> /Users/spirals/data/hosts

echo "Distribute Hostname IP maping."
docker $(docker-machine config hadoop-control) exec hadoop-controlnode /bin/bash -c "sh /getMaping.sh"
docker $(docker-machine config hadoop-hibench) exec hadoop-hibenchnode /bin/bash -c "sh /getMaping.sh"
docker $(docker-machine config hadoop-compute1) exec $(docker $(docker-machine config hadoop-compute1) ps -q -l) /bin/bash -c "sh /getMaping.sh"

eval $(docker-machine env hadoop-hibench)
echo "In Hadoop HiBench Node now!"
docker attach hadoop-hibenchnode
