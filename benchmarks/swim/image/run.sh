#!/bin/bash
set -e

echo "Preparing SWIM:"
[[ -d workGenInput ]] && rm -fr workGenInput
hdfs dfs -rm -r -f /user/root/workGenInput
hadoop jar $SWIM_HOME/HDFSWrite.jar org.apache.hadoop.examples.HDFSWrite -conf $SWIM_HOME/randomwriter_conf.xsl workGenInput

echo "Running SWIM:"
$SWIM_HOME/run-jobs-all.sh
