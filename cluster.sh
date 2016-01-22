#!/bin/bash
set -e

# TODO: colorful log
# TODO: add debug for the commands, different color and separate from the log messages
# TODO: create compute nodes in parallel

DRIVER=${DRIVER:-'virtualbox'}
NUM_COMPUTE_NODES=${NUM_COMPUTE_NODES:-1}

export VIRTUALBOX_MEMORY_SIZE=${VIRTUALBOX_MEMORY_SIZE:-2048}
export VIRTUALBOX_CPU_COUNT=${VIRTUALBOX_CPU_COUNT:-1}
export VIRTUALBOX_BOOT2DOCKER_URL=${VIRTUALBOX_BOOT2DOCKER_URL:-'https://github.com/AkihiroSuda/boot2docker/releases/download/v1.9.1-fix1/boot2docker-v1.9.1-fix1.iso'}

# private constants
declare -r docker_name_prefix='hadoop'
declare -r network_name='hadoop-net'
declare -r script_name="$(basename $0)"
declare -r consul_node_name="$docker_name_prefix-consul"
declare -r controller_node_name="$docker_name_prefix-controller"
declare -r compute_node_name="$docker_name_prefix-compute"

# flags
noop='false'
force='false'
recreate='false'
debug='false'

log() {
  echo "$(tput setaf 2)[$script_name]$(tput sgr0): $@"
}

debug() {
  [[ "$debug" == 'true' ]] && log $@
}

error() {
  echo >&2 "[$script_name]: $@"
}

run() {
  cmd=$@
  cmd=${cmd//$'\n'/' '}

  if [[ "$noop" == 'true' ]]; then
    log "---> $cmd"
  else
    debug "---> $cmd"
    $@
  fi
}

destroy_machine() {
  name=$1
  shift

  stop_machine $name

  log "checking status of docker machine: $name"
  status=$(docker-machine status $name 2> /dev/null || echo 'Nonexistent')

  case "$status" in
    Nonexistent)
      log "docker machine $name does not exists"
      # no more work
    ;;

    *)
      log "trying to destroy docker machine $name..."
      run docker-machine rm -y $([[ "$force" == "true" ]] && "echo -f") $name
  esac
}

stop_machine() {
  name=$1
  shift

  log "checking status of docker machine: $name"
  status=$(docker-machine status $name 2> /dev/null || echo 'Nonexistent')

  case "$status" in
    Running)
      log "docker machine $name is running, stopping..."
      run docker-machine stop $name
    ;;

    Stopped)
      log "docker machine $name is already stopped"
      # no more work
    ;;

    Nonexistent)
      log "docker machine $name does not exists"
      # no more work
    ;;

    *)
      log "trying to stop docker machine $name..."
      run docker-machine stop $name
  esac

}

start_machine() {
  name=$1
  shift

  [[ "$recreate" == "true" ]] && destroy_machine $name

  # check if it exists
  log "checking status of docker machine: $name"
  status=$(docker-machine status $name 2> /dev/null || echo 'Nonexistent')

  case "$status" in
    Running)
      log "docker machine $name is running"
      # no work needed
    ;;

    Stopped)
      log "docker machine $name is stopped, starting..."
      run docker-machine start $name
    ;;

    Nonexistent)
      log "docker machine $name does not exists, creating..."
      run docker-machine create -d $DRIVER $@ $name
    ;;

    *)
      error "$status: of docker machine $name has to be attended manually, to connect use 'docker-machine $name'"
      exit 1
  esac
}

destroy_container() {
  machine=$1
  shift
  name=$1
  shift

  docker_conn=$(docker-machine config $machine)

  # check if it exists
  log "checking status of docker container: $name@$machine"
  status=$(docker $docker_conn inspect -f '{{.State.Status}}' $name 2> /dev/null || echo 'nonexistent')

  case "$status" in
    nonexistent)
      log "docker container $name@$machine does not exist"
      # no more work
    ;;

    *)
      log "trying to remove docker container: $name@$machine..."
      run docker $docker_conn rm $([[ "$force" == 'true' ]] && echo '-f') $name
  esac
}

