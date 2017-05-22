# SCENARIOS

The collection of cluste blueprints.

### Creating New Scenario
To create a new scenario, users should create a new Hadoop cluster with proper configurations and their achieved implementation together.
In this case, the self-adaptation scenario can be regarded as a good example to explain how users can create a new scenario with hadoop-benchmark.

For a customized scenario, there are several different files should be generated (the directories of new scenario please strictly respect the same structure of self-adaptation scenario):

- Create new Dockerfile: The `image` directory, in fact, is used for creating the new docker image.
In all the files contained by `image` directory, the `Dockerfile` is the important one.
This file will be used by hadoop-benchmark to create new hadoop docker image which will be used to produce specific Hadoop cluster.
In this file, the commands describe the steps one by one, which customize the Hadoop cluster based on a basic docker image.

>>For example (e.g. `/scenarios/self-balancing-example/image/Dockerfile`),
>>```sh
>>ADD self-balancing /self-balancing
>>```
>>This Dockerfile command inserts our self-balancing approach into the new docker image, and puts it under root directory.
>>```sh
>>ADD capacity-scheduler.xml /usr/local/hadoop/etc/hadoop/
>>```
>>This command replaces a default hadoop configuration file with a new customized one.

>>According to the new Dockerfile, docker engine could generate a new docker image which contains new customized hadoop packages with users' implementations.
With the new docker images, users could easily create a new hadoop cluster by only one command of hadoop-benchmark.

>>To well understand and learn how to create a new Dockerfile, users can get more informations and tutorial [here](https://docs.docker.com/engine/reference/builder/).

- Generat new hadoop-benchmark configuration file: This file will be used in launching command to indicate correct docker image and specific configurations concerning the new Hadoop cluster (e.g. `/scenarios/self-balancing-example/local_cluster`).

>>In fact, users can directly copy the `local_cluster` file from self-adaptation scenario, but please DO NOT forget to modify $HADOOP_IMAGE and $HADOOP_IMAGE_DIR parameters, like:
>>```sh
>>HADOOP_IMAGE='hadoop-benchmark/{new scenario}'
>>HADOOP_IMAGE_DIR='scenarios/{new scenario}/image'
>>```

- Option: generating `after-start.sh` bash is also necessary when there are additional services need to be launched after Hadoop cluster becomes ready (e.g. `/scenarios/self-balancing-example/image/after-start.sh`).
For example, in the case of self-adaptation scenario, our self-balancing approach should be launched after the running of Hadoop cluster.

In these steps, `Create new Dockerfile` is the most important one.
We suggest users to create the new docker images from `spirals/hadoop-benchmark:hadoop-benchmark` docker image which have been shared in DockerHub.
This image only contains the pure hadoop packages and wouldn't cause any disturbs from our examples.
