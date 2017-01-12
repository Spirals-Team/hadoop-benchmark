#!/bin/bash

for i in {0..49}; do cat workGenLogs-Static/job-$i.txt | grep "The job took" | awk -v var=$i '{print var " "  $4}' >> all-jobs-duration-static.txt; done

for i in {0..49}; do cat workGenLogs-Dynamic/job-$i.txt | grep "The job took" | awk -v var=$i '{print var " "  $4}' >> all-jobs-duration-dynamic.txt; done

Rscript analysis.R

pdfjam compare.pdf 2 -o compare.pdf
