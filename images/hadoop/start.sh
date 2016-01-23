#!/bin/bash
set -e

mode=$1

trap 'stop' INT TERM

stop() {
  trap '' INT TERM # ignore INT and TERM while shutting down

  echo "[$0]: *** Stopping all processes ***"

  [[ -f /before-stop.sh ]] && /before-stop.sh $mode
  case "$mode" in
    controller)
      $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop namenode
      $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop secondarynamenode
      $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop resourcemanager
      $HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver
    ;;
    compute)
      $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode
      $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager
    ;;
  esac
  [[ -f /after-stop.sh ]] && /after-stop.sh $mode

  echo "[$0]: *** All processes have been stopped ***"

  kill -TERM 0
  wait
}

echo "[$0]: *** Starting collectd ***"

# start collectd
/usr/sbin/collectd -C /etc/collectd/collectd.conf

echo "[$0]: *** Starting all processes ***"

[[ -f /before-start.sh ]] && /before-start.sh $mode
case "$mode" in
  controller)
    if [[ ! -d $CONF_NAMENODE_NAME_DIR ]]; then
      echo "[$0]: *** Formatting HDFS NameNode ***"
      $HADOOP_PREFIX/bin/hdfs namenode -format $CONF_CLUSTER_NAME
    fi

    $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start secondarynamenode
    $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
    $HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver
  ;;
  compute)
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
    $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager
  ;;
esac
[[ -f /after-start.sh ]] && /after-start.sh $mode

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
