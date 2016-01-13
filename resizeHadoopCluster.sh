#!/bin/bash

if [ $# == '0' ]; then
	echo "Please indicate the amount of compute nodes as a parameter."
	exit;
fi

if [ $1 -lt '1' ]; then
	echo "At least one compute node!"
	exit;
fi

number=$(docker exec hadoop-control /bin/bash -c 'cat /etc/hosts | grep "hadoop-compute" | wc -l')
number=$(echo $number/2 | bc)

if [ $1 -eq $number ]; then
	echo "Already achieved!"
	exit;
fi

if [ $1 -lt $number ]; then
	for i in $(seq $(echo $1+1 | bc) $number);
	do
		ip=$(docker exec hadoop-control /bin/bash -c "cat /etc/hosts | grep hadoop-compute_$i$ | tr '\t' ' ' | cut -d' ' -f1")
		docker exec hadoop-control /bin/bash -c "echo $ip >> /root/hadoop/etc/hadoop/datanode-excludes" ;
	done

	docker exec hadoop-control /bin/bash -c '/root/hadoop/bin/hdfs dfsadmin -refreshNodes'
	docker-compose --x-networking -f computenode.yml scale hadoop-compute=$1 ;
fi

if [ $1 -gt $number ]; then
	docker-compose --x-networking -f computenode.yml scale hadoop-compute=$1

	for i in $(seq $(echo $number+1 | bc) $1);
	do
		ip=$(docker exec hadoop-control /bin/bash -c "cat /etc/hosts | grep hadoop-compute_$i$ | tr '\t' ' ' | cut -d' ' -f1")
		docker exec hadoop-control /bin/bash -c "sed -i '/^$ip/d' /root/hadoop/etc/hadoop/datanode-excludes"
	done

	docker exec hadoop-control /bin/bash -c '/root/hadoop/bin/hdfs dfsadmin -refreshNodes' ;
fi
