#!/bin/bash
set -e

echo '================= Prepare Wordcount Dataset ================='
hdfs dfs -rm -r spark-wordcount-input

hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar randomtextwriter -D mapreduce.randomtextwriter.bytespermap=100000000 -D mapreduce.randomtextwriter.mapsperhost=1 spark-wordcount-input

echo '====================== Run Wordcount in Spark on YARN ======================'
spark-submit --class org.apache.spark.examples.JavaWordCount /usr/local/spark/examples/jars/spark-examples_2.11-2.1.0.jar /user/root/spark-wordcount-input/part-m-00000
