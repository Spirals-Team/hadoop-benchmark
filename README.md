## 1. Introduction

Hadoop is a famous software to achieve reliable, scalable and distributed computing.
But setting a Hadoop cluster always troubles users by its configurations and networking.
Moreover, in research community, there is no an easy way to quickly reproduce a running Hadoop cluster which can help researchers compare different existing approaches.

This project use Docker to package a Hadoop cluster and all its dependencies in images.
Users can use Docker containers to quickly build an Hadoop infrastructure.
We also provide some acknowledged benchmarks and self-adaptive scenarios atop of it.



## 2. Requirements: 

This project is based on Docker and Bash script.
Before the start, please ensure that the below tools have been well installed.
The links following the software is the official tutorial or commands of installation.

#### docker (version >= 1.9.1)
##### Linux
    https://docs.docker.com/engine/installation/
##### Mac
    https://docs.docker.com/engine/installation/mac/
##### windows
    https://docs.docker.com/engine/installation/windows/
    
#### docker-machine (version >= 0.5.6)
##### Linux
```sh
$ curl -L https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine
```
##### Mac 
```sh
$ curl -L https://github.com/docker/machine/releases/download/v0.5.6/docker-machine_darwin-amd64 >/usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine
```
##### windows (using git bash)
```sh
$ if [[ ! -d "$HOME/bin" ]]; then mkdir -p "$HOME/bin"; fi && \
    curl -L https://github.com/docker/machine/releases/download/v0.5.6/docker-machine_windows-amd64.exe > "$HOME/bin/docker-machine.exe" && \
    chmod +x "$HOME/bin/docker-machine.exe"
```
>`Please ensure that 'nc' commands have been installed which is important to start hadoop cluster.`

#### bash (version >= 3)

#### VirtualBox (for local tests)



## 3. Organization

This project can be cloned by the command

```sh
	$ git clone https://github.com/Spirals-Team/hadoop-benchmark.git
```

The directory contains several important components:
- cluster.sh
- images
- benchmarks
- scenarios

##### cluster.sh
 - It is the main bash of this project. The details can be found by command: 
 ```sh
	 $ ./cluster.sh --help
 ```
 - With the default environment value, this bash will create an example Hadoop cluster which is composed by three nodes:
 	- Consul K/V store
	- Hadoop control node
	- Hadoop compute node 1
	(Consul K/V store is used by docker to create an overlay network which help docker containers in different hosts to connect to each other.)
 
##### images
  - This directory contains base images. The built images should package the compiled Hadoop code, prepared configuration files and all required dependencies.
 
##### benchmarks
  - This directory provide 3 benchmarks.
  	- The bundled Hadoop examples
	- Hibench
	- SWIM - default 50 jobs 
	
##### self-adaptive scenarios
 - This directory provide the source code of an alternative Hadoop images. Besides the basic Hadoop environment, a self-adaptive approach is also packaged in these images.


## 4. Getting started guide

This project aims to help users quickly deploy a running Hadoop cluster.
It provide a set of commands to simplify and accelerate the deployment.
This guide will illustrate how to execute this project.
Moreover, some example results are also provided to help users follow this guide.
Following this guide, users will create local Hadoop cluster, execute a benchmark, check the results, even rerun the benchmark with self-adaptive scenario (in next section).
The guide process contains the following phases:

 - create cluster
 - start hadoop
 - run benchmark (experiment)
 - check results
 
Furthermore, users can also create different Hadoop cluster to compare the performance difference between configurations (or scenario), following the further guide in next section.
 
 - update Hadoop configuration / change to self-adaptive scenario
 - restart hadoop

The guide process can also be visualized in the below image:

![The guide process](/figures/guide.png)


