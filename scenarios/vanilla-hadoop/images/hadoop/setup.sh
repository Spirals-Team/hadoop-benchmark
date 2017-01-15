#!/bin/bash
set -e

# replace ANY %CONF_<NAME> to evaluated $CONF_<NAME> variables
for f in "$HADOOP_CONF_DIR"/*; do
  echo "[$0]: processing '$f' configuration file"
  awk '{ while(match($0, "%CONF_[a-zA-Z0-9_]+")) { var=substr($0, RSTART + 1, RLENGTH - 1) ; gsub("%"var, ENVIRON[var]) } }1' < $f > "$f.tmp"
  mv "$f.tmp" $f
done
