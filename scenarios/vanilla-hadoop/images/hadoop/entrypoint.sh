#!/bin/bash
set -e

mode=$1

# setup defaults
export CONF_CLUSTER_NAME=${CONF_CLUSTER_NAME:-"cluster"}
export CONF_CONTROLLER_HOSTNAME=${CONF_CONTROLLER_HOSTNAME:-"controller"}
export CONF_NAMENODE_NAME_DIR=${CONF_NAMENODE_NAME_DIR:-"/usr/local/hadoop/var/lib/namenode"}
export CONF_DATANODE_DATA_DIR=${CONF_DATANODE_DATA_DIR:-"/usr/local/hadoop/var/lib/datanode"}
export CONF_JOBHISTORY_DONE_DIR=${CONF_JOBHISTORY_DONE_DIR:-"/usr/local/hadoop/run/jobhistory-intermediate"}
export CONF_JOBHISTORY_INTERMEDIATE_DIR=${CONF_JOBHISTORY_INTERMEDIATE_DIR:-"/usr/local/hadoop/run/jobhistory-done"}

# set Hadoop dirs
export USER=root
export HADOOP_COMMON_HOME=$HADOOP_PREFIX
export HADOOP_HDFS_HOME=$HADOOP_PREFIX
export HADOOP_MAPRED_HOME=$HADOOP_PREFIX
export HADOOP_YARN_HOME=$HADOOP_PREFIX
export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
export HADOOP_PID_DIR=$HADOOP_PREFIX/var/run
export YARN_PID_DIR=$HADOOP_PID_DIR
export HADOOP_MAPRED_PID_DIR=$HADOOP_PID_DIR

# set Hadoop processes options
export HADOOP_NAMENODE_OPTS=""
export HADOOP_DATANODE_OPTS=""
export HADOOP_SECONDARYNAMENODE_OPTS=""
export YARN_RESOURCEMANAGER_OPTS=""
export YARN_NODEMANAGER_OPTS=""
export YARN_PROXYSERVER_OPTS=""
export HADOOP_JOB_HISTORYSERVER_OPTS=""

[[ -f /before-setup.sh ]] && /before-setup.sh $mode
/setup.sh $mode
[[ -f /after-setup.sh ]] && /after-setup.sh $mode

case "$mode" in
  controller|compute)
    /start.sh $mode
  ;;
  console)
    exec bash
  ;;
  run)
    shift
    exec "$@"
  ;;
  *)
    echo "Use with {controller|compute|console|run}"
    exit 1
esac
