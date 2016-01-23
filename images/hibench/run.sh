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
