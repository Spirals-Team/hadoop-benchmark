#!/bin/bash
set -e

case "$1" in
  --benchmarks)
    shift

    echo $@ | tr ' ' '\n' > $HIBENCH_HOME/conf/benchmarks.lst
    echo "Running benchmarks:"
    cat $HIBENCH_HOME/conf/benchmarks.lst

    for i in $(seq 1 10);
    do
        $HIBENCH_HOME/bin/run-all.sh
        cat $HIBENCH_HOME/hibench.report

        hdfs dfs -copyFromLocal $HIBENCH_HOME/hibench.report hdfs:///report/hibench-$(date +"%s").report
    done
  ;;
  *)
    exec "$@"
  ;;
esac

echo "Benchmarks finished"
echo "All hibench.report files are uploaded to HDFS (in hdfs:///)"
echo "To download these reports to current path, run './cluster.sh hdfs-download hdfs:///report/ .'"
