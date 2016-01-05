#!/bin/bash

#if [ $# == '0' ]; then
#	echo "Please indicate the amount of compute nodes as a parameter."
#	exit;
#fi

#if [ $1 -lt '1' ]; then
#	echo "There must be at least 1 compute node!"
#	exit;
#fi

docker build -t hadoop_yarn .
docker build -t hadoop_controlnode controlnode/
docker build -t hadoop_computenode computenode/
docker build -t hadoop_clientnode clientnode/

#master='control-node'
#name='hadoop_control'

#touch slaves

#for i in $(seq 1 $1);
#do
#	echo "compute-node$i" >> slaves
#done;

#docker run -itd -P --name $name -h $master -v $(pwd)/data:/data hadoop_controlnode

#docker cp slaves $name:/root/hadoop/etc/hadoop/
#docker exec $name service ssh start

#rm slaves

#for i in $(seq 1 $1);
#do
#	docker run -itd -P --name hadoop_compute$i -h compute-node$i -v $(pwd)/data:/data hadoop_computenode
#	docker exec hadoop_compute$i service ssh start

##	docker exec hadoop_compute$i /root/hadoop/sbin/hadoop-daemon.sh start datanode
##	docker exec hadoop_compute$i /root/hadoop/sbin/yarn-daemon.sh start nodemanager ;
#done

#Collect IPs
#mip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $name)
#echo "$mip $master" > data/hosts

#for i in $(seq 1 $1);
#do
#	sip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' hadoop_compute$i)
#	echo "$sip compute-node$i" >> data/hosts
#done

#Set /etc/hosts
#docker exec $name /bin/sh -c "cat /data/hosts >> /etc/hosts"

#for i in $(seq 1 $1);
#do
#	docker exec hadoop_compute$i /bin/sh -c "cat /data/hosts >> /etc/hosts"
#done

#start Hadoop Cluster
#docker exec $name /root/hadoop/sbin/start-all.sh

docker-compose --x-networking -f cluster.yml -f clientnode.yml up -d

echo "In HiBench Client Node now!"
docker attach client-node
