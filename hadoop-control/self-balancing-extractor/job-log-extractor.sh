#!/bin/bash

endwaittime=""
daytime=""
yeartime=""
hmstime=""
starttime=""
finishtime=""

for i in {0..1501};
do
	starttime=$(date --date "$(cat job-$i.txt | grep 'Job started:' | cut -d ' ' -f 3,4,5,6,7,8)" +%s)

	daytime=$(cat job-$i.txt | grep 'Job started:' | cut -d ' ' -f 3,4,5)
	yeartime=$(cat job-$i.txt | grep 'Job started:' | cut -d ' ' -f 7,8)
	hmstime=$(cat job-$i.txt | grep 'running in uber mode' | awk '{print $2}')
	endwaittime="$daytime $hmstime $yeartime"
	endwaittime=$(date --date "$endwaittime" +%s)

	finishtime=$(date --date "$(cat job-$i.txt | grep 'Job ended:' | cut -d ' ' -f 3,4,5,6,7,8)" +%s)	

	echo "$i $starttime $endwaittime $finishtime" >> all-jobs-time.txt
done
