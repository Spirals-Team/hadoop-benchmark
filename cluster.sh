#!/bin/bash
set -e

# allow to easily override common settings
[[ -f $CONFIG ]] && source $CONFIG

# basics
DRIVER=${DRIVER:-'virtualbox'}
NUM_COMPUTE_NODES=${NUM_COMPUTE_NODES:-1}
CLUSTER_NAME_PREFIX=${CLUSTER_NAME_PREFIX:-'local-hadoop'}
CLUSTER_ADVERTISE=${CLUSTER_ADVERTISE:-'eth1:2376'}
HADOOP_IMAGE=${HADOOP_IMAGE:-'hadoop-benchmark/hadoop'}
HADOOP_IMAGE_DIR=${HADOOP_IMAGE_DIR:-'images/hadoop'}

# extension points
EXT_AFTER_CONSUL_MACHINE=${EXT_AFTER_CONSUL_MACHINE:-''}
EXT_AFTER_CONTROLLER_MACHINE=${EXT_AFTER_CONTROLLER_MACHINE:-''}
EXT_AFTER_COMPUTE_MACHINE=${EXT_AFTER_COMPUTE_MACHINE:-''}

# all driver related settings must be exported
export VIRTUALBOX_MEMORY_SIZE=${VIRTUALBOX_MEMORY_SIZE:-2048}
export VIRTUALBOX_CPU_COUNT=${VIRTUALBOX_CPU_COUNT:-1}
export VIRTUALBOX_BOOT2DOCKER_URL=${VIRTUALBOX_BOOT2DOCKER_URL:-'https://github.com/AkihiroSuda/boot2docker/releases/download/v1.9.1-fix1/boot2docker-v1.9.1-fix1.iso'}

# private constants
declare -r docker_name_prefix="$CLUSTER_NAME_PREFIX"
declare -r network_name='hadoop-net'
declare -r script_name="$(basename $0)"
declare -r consul_node_name="$docker_name_prefix-consul"
declare -r controller_node_name="$docker_name_prefix-controller"
declare -r compute_node_name="$docker_name_prefix-compute"

# flags
noop='false'
force='false'
recreate='false'
debug='true'

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
    log "===> $cmd"
  else
    debug "===> $cmd"
    "$@"
  fi
}

run_docker() {
  case "$1" in
    --swarm)
      swarm="--swarm"
      shift
    ;;
  esac

  machine=$1
  shift

  status=$(docker-machine status $machine 2> /dev/null)

  case "$status" in
    Running)
      docker_conn=$(docker-machine config $swarm $machine)
      run docker $docker_conn "$@"
    ;;
    *)
      error "docker machine $machine is not running, unable to run: docker $@"
      exit 1
  esac
}

wait_for_port() {
  ip=$1
  port=$2

  while ! nc -z $ip $port > /dev/null; do
    log "Waiting for $ip:$port ..."
    sleep 1
  done
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

check_docker_container() {
  machine=$1
  shift
  name=$1
  shift

  docker_conn=$(docker-machine config $machine)
  docker $docker_conn inspect -f '{{.State.Status}}' $name 2> /dev/null || echo 'nonexistent'
}

destroy_container() {
  machine=$1
  shift
  name=$1
  shift

  # check if it exists
  log "checking status of docker container: $name@$machine"
  status=$(check_docker_container $machine $name)

  case "$status" in
    nonexistent)
      log "docker container $name@$machine does not exist"
      # no more work
    ;;

    *)
      log "trying to remove docker container: $name@$machine..."
      run_docker $machine rm $([[ "$force" == 'true' ]] && echo '-f') $name
  esac
}

stop_container() {
  machine=$1
  shift
  name=$1
  shift

  # check if it exists
  log "checking status of docker container: $name@$machine"
  status=$(check_docker_container $machine $name)

  case "$status" in
    running)
      if [[ "$force" == 'true' ]]; then
        log "[force] docker container $name@$machine is running, killing..."
        run_docker $machine kill $name
      else
        log "docker container $name@$machine is running, stopping..."
        run_docker $machine stop $name
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
      run_docker $machine kill $([[ "$force" == 'true' ]] && echo '-f') $name
  esac

}

