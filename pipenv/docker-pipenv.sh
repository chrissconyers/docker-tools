#!/bin/bash

export PUID=$(id -u)
export PGID=$(id -g)

cd "$(dirname "$(readlink -f "$0")")"
docker-compose run pipenv pipenv "$@"

