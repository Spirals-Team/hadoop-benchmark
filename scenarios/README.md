In this directory, we provide 2 scenarios which have been adapted to docker for hadoop-benchmark:
- Vanilla Configuration (default Hadoop Cluster) 
- Self-Adaptation Hadoop Cluster

### Vanilla Configuration (default Hadoop Cluster)
This scenario only configure the connections between different nodes to guarantee the Hadoop cluster can work normally.
All the other Hadoop configuration parameters keep the default values.
This scenario can ensure that users would have a pure Hadoop Cluster.

To modify the Hadoop cluster, users only need to update the configuration files under `vanilla-hadoop/images/hadoop/hadoop-conf` firstly, destroy the old Hadoop cluster and restart a new one with the bellow commands:
```sh
	$ ./cluster.sh destroy-hadoop
	$ ./cluster.sh start-hadoop
```

### Self-Adaptation Hadoop Cluster
This scenario is an advanced Hadoop Cluster which can dynamically adjust job throughput and job parallelism by modifying configuration at runtime.

A new approach based on a [self-balancing algorithm](https://hal.inria.fr/hal-01294834) is implemented along with the vanilla Hadoop cluster.
This approach continues monitoring the memory utilization of the whole Hadoop cluster, makes the decision when and how to modify Hadoop configuration, and requires Hadoop to reload the new parameter values at runtime.

This scenario can help users easily reproduce my experiments and compare the improvement between different research.
To launch such scenario, users needs to destroy the old Hadoop cluster, and start a new one with Self-Adaptation configuration under `self-balancing-example`.
The commands are like:
```sh
	$ ./cluster.sh destroy-hadoop
	$ CONFIG=self-balancing-example/local_cluster ./cluster.sh start-hadoop
```

### Creating New Scenario
To create a new scenario, there are several steps:
1 Create new Dockerfile: This file will be used by hadoop-benchmark to create new hadoop docker image which will be used to produce specific Hadoop cluster.
2 Generat new hadoop-benchmark configuration file: This file will be used in launching command to indicate correct docker image and specific configurations concerning the new Hadoop cluster.
3 Option: generating `after-start.sh` bash is also necessary when there are additional services need to be launched after Hadoop cluster becomes ready.

In these steps, `Create new Dockerfile` is the most important one.
To understand and learn how to create a new Dockerfile, users can get more informations and tutorial [here](https://docs.docker.com/engine/reference/builder/).
We suggest users to create the new docker images from `spirals/hadoop-benchmark:hadoop-benchmark` docker image which have been shared in DockerHub.
This image only contains the pure hadoop packages and wouldn't cause any disturbs from our examples.