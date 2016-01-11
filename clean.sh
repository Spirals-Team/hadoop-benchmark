#!/bin/bash

rm /Users/spirals/Desktop/hadoop-env/data/hosts

docker stop $(docker ps -a -q)

docker rm $(docker ps -a -q)
