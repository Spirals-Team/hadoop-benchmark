#!/bin/bash

rm data/hosts

docker stop $(docker ps -a -q)

docker rm $(docker ps -a -q)
