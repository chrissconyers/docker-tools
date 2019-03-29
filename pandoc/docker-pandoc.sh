#!/bin/bash

export PUID=$(id -u)
export PGID=$(id -g)
export WORKING_DIR=$PWD

cd "$(dirname "$(readlink -f "$0")")"
docker-compose run --rm pandoc pandoc "$@"

