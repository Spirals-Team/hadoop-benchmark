#!/bin/bash
set -e

interval=2

if [ $# -lt 1 ]; then
  echo >&2 "Usage: $0 <pid1> [<pid2>] ... [<pidN>]"
	echo >&2 "       a <pid> can be either a PID or a PID file"
  exit 1
fi

pids=()
for pid in "$@"; do
  # check if it is a pid file
  if [[ -f $pid ]]; then
    pid=$(<$pid)
  fi
  # check if it is a number
  if [[ ! "$pid" =~ ^[0-9]+$ ]] ; then
    echo >&2 "$pid: Not a number"; exit 1
  fi
  # check if it is a PID
  if [[ ! -e /proc/$pid ]]; then
    echo >&2 "$pid: Not a PID"; exit 1
  fi

  echo "Waiting for [$pid]: $(ps -p $pid -o command=)"
  pids+=($pid)
done

while true; do
    for pid in "${pids[@]}"; do
        if [[ ! -e /proc/$pid ]]; then
            echo "Process $pid finished"
            pids=(${pids[@]/$pid})
        fi
    done

    if [[ ${#pids[@]} -eq 0 ]]; then
      break
    fi

    sleep $interval
done
