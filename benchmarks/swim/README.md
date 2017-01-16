# SWIM

Benchmark based on [SWIM](https://github.com/SWIMProjectUCB/SWIM).

## Image

In this example, we generated a simple concurrent workload which only consists of 50 Mapreduce jobs.
The workloads files are visible under `image/SWIM` directory.

Users can also generate new Mapreduce workloads by following SWIM tutorial, and only replace the workloads files under `image/SWIM` by those of new workloads.

PS: To facilitate users to collect the log files of SWIM, we modified `run-all-jobs.sh`.
When users replace the example by new workloads, please add the bellow code to the end of `run-all-jobs.sh` file.

```sh
for job in `jobs -p`
do
  echo "Waiting for $job to finish"
  wait $job
done

logs="workGenLogs-$(date +"%Y%m%d-%H%M").tgz"
tar cfvz "$logs" "$SWIM_HOME/workGenLogs"
hdfs dfs -put "$logs" "/user/root/$logs"
```

## Analysis

In `analysis` directory, we provide a simple R script to help users analyse the log files and generate graphs.