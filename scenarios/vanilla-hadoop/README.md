#Vanilla Hadoop Cluster

This Hadoop Cluster is based on the new version of Hadoop (YARN) which has a great overhaul on its architecture.
In the new version, developers add a new component called YARN which is responsible for job management which is extracted from previous Mapreduce framework.
In this case, there a special component for job scheduling and Resource monitoring in hadoop.
This new architecture makes each component (layer) can only focus on its own responsibility and strengths the stability of Hadoop Cluster.

YARN also has three subcomponents:
- ResourceManager
- NodeManager
- Container

In these components, `ResourceManager` and `NodeManager` are used for Resource Monitoring over the whole Hadoop Cluster.
The `Container`, in fact, is a block of resources in each compute nodes of Hadoop Cluster.
It has two different types: 

- MRAppMaster : This container can be regarded as a private controller for its corresponding job and a scheduler for its affiliated tasks.
- YarnChild : This container only process the assigned tasks.

Thank to the `container` component of YARN, each submitted job can create a sub distributed system for itself inside the compute nodes of Hadoop Cluster, resulting in job-level self-managing mechanism for Hadoop.

The architecture of YARN is illustrated below and further informations can be found [here](https://hadoop.apache.org/docs/r2.7.2/hadoop-yarn/hadoop-yarn-site/):

 ![The architecture of YARN](/figures/yarn.png)