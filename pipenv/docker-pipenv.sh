#!/bin/bash

export PUID=$(id -u)
export PGID=$(id -g)
export WORKING_DIR=$PWD

X_FORWARD=""
if [[ -n $1 ]] && [[ $1 == '-X' ]]; then
  X_FORWARD="-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY"
  shift
fi

cd "$(dirname "$(readlink -f "$0")")"
docker-compose run --rm $X_FORWARD pipenv pipenv "$@"

