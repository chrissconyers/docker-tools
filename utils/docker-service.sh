#!/bin/bash

script_name=$(basename -- $0)
export PUID=$(id -u)
export PGID=$(id -g)

main ()
{
  parse_args $@

  if [ $use_compose ]; then
    if [ $command == "start" ]; then
      start_compose
    elif [ $command == "stop" ]; then
      stop_compose
    elif [ $command == "restart" ]; then
      stop_compose && start_compose
    elif [ $command == "update" ]; then
      update
    fi
  else
    if [ $command == "start" ]; then
      start_swarm
    elif [ $command == "stop" ]; then
      stop_swarm
    elif [ $command == "restart" ]; then
      stop_swarm && start_swarm
    elif [ $command == "update" ]; then
      update
    fi
  fi

  exit
}

start_compose()
{
  cd $compose_dir
  docker-compose up -d
}

stop_compose()
{
  cd $compose_dir
  docker-compose down
}

start_swarm()
{
  docker stack deploy -c $compose_file $stack_name
}

stop_swarm()
{
  docker stack rm $stack_name
}

update()
{
  cd $compose_dir
  docker-compose pull
}

parse_args()
{
  use_compose=true
  stack_name=""
  while getopts "t:s:f:h" opt; do
    case ${opt} in
      f )
        compose_file=$OPTARG
        ;;
      t )
        if [ $OPTARG == "compose" ]; then
          use_compose=true
        elif [ $OPTARG == "swarm" ]; then
          use_compose=false
        else
          echo "$script_name: unrecognized type $OPTARG"
          exit
        fi
        ;;
      s )
        stack_name=$OPTARG
        ;;
      h )
        usage
        exit
        ;;
      \? )
        usage
        exit
        ;;
    esac
  done
  shift $((OPTIND -1))

  if [[ -z $1 ]]; then
    command="start"
  elif [ "$1" != "start" ] && [ "$1" != "stop" ] && [ "$1" != "restart" ] && [ "$1" != "update" ]; then
    echo "must use one of the following commands: start, stop, restart, update"
    exit
  else
    command=$1
  fi
  shift

  if [ ! $use_compose ] && [ "$stack_name" == "" ]; then
    echo "must supply a stack name in swarm mode (use -s option)"
    exit
  fi

  if [[ -z $compose_file ]]; then
    echo "must supply a path to compose file (use -f option)"
    exit
  fi

  compose_dir=$(dirname $compose_file)
}

usage ()
{
  bold=$(tput bold)
  normal=$(tput sgr0)

  cat << EOF
Usage:
  $script_name [options] [command]

Command:
  ${bold}start${normal}:   create and run the docker service (default)

  ${bold}stop${normal}:    stop and remove the docker service

  ${bold}restart${normal}: equivalent to stopping and starting a service

  ${bold}update${normal}:  pull the latest docker images for all services

Options:
  -f=<file>   path to the docker-compose.yml file that defines the service(s) to start

  -s=<stack>  name of the docker stack (swarm mode only)

  -t=<type>   type can be compose (default) or swarm 
EOF
}

main $@

