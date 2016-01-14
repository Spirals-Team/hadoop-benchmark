#!/bin/bash

#docker build -t hadoop_yarn .
#docker build -t hadoop_controlnode controlnode/
#docker build -t hadoop_computenode computenode/
#docker build -t hadoop_clientnode clientnode/

mkdir /Users/spirals/data

docker-machine create --driver virtualbox hadoop-control
echo "$(docker-machine ip hadoop-control) hadoop-control" >> /Users/spirals/data/hosts
docker-machine create --driver virtualbox hadoop-hibench
echo "$(docker-machine ip hadoop-hibench) hadoop-control" >> /Users/spirals/data/hosts
docker-machine create --driver virtualbox hadoop-compute1
echo "$(docker-machine ip hadoop-compute1) hadoop-control" >> /Users/spirals/data/hosts

eval $(docker-machine env hadoop-control)
docker-compose --x-networking -f hadoopControlNode.yml up -d
eval $(docker-machine env hadoop-hibench)
docker-compose --x-networking -f hadoopHibenchNode.yml up -d
eval $(docker-machine env hadoop-compute1)
docker-compose --x-networking -f hadoopComputeNode.yml up -d

eval $(docker-machine env hadoop-hibench)
echo "In Hadoop HiBench Node now!"
docker attach hadoop-hibench
