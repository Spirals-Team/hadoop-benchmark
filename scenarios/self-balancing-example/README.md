# Self-Adaptation Scenario

In this scenario, we propose a new self-balancing approach that works along with vanilla Hadoop cluster. This approach dynamically tunes the Hadoop configuration files to automatically balance job parallelism and job throughput depending on the characteristics of ongoing concurrent workloads.

We have published two papers on this self-balancing approach:
* [Self-Balancing Job Parallelism and Throughput in Hadoop](https://hal.inria.fr/hal-01294834)
* [Self-configuration of the Number of Concurrently Running MapReduce Jobs in a Hadoop Cluster](https://hal.inria.fr/hal-01143157)

The self-balancing approach is realized by a Feedback Control Loop based on typical MAPE cycle as shown below.

 ![The feedback control loop of self-balancing approach](/figures/loop.png)
 
Concluding with many experiments of various MapReduce jobs, we can say that this approach can obviously improve the system performance of Hadoop cluster while processing concurrent workloads.

 ![The result comparison between self-balancing approach and default static configurations](/figures/diff-type-size.png)
