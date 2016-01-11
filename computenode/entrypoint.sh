#!/bin/bash

cat /etc/hosts | grep $(hostname) | ssh root@control-node 'cat >> /etc/hosts'
cat /etc/hosts | grep $(hostname) | ssh root@client-node 'cat >> /etc/hosts'
echo $(cat /etc/hosts | grep $(hostname) | tr '\t' ' ' | cut -d' ' -f1)	$(hostname) >> /data/hosts 

ln -s /data/hosts /etc/hosts

/root/hadoop/sbin/hadoop-daemon.sh start datanode

/root/hadoop/sbin/yarn-daemon.sh start nodemanager 


