# hadoop-benchmark
Docker containers to build an Hadoop infrastructure and experiment feedback control loops atop of it.

There are only three commands:

>  ./createHadoopCluster.sh
  
>  ./resizeHadoopCluster.sh [amount of compute nodes]
  
>  ./clean.sh

All these commands should be executed in host, not in containers.


### Prerequisites: 

    docker
    
    docker-compose

### Command One (in Terminal 1):

```sh
$ ./createHadoopCluster.sh
```
    
    - when you success to create a Hadoop cluster, you should be in the hadoop-hibench node. You can confirm the Hadoop cluster by command
            $ hdfs dfsadmin -report
      And you will see that, right now, you have one live datanode with "Normal" status.
      That means your hadoop cluster only have one compute node at this moment.

### Command Two (in Terminal 2):

```sh
$ ./resizeHadoopCluster.sh [amount of compute nodes]
```

    - when this command has finished, you can repeat "hdfs dfsadmin -report" command in Terminal 1.
      And you will find you have [amount of compute nodes] live datanode with  "Normal" status.
      You can play Command two in Terminal 2 several times, with different [amount of compute nodes], to make sure it really rescale the Hadoop cluster.
      But please be careful that when you scale down the cluster, the number of live datanode doesn't change, but their status will become "decommissioned".

### Command Three (in Terminal 1: You probably be in Client node now):

```sh
$ hadoop jar ~/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-example-2.7.1.jar pi 2 2
```

    - this is a hadoop example command proposed by Hadoop itself.
      You can run other hadoop command as you like.
      Or you can use Hibench benchmark which is located in /root/.

### Command Four (in Terminal 1 or 2: if in Terminal 1, please ensure that you have exit from containers)

```sh
$ ./clean.sh
```

    - this command is to clean all the containers created.

Here, demo is over. 