#!/bin/bash
set -e

trap 'stop' INT TERM

stop() {
  trap '' INT TERM # ignore INT and TERM while shutting down

  echo "[$0]: *** Stopping all processes ***"
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode
  $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager
  echo "[$0]: *** All processes have been stopped ***"

  kill -TERM 0
  wait
}

echo "[$0]: *** Starting all processes ***"
$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager

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
