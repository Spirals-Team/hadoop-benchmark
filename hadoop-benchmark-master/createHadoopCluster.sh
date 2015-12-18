#!/bin/bash

if [ $# == '0' ]; then
	echo "Please indicate the amount of compute nodes as a parameter."
	exit;
fi

if [ $1 -le '1' ]; then
	echo "There must be at least 1 compute node!"
	exit;
fi

docker build -t hadoop_yarn .

master='control-node'
name='hadoop_control'

docker run -itd -P --name $name -h $master -v $(pwd)/data:/data hadoop_yarn

echo "Hadoop Control Node Hostname : $master"

cp -r hadoop-config hadoop

sed -i -- "s/hadoopControlNodeName/$master/g" hadoop/yarn-site.xml
sed -i -- "s/hadoopControlNodeName/$master/g" hadoop/core-site.xml
sed -i -- "s/hadoopControlNodeName/$master/g" hadoop/mapred-site.xml

for i in $(seq 1 $1);
do
	echo "compute-node$i" >> hadoop/slaves
done;

docker cp hadoop $name:/root/hadoop/etc/

docker exec $name service ssh start

docker exec $name /root/hadoop/bin/hadoop namenode -format

for i in $(seq 1 $1);
do
	docker run -itd -P --name hadoop_compute$i -h compute-node$i -v $(pwd)/data:/data hadoop_yarn

	docker cp hadoop hadoop_compute$i:/root/hadoop/etc/

	docker exec hadoop_compute$i service ssh start

#	docker exec hadoop_compute$i /root/hadoop/sbin/hadoop-daemon.sh start datanode
#	docker exec hadoop_compute$i /root/hadoop/sbin/yarn-daemon.sh start nodemanager ;
done

#Collect IPs
mip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $name)
echo "$mip $master" > data/hosts

for i in $(seq 1 $1);
do
	sip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' hadoop_compute$i)
	echo "$sip compute-node$i" >> data/hosts
done

#Set /etc/hosts
docker exec $name /bin/sh -c "cat /data/hosts >> /etc/hosts"

for i in $(seq 1 $1);
do
	docker exec hadoop_compute$i /bin/sh -c "cat /data/hosts >> /etc/hosts"
done

#start Hadoop Cluster
docker exec $name /root/hadoop/sbin/start-all.sh

rm -r hadoop

echo "In Hadoop Control Node now!"
docker attach $name
