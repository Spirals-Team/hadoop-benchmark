#!/bin/bash

vm=$1
endpoint=$2
public_port=$3
private_port=$4

if azure vm endpoint show $vm $endpoint | grep -q "not found"; then
  echo "creating endpoint $endpoint on $vm for $public_port:$private_port"
  azure vm endpoint create $vm -n $endpoint $public_port $private_port
fi
