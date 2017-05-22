# BENCHMARKS

In this directory, we provide the following benchmarks:

+ default Hadoop benchmarks
+ default Spark benchmarks
+ HiBench
+ SWIM (Statistical Workload Injector for Mapreduce)

In hadoop-benchmark, each benchmark is running in an individual docker container which has been configured to connect to the Hadoop cluster. This architecture can avoid the impact of having additional processes (i.e. benchmarks) running in the Hadoop cluster.

## Creating a new benchmark

A new benchmark should have therefore its own docker image with all the necessary software installed. The container should start the benchmark immediatelly once the container is run. Benchmark results should be stored in HDFS. Finally, the authors of a benchmark should also povide a simple `run.sh` wrapper that launches the benchmark as well as any other scripts that help to further analyse the results.

The best is to look at the structure of the existing benchmarks.
