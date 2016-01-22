#!/bin/bash

# step is 0.1
val=.01

# "up" or "down"
policy="up"


while true
do
	date +%s | awk '{print "Time(s) " $1}' | tee -a valueCapacitySchedulerLog
	echo $val | awk '{print "Value " $1}' | tee -a valueCapacitySchedulerLog
	echo " " | tee -a valueCapacitySchedulerLog

	sed -i "s|\(<name>yarn.scheduler.capacity.maximum-am-resource-percent</name><value>\)[^<>]*\(</value>\)|\1${val}\2|g" hadoop/etc/hadoop/capacity-scheduler.xml
	/root/hadoop/bin/yarn rmadmin -refreshQueues

	if [ "$policy" = "up" ]
	then
		val=$(echo "$val + 0.1" | bc)

		if [ $(echo "$val >= 0.51" | bc) -eq 1 ]
		then
			policy="down"
		fi
	else
		val=$(echo "$val - 0.1" | bc)

		if [ $(echo "$val <= 0.01" | bc) -eq 1 ]
		then
			policy="up"
		fi
	fi

	sleep 600
done
