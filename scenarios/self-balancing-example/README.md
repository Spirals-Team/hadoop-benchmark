#SELF-ADAPTATION SCENARIO

In this scenario, a new self-balancing approach works along with vanilla Hadoop cluster.
This approach can dynamically tune hadoop configuration to automatically balance job parallelism and job throughput  while processing concurrent workloads.

We have published two papers on this self-balancing approach:

[Self-Balancing Job Parallelism and Throughput in Hadoop](https://hal.inria.fr/hal-01294834)

[Self-configuration of the Number of Concurrently Running MapReduce Jobs in a Hadoop Cluster](https://hal.inria.fr/hal-01143157)

The self-balancing approach is realized by a feedback control loop based on typical MAPE cycle as shown below:

 ![The feedback control loop of self-balancing approach](/figures/loop.png)
 
Concluding with many experiments of various Mapreduce jobs, we can say that this approach can obviously improve the system performance of Hadoop cluster while processing concurrent workloads.

 ![The result comparison between self-balancing approach and default static configurations](/figures/diff-type-size.png)