## 1. Introduction

Hadoop is a famous software to achieve reliable, scalable and distributed computing.
But setting a Hadoop cluster always troubles users by its configurations and networking.
Moreover, in research community, there is no an easy way to quickly reproduce a running Hadoop cluster which can help researchers compare different existing approaches.

This project use Docker to package a Hadoop cluster and all its dependencies in images.
Users can use Docker containers to quickly build an Hadoop infrastructure.
We also provide some acknowledged benchmarks and self-adaptive scenarios atop of it.


## 2. Requirements: 

This project is based on Docker and Bash script.
Before the start, please ensure that the bellow tools have been well installed.
The links following the software is the official tutorial or commands of installation.

#### docker (version >= 1.9.1)
##### Linux
    https://docs.docker.com/engine/installation/
##### Mac
    https://docs.docker.com/engine/installation/mac/
##### windows
    https://docs.docker.com/engine/installation/windows/
    
#### docker-machine (version >= 0.5.6)
(PS: docker-machine will be installed together with docker)
##### Linux
    https://docs.docker.com/engine/installation/
##### Mac 
    https://docs.docker.com/engine/installation/mac/
##### windows 
    https://docs.docker.com/engine/installation/windows/

#### bash (version >= 3)
    
#### git (version >=2.6)
#####    Linux: 
    $ yum install git-core
    $ apt-get install git
#####    Mac:
    http://sourceforge.net/projects/git-osx-installer/
#####    Windows:
    http://msysgit.github.com/

## 3. Organization

This project can be downloaded by the command

```sh
	$ git clone https://github.com/Spirals-Team/hadoop-benchmark.git
```

The main directory <<hadoop-benchmark>> contains several important components:
 - hadoop-benchmark
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
  - This directory contains the Dockerfiles of Hadoop images. The built images should package the compiled Hadoop code, prepared configuration files and all required dependencies.
 
##### benchmarks
  - This directory provide 3 benchmarks.
  	- The bundled Hadoop examples
	- Hibench
	- SWIM - default 50 jobs 
	
##### scenarios
 - This directory provide the source code of an alternative Hadoop images. Besides the basic Hadoop environment, a self-adaptive approach is also packaged in these images.


## 3. Getting started guide
### 3.1 Creating a cluster
When the project is downloaded, users can create an example Hadoop cluster by one command:
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

### 3.2 Starting hadoop 
Once the step one finished, users can start hadoop cluster by another command:
 ```sh
	 $ CONFIG=local_cluster ./cluster.sh start-hadoop
 ```
 
 This command will create a Hadoop control container in Hadoop control node.
 This container shall run ResourceManager, NameNode, SecondaryNamenode and JobHistoryServer which are master components of Hadoop.
 
 When the Hadoop control container is running, a Hadoop compute container will be launched in Hadoop Compute node 1.
 This container supports NodeManager and Datanode which are slave agent of Hadoop.

### 3.3 Running bechnmarks
 After step two successes, users can execute different benchmarks in the running Hadoop cluster.
 
#### 3.3.1 Quick test with Hadoop bundled examples
Users can quickly test the Hadoop cluster with the bundled example Hadoop commands.
For example:
 ```sh
	 $ ./benchmarks/hadoop-mapreduce-examples/run.sh pi 2 2
 ```
 
 #### 3.3.2 Run HiBench
 Users can also run HiBench on the Hadoop cluster, which is a famous hadoop benchmark provided by Intel. The launch command is like:
 ```sh
	 $ ./benchmarks/hibench/run.sh
 ```
 (Warning: each HiBench command will generates a lot of data (e.g. terasort input data is 1TB). So HiBench  is not suitable for a local machine.)
 
#### 3.3.3 Run SWIM
 In this project, a SWIM example workloads is also provided.
 This concurrent scenario contains 50 concurrent MapReduce jobs.
 Users can launch this benchmark by the bellow command:
 ```sh
	 $ ./benchmarks/swim/run.sh
 ```
 At the end of the test, all the job logs is stored in the directory "workLogs" in current directory.
 
 
## 4. Self-balancing Scenario
 Before this scenario, please ensure the Hadoop cluster has been stopped.
 Users can stop the Hadoop cluster by command:
 ```sh
	 $ CONFIG=local_cluster ./cluster.sh stop-hadoop
 ```
 
 In Self-balacing Scenario, besides a running Hadooop cluster, an self-adaptive approach is also running in Hadoop control node.
 This approach automatically balances the job-parallelism and job-throughput based on the memory utilization of the whole Hadoop cluster.
 
 To start Self-balancing Scenario, all commands used are similar to those in Section 3.
 But the 'local_cluster' configuration file should be replaced with the 'self-balancing-example/local_cluster' file.
 The commands should be like:
 ```sh
	 $ CONFIG=scenarios/self-balancing-example/local_cluster ./cluster.sh start-hadoop
 ```