#!/bin/bash
set -e

export SPARK_MASTER_HOST=$CONF_CONTROLLER_HOSTNAME
if [ "$SPARK_MASTER_PORT" = "" ]; then
  export SPARK_MASTER_PORT=7077
fi

case "$1" in
  controller)
    # start spark-cluster master
    ${SPARK_HOME}/sbin/start-master.sh
  ;;
  compute)
    # start spark-cluster slave
    ${SPARK_HOME}/sbin/start-slave.sh spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT
  ;;
  *)
    echo "Use with {controller|compute}"
    exit 1
esac

