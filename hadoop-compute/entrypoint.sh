#!/bin/bash

/bin/bash -c /getMaping.sh

/root/hadoop/sbin/hadoop-daemon.sh start datanode

/root/hadoop/sbin/yarn-daemon.sh start nodemanager 