stop_container() {
  machine=$1
  shift
  name=$1
  shift

  docker_conn=$(docker-machine config $machine)

  # check if it exists
  log "checking status of docker container: $name@$machine"
  status=$(docker $docker_conn inspect -f '{{.State.Status}}' $name 2> /dev/null || echo 'nonexistent')

  case "$status" in
    running)
      if [[ "$force" == 'true' ]]; then
        log "[force] docker container $name@$machine is running, killing..."
        run docker $docker_conn kill $name
      else
        log "docker container $name@$machine is running, stopping..."
        run docker $docker_conn stop $name
      fi
    ;;

    exited)
      log "docker container $name@$machine is not running"
      # no more work
    ;;

    nonexistent)
      log "docker container $name@$machine does not exist"
      # no more work
    ;;

    *)
      log "trying to remove docker container $name@$machine..."
      run docker $docker_conn kill $([[ "$force" == 'true' ]] && echo '-f') $name
  esac

}

start_container() {
  machine=$1
  shift
  name=$1
  shift

  [[ "$recreate" == 'true' ]] && destroy_container $machine $name

  docker_conn=$(docker-machine config $machine)

  log "checking status of docker container: $name@$machine"
  status=$(docker $docker_conn inspect -f "{{.State.Status}}" $name 2> /dev/null || echo 'nonexistent')

  case "$status" in
    running)
      log "docker container $name@$machine is running"
      # no work needed
    ;;

    exited)
      log "docker container $name@$machine is not running, starting..."
      run docker $docker_conn start $name
    ;;

    nonexistent)
      log "docker container $name@$machine does not exist, starting..."
      run docker $docker_conn run --name $name $@
    ;;

    *)
      echo >&2 "$status: of docker container $name@$machine has to be attended manually, to connect use 'docker $docker_conn'"
      exit 1
  esac
}

destroy_image() {
  machine=$1
  shift
  name=$1
  shift

  docker_conn=$(docker-machine config $machine)

  log "checking status of docker image: $name:latest on machine $machine"
  if ! docker $docker_conn inspect $name:latest > /dev/null 2>&1; then
    log "docker image $name:latest does not exist on machine $machine"
  else
    log "docker image $name:latest exists on machine $machine"
    run docker $docker_conn rmi $([[ "$force" == 'true' ]] && echo '-f') $name
  fi
}

create_image() {
  machine=$1
  shift
  name=$1
  shift
  dir=$1
  shift

  [[ "$recreate" == 'true' ]] && destroy_image $machine $name

  docker_conn=$(docker-machine config $machine)

  log "checking status of docker image: $name:latest on machine $machine"
  if ! docker $docker_conn inspect $name:latest > /dev/null 2>&1; then
    log "docker image $name:latest does not exist on machine $machine, creating..."
    run docker $docker_conn build -t $name $dir
  else
    log "docker image $name:latest exists on machine $machine"
  fi
}

destroy_network() {
  machine=$1
  shift
  name=$1
  shift

  docker_conn=$(docker-machine config --swarm $machine)

  log "trying to remove existing docker network $name on $machine..."
  run docker $docker_conn network rm $name
}

create_network() {
  machine=$1
  shift
  name=$1
  shift

  [[ "$recreate" == 'true' ]] && destroy_network $machine $name

  docker_conn=$(docker-machine config --swarm $machine)

  # check if it exists
  log "checking status of docker network: $name on $machine"
  if ! docker $docker_conn network inspect $name > /dev/null 2>&1; then
    log "docker network $name does not exist, creating using: '$cmd'"
    run docker $docker_conn network create -d overlay $@ $name
  else
    log "docker network $name already exist"
    # no more work
  fi
}

create_cluster() {
  # setup consul node
  VIRTUALBOX_MEMORY_SIZE=512 \
  start_machine $consul_node_name

  # start consul container
  start_container $consul_node_name consul -d -p "8500:8500" -h consul progrium/consul -server -bootstrap

  # consul connection string
  consul_conn="consul://$(docker-machine ip $consul_node_name):8500"

  # setup controller
  start_machine $controller_node_name \
    --swarm \
    --swarm-master \
    --swarm-discovery="$consul_conn" \
    --engine-label="type=controller" \
    --engine-opt="cluster-store=$consul_conn" \
    --engine-opt="cluster-advertise=eth1:2376"

  # setup compute nodes
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    start_machine "$compute_node_name-$i" \
      --swarm \
      --swarm-discovery="$consul_conn" \
      --engine-label="type=compute" \
      --engine-opt="cluster-store=$consul_conn" \
      --engine-opt="cluster-advertise=eth1:2376"
  done

  # setup network
  create_network "$docker_name_prefix-controller" "$network_name"
}

