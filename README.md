## Overview

Hadoop-Benchmark is an open-source research acceleration platform for rapid prototyping and evaluation of self-adaptive behaviors in Hadoop clusters.
The main objectives are to allow researchers to

− _rapidly prototype_, i.e., to experiment with self-adaptation in Hadoop clusters without the need to cope with low-level system infrastructure details,

− _reproduction_, i.e., to share complete experiments for others to reproduce them independently, and

− _repetition_, i.e., to experiment with and to compare their work, re-doing the same experiments on the same system using the same evaluation methods.

It uses [docker](https://www.docker.com/products/docker-engine) and [docker-machine](https://www.docker.com/products/docker-machine) to easily create a multi-node cluster (on a single laptop or in a cloud including [Grid5000](https://github.com/Spirals-Team/docker-machine-driver-g5k)) and provision Hadoop.
It contains a number of acknowledged [benchmarks](https://github.com/Spirals-Team/hadoop-benchmark/tree/master/benchmarks) and one self-adaptive [scenario](https://github.com/Spirals-Team/hadoop-benchmark/tree/master/scenarios/self-balancing-example).

The following is the high-level overview of the created cluster and deployed services:
![architecture](https://www.evernote.com/shard/s15/sh/f49ba1b9-b09b-4bce-8919-43e7f3cfffb2/a5254cdbaffe15de/res/4a92c1e1-055f-44b9-bac2-9197f815b8c1/architecture.png?resizeSmall&width=832)

## Requirements

- docker >= 1.12
- docker-machine >= 0.8
- (optional) R >= 3.3.2 with tidyverse and Hmisc for data analysis

## Usage

```
./cluster.sh                                                                              ✓
Usage ./cluster.sh [OPTIONS] COMMAND

Options:

  -f, --force   Use '-f' in docker commands where applicable
  -n, --noop    Only shows which commands would be executed wihout actually executing them
  -q, --quiet   Do not print which commands are executed

Commands:

  Cluster:
    create-cluster
    start-cluster
    stop-cluster
    restart-cluster
    destroy-cluster
    status-cluster

  Hadoop:
    start-hadoop
    stop-hadoop
    restart-hadoop
    destroy-hadoop

  Misc:
    console                   Enter a bash console in a container connected to the cluster
    run-controller CMD        Run a command CMD in the controller container
    hdfs CMD                  Run the HDFS CMD command
    hdfs-download SRC         Download a file from HDFS SRC to current directory

  Info:
    shell-init      Shows information how to initialize current shell to connect to the cluster
                    Useful to execute like: 'eval $(./cluster.sh shell-init)'
    connect-info    Shows information how to connect to the cluster
```

## Documentation

- check the [tutorial](https://github.com/Spirals-Team/hadoop-benchmark/wiki/Tutorial) to get started.

- check the [screencast](https://asciinema.org/a/8bibyzinreyz30f0dkjk75yhv)

- check the [demonstration](https://youtu.be/T6m4OM3nvGc) of using hadoop-benchmark on Grid5000