### 4.0 Configuration
Open the `local_cluster` file and modify the desired number of nodes, the `NUM_COMPUTE_NODES` settings.
The default deployment is on local machine using [ORACLE VirtualBox](https://www.virtualbox.org/). One hadoop instance requires about 2GB of RAM so be rather conservative to how many nodes can fit to your machine.
A number of additional virtualization environments are support.
The list, including all theior settings can be found at the [docker-machine website](https://docs.docker.com/machine/drivers/).
To use different driver, simply change the `DRIVER` variable export all require properties based on the driver requirements. 

### 4.1 Creating a cluster
 ```sh
$ CONFIG=local_cluster ./cluster.sh create-cluster
 ```
 By modifying 'NUM_COMPUTE_NODES', users can create a different scale Hadoop cluster by the above command.
 
 By default, this command will create the consul K/V store node firstly.
 And then, a consul K/V store container will be launched in this node.
 
 After the consul K/V store is ready, two nodes will be created as Hadoop control node and compute node 1.
 
 The command will create an overlay network for all docker containers in this cluster at the end.
 
 Users can use the following command to check the status of the nodes created:
 
```sh
$ CONFIG=local_cluster ./cluster.sh status-cluster
```

If the Hadoop cluster has been successfully created, the status-create would show some results like
![The result of create-cluster](/figures/result-status-cluster.png)





### 4.2 Starting hadoop 
Once the step one finished, users can start hadoop cluster by another command:
```sh
$ CONFIG=local_cluster ./cluster.sh start-hadoop
```
 
 This command will create a Hadoop control container in Hadoop control node.
 This container shall run ResourceManager, NameNode, SecondaryNamenode and JobHistoryServer which are master components of Hadoop.
 
 When the Hadoop control container is running, a Hadoop compute container will be launched in each Hadoop Compute node.
 This container supports NodeManager and Datanode which are slave agent of Hadoop.
 
 When Hadoop cluster has been successfully started, there should be some results shown in the terminal:
 ![The result of start-hadoop](/figures/result-start-hadoop.png)
 
 
 PS: In order to be able to run the benchmarks, please do not forget to execute the below command reminded in the above result. 
 ```sh
	 $ eval $(docker-machine env --swarm local-hadoop-controller)
 ```
 
 
The architecture of Hadoop cluster in local machine can be illustrated in following schema:
![The Architecture of Hadoop cluster deployed](/figures/architecture.png)
 
> To customize the Hadoop cluster,  users only need to update the hadoop configuration files in `images/hadoop/hadoop-conf`.


### 4.3 Running bechnmarks
 After step two successes, users can execute different benchmarks in the running Hadoop cluster.
 
#### 4.3.1 Quick test with Hadoop bundled examples
Users can quickly test the Hadoop cluster with the bundled example Hadoop commands.
For example:
 ```sh
	 $ ./benchmarks/hadoop-mapreduce-examples/run.sh pi 2 2
 ```
 > In this example, we try PI Estimator, a default hadoop benchmark packaged in hadoop-mapreduce-examples.jar
 
 
 At the end of this command, if the terminal exposes some informations like below image, that means this Hadoop MapReduce application has been successfully treated. Users can obtain the details of the application in this terminal report.
  ![The result of PI estimation](/figures/result-pi.png)
 
For all benchmarks packaged in Hadoop (e.g. pi), users can use the following command to run them on the Hadoop Cluster of hadoop-benchmark.
 ```sh
	$ ./benchmarks/hadoop-mapreduce-examples/run.sh 
 ```
 
#### 4.3.2 Run HiBench
 Users can also run HiBench on the Hadoop cluster, which is a famous hadoop benchmark provided by Intel. The launch command is like:
 ```sh
	 $ ./benchmarks/hibench/run.sh
 ```
> In this example, we try 4 famous and typical Mapreduce benchmarks (Sleep, Sort, Terasort and Wordcount) provided by HiBench.

The HiBench results are stored in `hibench.report`.
  ![The result of Hibench](/figures/result-hibench.png)

To generate new experiments of HiBench, users only need to replace the HiBench configuration files in `benchmarks/hibench/image/HiBench-conf` with new configuration or files.

To get more information about how to configure HiBench, users can visit [HiBench Github](https://github.com/intel-hadoop/HiBench).
>`HiBench is a big suit of benchmarks for Hadoop and Spark. `hadoop-benchmark` only supports the benchmarks of Hadoop cluster for the moment.`

 
#### 4.3.3 Run SWIM
 In this project, a SWIM example workloads is also provided.
 This concurrent scenario contains 50 concurrent MapReduce jobs.
 Users can launch this benchmark by the below command:
 ```sh
	 $ ./benchmarks/swim/run.sh
 ```
 At the end of the test, all the job logs is stored in the directory "workGenLogs" in current directory.
 
 (Warning: SWIM will launch many MapReduce applications running in parallel. So SWIM is not suitable for a local machine.)
 
 SWIM is a Statistical Workload Injector for Mapreduce [(SWIM)](https://github.com/SWIMProjectUCB/SWIM/wiki).
 Users could generate their own SWIM workloads by following SWIM tutorial, and then replace `benchmarks/swim/image/SWIM` directory with new SWIM workloads directory.
> In our example, we use a very small [work log](https://github.com/SWIMProjectUCB/SWIM/blob/master/workloadSuite/FB-2009_samples_24_times_1hr_0_first50jobs.tsv) which is captured by FaceBook in 2009 to generate our SWIM example workload which only contains 50 concurrent Mapreduce jobs.
 
 
## 5. Self-balancing Scenario
 Before this scenario, please ensure the Hadoop cluster has been stopped.
 Users can stop the Hadoop cluster by command:
 ```sh
	 $ CONFIG=local_cluster ./cluster.sh destroy-hadoop
 ```
 
 In Self-balacing Scenario, besides a running Hadooop cluster, an self-adaptive approach is also running in Hadoop control node.
 This approach automatically balances the job-parallelism and job-throughput based on the memory utilization of the whole Hadoop cluster.
 
 To start Self-balancing Scenario, all commands used are similar to those in Section 4.
 But the `local_cluster` configuration file should be replaced with the `scenario/self-balancing-example/local_cluster` file.
 The commands should be like:
 ```sh
	 $ CONFIG=scenarios/self-balancing-example/local_cluster ./cluster.sh start-hadoop
 ```

>For all the benchmarks supported by hadoop-benchmark, users can execute them on the self-adaptation cluster by the same commands introduced in above.


## 6. OPTION: Deployment in Grid5000

This project can also be used in [Grid5000](https://www.grid5000.fr).
In Grid5000, this project uses [docker-machine-driver-g5k](https://github.com/Spirals-Team/docker-machine-driver-g5k) driver to create the cluster.

This driver will use Grid5000 VPN to reserve nodes from users' own laptop.
Please follow the tutorial of docker-machine-driver-g5k to well configure it.

>PS: because a docker overlay network requires kernel (version >= 3.1.6), we suggest users using the environment `jessie-x64-min` to install `Debian Jessie` in the hosts, which is set as default environment in docker-machine-driver-g5k driver.

Users should use their proper informations to replace the examples in some parameters in `g5k_cluster` like:

 - USER='bzhang'
 - PASSWD='xxxxxxx'
 - SITE='lille'
 - PRIVATE_KEY=$HOME'/.ssh/id_rsa'
 - WALLTIME='8:00:00'

To ensure `docker-machine` can successfully create cluster, SSH private key file should be correctly set.

When the configuration of `docker-machine-driver-g5k` and `g5k_cluster` has finished, users can create a cluster and start hadoop in Grid5000 with the commands presented in section 4.
But the configuration file should be replaced with `g5k_cluster`.
The commands should be like:
 ```sh
	 $ CONFIG=g5k_cluster ./cluster.sh create-cluster
 ```


## 7. Result Comparison 

Based on our self-balancing research, we find that when Hadoop cluster process a concurrent MapReduce workload, its static configuration will degrade the cluster performance.
That means, for different workloads, the best Hadoop configuration (MARP: a parameter in CapacityScheduler in ResourceManager of YARN) would be different.
Furthermore, according to a time-varying workload, the most suitable value of MARP should be also dynamic.
  ![different best configurations for different workloads](/figures/diff-type-size.png)
 
To solve this problem, we proposed a self-balancing algorithm which can tune MARP at runtime to guarantee the cluster performance.
The assessments in Grid5000 show that, our approach of self-balancing algorithm can significantly improve the Hadoop cluster performance at runtime.
    ![homogenes](/figures/homogenes.png)

In hadoop-benchmark, we provide a simple bash+Rscript (analysis.sh analysis.R) to generate the comparison graph of each job completion time which are captured by SWIM between static Hadoop cluster and self-Adaptation cluster.
Users can generate their own graphs based on needs with the statistics generated by benchmarks.