#!/bin/bash
set -e

[[ -f $CONFIG ]] && source $CONFIG

CLUSTER_NAME_PREFIX=${CLUSTER_NAME_PREFIX:-'local-hadoop'}

declare -r controller_node_name="$CLUSTER_NAME_PREFIX-controller"
declare -r controller_conn="$(docker-machine config $controller_node_name)"
