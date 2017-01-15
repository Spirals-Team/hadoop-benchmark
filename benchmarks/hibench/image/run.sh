#!/bin/bash
set -e

case "$1" in
  --benchmarks)
    shift

    echo $@ | tr ' ' '\n' > $HIBENCH_HOME/conf/benchmarks.lst
    echo "Running benchmarks:"
    cat $HIBENCH_HOME/conf/benchmarks.lst
    $HIBENCH_HOME/bin/run-all.sh
  ;;
  *)
    exec "$@"
  ;;
esac

report=$HIBENCH_HOME/hibench.report
dest="/user/root/hibench-$(date +"%Y%m%d-%H%M").report"
hdfs dfs -put "$report" "$dest"

echo "Benchmarks finished"
echo
cat "$report"
echo
echo "The report has been uploaded to HDFS: $dest"
echo "To download, run ./cluster.sh hdfs-download \"$dest\""
