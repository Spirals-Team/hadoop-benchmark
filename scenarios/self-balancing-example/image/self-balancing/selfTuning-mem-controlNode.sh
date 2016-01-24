#!/bin/bash
newtime="10"
str=""
lastline=""

#Log file should be modified when control node is changed.
logfile="yarn-root-resourcemanager-$(hostname).log"
str=$(tail -n 1 /usr/local/hadoop/logs/$logfile)
newtime=$(echo $str | cut -d "," -f 1)
str=""

str=$(tail -n 1000 /usr/local/hadoop/logs/$logfile | grep "$newtime" | grep 'used=<memory:' | grep 'cluster=<memory:')
newtime="10"

if [ -n "$str" ]
then
	lastline=$(echo $str | tr "\n" "&" | rev | cut -d "&" -f 2 | rev)
#Time
	newtime=$(date --date="$(echo $lastline | cut -d ',' -f 1)" +%s)

	echo $newtime | awk '{print "Time(s): "$1}' | tee -a /self-balancing/memLog

	echo $lastline | sed -e "s=absoluteUsedCapacity\==\&=g" | cut -d "&" -f 2 | cut -d " " -f 1 | awk '{print "absoluteUsedCapacity " $1}' | tee -a /self-balancing/memLog

	echo $lastline | sed -e "s=used\=<memory:=\&=g" | cut -d "&" -f 2 | cut -d "," -f 1 | awk '{print "usedMemory " $1}' | tee -a /self-balancing/memLog

	echo $lastline | sed -e "s=cluster\=<memory:=\&=g" | cut -d "&" -f 2 | cut -d "," -f 1 | awk '{print "clusterMemory " $1}' | tee -a /self-balancing/memLog

	echo ""  | tee -a /self-balancing/memLog
	echo "#########################################"  | tee -a /self-balancing/memLog
	echo ""  | tee -a /self-balancing/memLog
fi
