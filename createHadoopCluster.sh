#!/bin/bash

docker build -t hadoop_yarn .
docker build -t hadoop_controlnode controlnode/
docker build -t hadoop_computenode computenode/
docker build -t hadoop_clientnode clientnode/

#for i in $(seq 1 $1);
#do
#	docker run -itd -P --name hadoop_compute$i -h compute-node$i -v $(pwd)/data:/data hadoop_computenode
#	docker exec hadoop_compute$i service ssh start

##	docker exec hadoop_compute$i /root/hadoop/sbin/hadoop-daemon.sh start datanode
##	docker exec hadoop_compute$i /root/hadoop/sbin/yarn-daemon.sh start nodemanager ;
#done

docker-compose --x-networking -f constantnode.yml up -d
docker-compose --x-networking -f computenode.yml up -d

echo "In HiBench Client Node now!"
docker attach client-node
