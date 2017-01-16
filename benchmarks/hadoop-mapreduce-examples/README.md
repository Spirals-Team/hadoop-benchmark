# Hadoop MapReduce Examples

Benchmark based on [hadoop-mapreduce-examples](https://github.com/apache/hadoop/tree/trunk/hadoop-mapreduce-project/hadoop-mapreduce-examples).

 ![The list of Default Benchmarks](/figures/defaultBenchmarkInfo.png)
 
Because all these benchmarks (shown in above) are packaged in hadoop, it is not necessary to generate a new docker image, but launching one docker container from `hadoop-benchmark/hadoop` image is enough.
What users should do is only to concatenate benchmarks' arguments after `run.sh` bash, like
```sh
	$ ./benchmarks/hadoop-mapreduce-examples/run.sh pi 2 2
```

The further informations about these benchmarks can be checked by bellow command
```sh
	$ ./benchmarks/hadoop-mapreduce-examples/run.sh
```
