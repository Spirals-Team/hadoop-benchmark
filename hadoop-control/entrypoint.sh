#!/bin/bash

sed -i -- "s/ControlNodeHostName/hadoop-control/g" /root/hadoop/etc/hadoop/core-site.xml
sed -i -- "s/ControlNodeHostName/hadoop-control/g" /root/hadoop/etc/hadoop/mapred-site.xml
sed -i -- "s/ControlNodeHostName/hadoop-control/g" /root/hadoop/etc/hadoop/yarn-site.xml 

/root/hadoop/bin/hadoop namenode -format

/root/hadoop/sbin/hadoop-daemon.sh start namenode

/root/hadoop/sbin/hadoop-daemon.sh start secondarynamenode

/root/hadoop/sbin/yarn-daemon.sh start resourcemanager


