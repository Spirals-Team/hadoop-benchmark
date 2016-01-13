#!/bin/bash

cat /etc/hosts | grep $(hostname) | ssh root@control-node 'cat >> /etc/hosts'
cat /etc/hosts | grep $(hostname) | ssh root@client-node 'cat >> /etc/hosts'
echo $(cat /etc/hosts | grep $(hostname) | tr '\t' ' ' | cut -d' ' -f1)	$(hostname) >> /data/hosts 

/bin/serf agent -config-dir /etc/serf > serf_log &

/root/hadoop/sbin/hadoop-daemon.sh start datanode

/root/hadoop/sbin/yarn-daemon.sh start nodemanager 

/bin/serf join control-node:7946


