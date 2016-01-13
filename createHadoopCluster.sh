#!/bin/bash

#docker build -t hadoop_yarn .
#docker build -t hadoop_controlnode controlnode/
#docker build -t hadoop_computenode computenode/
#docker build -t hadoop_clientnode clientnode/

docker-compose --x-networking -f constantnode.yml up -d

echo "Wait for the hadoop-control node."
sleep 5

docker-compose --x-networking -f computenode.yml up -d

echo "In Hadoop HiBench Node now!"
docker attach hadoop-hibench
