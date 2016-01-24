#!/bin/bash
newtime="10"
str=""
lastline=""

#Log file should be modified when control node is changed.
logfile="yarn-root-resourcemanager-$(hostname).log"
str=$(tail -n 1 /usr/local/hadoop/logs/$logfile)
newtime=$(echo $str | cut -d "," -f 1)
str=""

str=$(tail -n 1000 /usr/local/hadoop/logs/$logfile | grep "$newtime" | grep 'pending')
newtime="10"

if [ -n "$str" ]
then
	lastline=$(echo $str | tr "\n" "&" | rev | cut -d "&" -f 2 | rev)
#Time
	newtime=$(date --date="$(echo $lastline | cut -d ',' -f 1)" +%s)

	echo $newtime | awk '{print "Time(s): "$1}' | tee -a /self-balancing/controlNodeLog

#Number of idle jobs
	echo $lastline | cut -d "#" -f 2,3,4,5 | sed -e "s=#==g" | cut -d " " -f 1,2,3,4,5,6,7,8 | tee -a /self-balancing/controlNodeLog

	echo ""  | tee -a /self-balancing/controlNodeLog
	echo "#########################################"  | tee -a /self-balancing/controlNodeLog
	echo ""  | tee -a /self-balancing/controlNodeLog
fi