destroy_cluster() {
  stop_cluster

  # network
  destroy_network $controller_node_name $network_name

  # machines
  cmd="docker-machine ls --filter name=$docker_name_prefix-.*"
  if [[ $($cmd | wc -l) -le 1 ]]; then
    error "No hadoop-* docker machines to be destroyed"
    exit 1
  fi

  $cmd

  echo "$(tput setaf 1)All the above machines will be destroyed$(tput sgr0)"
  read -p "Do you want to continue? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    $cmd -q | xargs docker-machine rm -y$([[ -z $force ]] || echo ' --force')
  fi
}

stop_cluster() {
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    stop_machine "$compute_node_name-$i"
  done

  stop_machine $controller_node_name

  stop_machine $consul_node_name
}

status_cluster() {
  docker-machine ls --filter name=$docker_name_prefix-.*
}

init_hadoop() {
  create_image $controller_node_name "hadoop-benchmark/hadoop-base" "images/hadoop-base"

  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    create_image "$compute_node_name-$i" "hadoop-benchmark/hadoop-base" "images/hadoop-base"
  done
}

destroy_hadoop() {
  stop_hadoop

  destroy_container $controller_node_name controller

  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    destroy_container "$compute_node_name-$i" "compute-$i"
  done
}

stop_hadoop() {
  stop_container $controller_node_name controller

  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    stop_container "$compute_node_name-$i" "compute-$i"
  done
}

start_hadoop() {
  recreate='true' create_image $controller_node_name "hadoop-benchmark/hadoop" "images/hadoop"

  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    recreate='true' create_image "$compute_node_name-$i" "hadoop-benchmark/hadoop" "images/hadoop"
  done

  # start controller
  start_container $controller_node_name controller \
    -h controller \
    --net $network_name \
    -p "8088:8088" \
    -e "CONF_CONTROLLER_HOSTNAME=controller" \
    -d \
    hadoop-benchmark/hadoop \
    controller

  # wait for resource manager
  log "Waiting for ResourceManager"
  docker $(docker-machine config $controller_node_name) exec controller \
    bash -c "while ! nc -z localhost 8088; do echo -n '.'; sleep 1; done; echo ''"

  # start computes
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    start_container "$compute_node_name-$i" "compute-$i" \
      -h "compute-$i" \
      --net $network_name \
      -p "8042:8042" \
      -e "CONF_CONTROLLER_HOSTNAME=controller" \
      -d \
      hadoop-benchmark/hadoop \
      compute
  done
}

shell_init() {
  docker-machine env --swarm $controller_node_name
}

# command
command=

while [[ $# > 0 ]]; do
  case $1 in
      -f|--force)
        force='true'
        shift
      ;;
      -r|--recreate)
        recreate='true'
        shift
      ;;
      -d|--debug)
        debug='true'
        shift
      ;;
      -n|--noop)
        noop='true'
        shift
      ;;
      create-cluster|start-cluster)
        command='create_cluster'
        shift
      ;;
      stop-cluster)
        command='stop_cluster'
        shift
      ;;
      destroy-cluster)
        command='destroy_cluster'
        shift
      ;;
      status-cluster)
        command='status_cluster'
        shift
      ;;
      init-hadoop)
        command='init_hadoop'
        shift
      ;;
      destroy-hadoop)
        command='destroy_hadoop'
        shift
      ;;
      stop-hadoop)
        command='stop_hadoop'
        shift
      ;;
      start-hadoop)
        command='start_hadoop'
        shift
      ;;
      shell-init)
        command='shell_init'
        shift
      ;;
      *)
        echo >&2 "$1: unknown argument"
        exit 1
      ;;
  esac
done

if [[ -z $command ]]; then
  echo >&2 "Usage: $0 {create|destroy} [-f|--force]"
  exit 1
fi

$command
