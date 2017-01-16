# Intel HiBench

Benchmark based on [Intel HiBench](https://github.com/intel-hadoop/HiBench).

In this example, we only run 4 typical Mapreduce benchmarks to demonstrate how HiBench works with hadoop-benchmark.

The 4 benchmarks are:
- Wordcount
- Sort
- Terasort
- Sleep

#### Image

The `image` directory will be required by docker engine to create HiBench image. 

In `image/hibench-config.sh`, we configure the basic parameters of HiBench which guarantee the benchmarks can execute on Hadoop cluster of hadoop-benchmark.
Even though users want to modify the benchmarks of HiBench, this file can be left as the same.

In `image/HiBench-conf` directory, there are 4 directory corresponding to 4 benchmarks we used in this example.
Each of them contains one file (named `configure.sh`) which stores the datasets of corresponding benchmark.
Users can directly modify these files to achieve their desired benchmarks, or create a new directory containing a file having the same name (`configure.sh`) for another benchmarks.

All the types of benchmarks supported by HiBench for YARN Hadoop can be checked [here](https://github.com/intel-hadoop/HiBench/blob/yarn/conf/benchmarks.lst).

#### Analysis

In `analysis` directory, we provide a simple R script to help users analyse results and generate graphs. 