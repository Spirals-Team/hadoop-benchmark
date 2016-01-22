#!/bin/bash
oldtime="10"
newtime="10"
str=""
lastline=""

while true
do
#Log file should be modified when control node is changed.
	logfile="yarn-root-resourcemanager-$(hostname).log"
	str=$(tail -n 1 ~/hadoop/logs/$logfile)
	newtime=$(echo $str | cut -d "," -f 1)
	str=""

	str=$(cat ~/hadoop/logs/$logfile | grep "$newtime" | grep 'numApps')
	newtime="10"

	if [ -n "$str" ]
	then
		lastline=$(echo $str | tr "\n" "&" | rev | cut -d "&" -f 2 | rev)
#Time
		newtime=$(date --date="$(echo $lastline | cut -d ',' -f 1)" +%s)

		if [ "$newtime" != "$oldtime" ]
		then
			echo $newtime | awk '{print "Time(s): "$1}' | tee -a numLog
			oldtime=$newtime

			echo $lastline | sed -e "s=numApps\==\&=g" | cut -d "&" -f 2 | cut -d "," -f 1 | awk '{print "numApps " $1}' | tee -a numLog

			echo $lastline | sed -e "s=numContainers\==\&=g" | cut -d "&" -f 2 | cut -d "," -f 1 | awk '{print "numContainers " $1}' | tee -a numLog

			echo ""  | tee -a numLog
			echo "#########################################"  | tee -a numLog
			echo ""  | tee -a numLog
		fi
	fi
	str=""
	lastline=""
	newtime="10"

	sleep 0.9
done