start_container() {
  machine=$1
  shift
  name=$1
  shift

  [[ "$recreate" == 'true' ]] && destroy_container $machine $name

  log "checking status of docker container: $name@$machine"
  status=$(check_docker_container $machine $name)

  case "$status" in
    running)
      log "docker container $name@$machine is running"
      # no work needed
    ;;

    exited)
      log "docker container $name@$machine is not running, starting..."
      run_docker $machine start $name
    ;;

    nonexistent)
      log "docker container $name@$machine does not exist, starting..."
      run_docker $machine run --name $name $@
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

  log "checking status of docker image: $name:latest on machine $machine"
  if ! run_docker $machine inspect $name:latest > /dev/null 2>&1; then
    log "docker image $name:latest does not exist on machine $machine"
  else
    log "docker image $name:latest exists on machine $machine"
    run_docker $machine rmi $([[ "$force" == 'true' ]] && echo '-f') $name
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

  log "checking status of docker image: $name:latest on machine $machine"
  if ! run_docker $machine inspect $name:latest > /dev/null 2>&1; then
    log "docker image $name:latest does not exist on machine $machine, creating..."
    run_docker $machine build -t $name $dir
  else
    log "docker image $name:latest exists on machine $machine"
  fi
}

build_image() {
  name=$1
  dir=$2

  create_image $controller_node_name $name $dir

  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    create_image "$compute_node_name-$i" $name $dir
  done
}

destroy_network() {
  machine=$1
  shift
  name=$1
  shift

  if [[ $(docker-machine status $name 2> /dev/null) == 'Running' ]]; then
    log "trying to remove existing docker network $name on $machine..."
    run_docker $machine network rm $name
  else
    log "docker machine $machine is not running, skipping"
  fi

}

create_network() {
  machine=$1
  shift
  name=$1
  shift

  [[ "$recreate" == 'true' ]] && destroy_network $machine $name

  # check if it exists
  log "checking status of docker network: $name on $machine"
  if ! run_docker $machine network inspect $name > /dev/null 2>&1; then
    log "docker network $name does not exist, creating using: '$cmd'"
    run_docker $machine network create -d overlay $@ $name
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

  # extension point
  [[ -z $EXT_AFTER_CONSUL_MACHINE ]] || $EXT_AFTER_CONSUL_MACHINE $consul_node_name

  # setup controller
  start_machine $controller_node_name \
    --swarm \
    --swarm-master \
    --swarm-discovery="$consul_conn" \
    --engine-label="type=controller" \
    --engine-opt="cluster-store=$consul_conn" \
    --engine-opt="cluster-advertise=$CLUSTER_ADVERTISE"

  # extension point
  [[ -z $EXT_AFTER_CONTROLLER_MACHINE ]] || $EXT_AFTER_CONTROLLER_MACHINE $controller_node_name

  # setup compute nodes
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    local name="$compute_node_name-$i"
    start_machine $name \
      --swarm \
      --swarm-discovery="$consul_conn" \
      --engine-label="type=compute" \
      --engine-opt="cluster-store=$consul_conn" \
      --engine-opt="cluster-advertise=$CLUSTER_ADVERTISE"

    # extension point
    [[ -z $EXT_AFTER_COMPUTE_MACHINE ]] || $EXT_AFTER_COMPUTE_MACHINE $name
  done

  # setup network
  create_network "$docker_name_prefix-controller" "$network_name"
}

