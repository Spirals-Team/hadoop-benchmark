#!/bin/bash

/root/hadoop/bin/hadoop namenode -format

/root/hadoop/sbin/hadoop-daemon.sh start namenode

/root/hadoop/sbin/hadoop-daemon.sh start secondarynamenode

/root/hadoop/sbin/yarn-daemon.sh start resourcemanager


