# Intel HiBench

Benchmark based on [Intel HiBench](https://github.com/intel-hadoop/HiBench).

In this example, we only run 4 typical Mapreduce benchmarks to demonstrate how HiBench works with hadoop-benchmark.

The 4 benchmarks are:
- Wordcount
- Sort
- Terasort
- Sleep

The statistics of these benchmarks will be stored in a file called `hibench.report` like:

 ![The result of HiBench examples](/figures/result-hibench.png)


## Image

The `image` directory will be required by docker engine to create HiBench image. 

In `image/hibench-config.sh`, we configure the basic parameters of HiBench which guarantee the benchmarks can execute on Hadoop cluster of hadoop-benchmark.
Even though users want to modify the benchmarks of HiBench, this file can be left as the same.

In `image/HiBench-conf` directory, there are 4 directory corresponding to 4 benchmarks we used in this example.
Each of them contains one file (named `configure.sh`) which stores the datasets of corresponding benchmark.
Users can directly modify these files to achieve their desired experiments with the 4 benchmarks.

But users should create a new directory containing a file having the same name (`configure.sh`) for another benchmarks.
So for adding a new benchmark of HiBench, users need to follow several steps:

1. Creating a new directory for this benchmark under `/benchmarks/hibench/image/HiBench-conf/`

2. Generating `configure.sh` for this benchmark and put it in the directory created in above step

3. Updating Dockerfile with below command (put it under `# copy configuration files`)
```sh
	ADD HiBench-conf/{new benchmark}/configure.sh $HIBENCH_HOME/{new benchmark}/conf/
```

4. Updating `ALL_BENCHMARKS` in run.sh under `benchmarks/hibench`

All the types of benchmarks supported by HiBench for YARN Hadoop can be checked [here](https://github.com/intel-hadoop/HiBench/blob/yarn/conf/benchmarks.lst), and the corresponding `configure.sh` can be checked [here](https://github.com/intel-hadoop/HiBench/tree/yarn) (under `${corresponding benchmark}/conf` directory).
>PS: if users add another benchmarks of HiBench into docker image, please ``DO NOT`` forget to add the benchmark name to $ALL_BENCHMARKS in run.sh under `benchmarks/hibench`.

## Analysis

In `analysis` directory, we provide a simple R script to help users analyse results and generate graphs. 

After users have collected the HiBench reports (hibench.report) from hadoop-benchmark, please put them in a proper directory (e.g. `results/hibench/`).
And the command to launch R scripte will be like:
```sh
	$ Rscript hibench-report.R results/hibench/
```