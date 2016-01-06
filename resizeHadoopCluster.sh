#!/bin/bash

if [ $# == '0' ]; then
	echo "Please indicate the amount of compute nodes as a parameter."
	exit;
fi

if [ $1 -lt '1' ]; then
	echo "At least one compute node!"
	exit;
fi

number=$(docker exec control-node /bin/bash -c 'cat /etc/hosts | grep "compute-node" | wc -l')
number=$(echo $number/2 | bc)

if [ $1 -eq $number ]; then
	echo "Already achieved!"
	exit;
fi

if [ $1 -lt $number ]; then
	for i in $(seq $(echo $1+1 | bc) $number);
	do
		docker exec control-node /bin/bash -c "cat /etc/hosts | grep compute-node_$i$ | tr '\t' ' ' | cut -d' ' -f1 >> /root/hadoop/etc/hadoop/datanode-excludes"
	done

	docker exec control-node /bin/bash -c '/root/hadoop/bin/hdfs dfsadmin -refreshNodes'

	docker-compose --x-networking -f cluster.yml scale compute-node=$1
fi

if [ $1 -gt $number ]; then
	docker-compose --x-networking -f cluster.yml scale compute-node=$1

	for i in $(seq $(echo $number+1 | bc) $1);
	do
		ip=$(docker exec control-node /bin/bash -c "cat /etc/hosts | grep compute-node_$i$ | tr '\t' ' ' | cut -d' ' -f1")
		docker exec control-node /bin/bash -c "sed -i '/^$ip/d' /root/hadoop/etc/hadoop/datanode-excludes"
	done

	docker exec control-node /bin/bash -c '/root/hadoop/bin/hdfs dfsadmin -refreshNodes'
fi
