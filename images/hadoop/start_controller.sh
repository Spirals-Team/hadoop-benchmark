#!/bin/bash
set -e

trap 'stop' INT TERM

stop() {
  trap '' INT TERM # ignore INT and TERM while shutting down

  echo "[$0]: *** Stopping all processes ***"
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop namenode
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop secondarynamenode
  $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop resourcemanager
  $HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver
  echo "[$0]: *** All processes have been stopped ***"

  kill -TERM 0
  wait
}

if [[ ! -d $CONF_NAMENODE_NAME_DIR ]]; then
  echo "[$0]: *** Formatting HDFS NameNode ***"
  $HADOOP_PREFIX/bin/hdfs namenode -format $CONF_CLUSTER_NAME
fi

echo "[$0]: *** Starting all processes ***"
$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start secondarynamenode
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver
echo "[$0]: *** Waiting 5 seconds for pid and log files ***"
sleep 5

# wait for pids
/pwait.sh $HADOOP_PID_DIR/* &
pwait_pid=$!

# flush output before tailing from logs
sleep 1
echo "[$0]: *** Tailing log files ***"

# tail all logs
/mtail.sh $HADOOP_PREFIX/logs/* &

wait $pwait_pid

# kill all subprocesses, i.e. mtail.sh
kill -TERM 0