destroy_cluster() {
  # network
  destroy_network $controller_node_name $network_name

  stop_cluster

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

restart_cluster() {
  destroy_cluster
  recreate='true' create_cluster
  echo "You should reconnect to docker: 'eval \$(docker-machine env --swarm "$controller_node_name")'"
}

status_cluster() {
  run docker-machine ls --filter "name=$docker_name_prefix-.*"
}

destroy_hadoop() {
  stop_hadoop

  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    destroy_container "$compute_node_name-$i" "compute-$i"
  done

  destroy_container $controller_node_name controller

  destroy_container $controller_node_name graphite
}

stop_hadoop() {
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    stop_container "$compute_node_name-$i" "compute-$i"
  done

  stop_container $controller_node_name controller

  stop_container $controller_node_name graphite
}

start_hadoop() {
  if [[ "$recreate" == 'true' ]]; then
    destroy_hadoop
  fi

  build_image $HADOOP_IMAGE $HADOOP_IMAGE_DIR

  # start graphite frontend
  start_container $controller_node_name graphite \
    -d \
    -h graphite \
    --restart=always \
    --net $network_name \
    -p 80:80 \
    -p 2003:2003 \
    -p 8125:8125/udp \
    -p 8126:8126 \
    hopsoft/graphite-statsd

  # start controller
  start_container $controller_node_name controller \
    -h controller \
    --net $network_name \
    -p "8088:8088" \
    -p "50070:50070" \
    -e "CONF_CONTROLLER_HOSTNAME=controller" \
    -d \
    $HADOOP_IMAGE \
    controller

  # wait for resource manager
  log "Waiting for ResourceManager"
  wait_for_port $(docker-machine ip $controller_node_name) 8088
  # run_docker $controller_node_name exec controller \
  #   bash -c "while ! nc -z localhost 8088; do echo -n '.'; sleep 1; done; echo"

  # start computes
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    local name="compute-$i"
    local machine="$compute_node_name-$i"
    start_container $machine $name \
      -h $name \
      --net $network_name \
      -p "8042:8042" \
      -p "50075:50075" \
      -e "CONF_CONTROLLER_HOSTNAME=controller" \
      -d \
      $HADOOP_IMAGE \
      compute

    # wait for node manager
    log "Waiting for NodeManager on $name"
    wait_for_port $(docker-machine ip $machine) 8042
    # run_docker $controller_node_name exec controller \
    #   bash -c "while ! nc -z localhost 8042; do echo -n '.'; sleep 1; done; echo"
  done

  echo "Hadoop should be ready"
  connect_info
}

restart_hadoop() {
  destroy_hadoop
  recreate='true' start_hadoop
}

connect_info() {
  echo "To connect docker run: 'eval \$(docker-machine env --swarm "$controller_node_name")'"
  echo "To connect a bash console to the cluster run: './benchmarks/console.sh'"
  echo "To connect to Graphite (WEB console visualizing collectd data), visit http://$(docker-machine ip $controller_node_name)"
  echo "To connect to YARN ResourceManager WEB UI, visit http://$(docker-machine ip $controller_node_name):8088"
  echo "To connect to HDFS NameNode WEB UI, visit http://$(docker-machine ip $controller_node_name):50070"
  echo "To connect to YARN NodeManager WEB UI, visit:"
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    echo "http://$(docker-machine ip "$compute_node_name-$i"):8042 for compute-$i"
  done
  echo "To connect to HDFS DataNode WEB UI, visit:"
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    echo "http://$(docker-machine ip "$compute_node_name-$i"):50075 for compute-$i"
  done
  echo
  echo "If you plan to use YARN WEB UI more extensively, consider to add the following records to your /etc/hosts:"
  echo "$(docker-machine ip $controller_node_name) controller"
  for i in $(seq 1 $NUM_COMPUTE_NODES); do
    echo "$(docker-machine ip "$compute_node_name-$i") compute-$i"
  done
}

shell_init() {
  docker-machine env --swarm $controller_node_name
}

console() {
  start_container $controller_node_name console \
    -it \
    --rm \
    --net hadoop-net \
    -h hadoop-console \
    $HADOOP_IMAGE \
    console
}

print_help() {
cat <<EOM
Usage $0 [OPTIONS] COMMAND

Options:

  -f, --force   Use '-f' in docker commands where applicable
  -n, --noop    Only shows which commands would be executed wihout actually executing them
  -q, -quiet    Do not print which commands are executed

Commands:

  Cluster:
    create-cluster
    start-cluster
    stop-cluster
    restart-cluster
    destroy-cluster
    status-cluster

  Hadoop:
    start-hadoop
    stop-hadoop
    restart-hadoop
    destroy-hadoop

  Misc:
    console         Enter a bash console in a container connected to the cluster

  Info:
    shell-init      Shows information how to initialize current shell to connect to the cluster
                    Useful to execute like: 'eval \$($0 shell-init)'
    connect-info    Shows information how to connect to the cluster
EOM
}

# command
command=

while [[ $# > 0 ]]; do
  case $1 in
      -h|--help)
        print_help
        exit 1
      ;;
      -f|--force)
        force='true'
        shift
      ;;
      -q|--quiet)
        debug='false'
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
      restart-cluster)
        command='restart_cluster'
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
      restart-hadoop)
        command='restart_hadoop'
        shift
      ;;
      shell-init)
        command='shell_init'
        shift
      ;;
      connect-info)
        command='connect_info'
        shift
      ;;
      console)
        command='console'
        shift
      ;;
      *)
        echo >&2 "$1: unknown argument"
        exit 1
      ;;
  esac
done

if [[ -z $command ]]; then
  print_help
  exit 1
fi

$command
