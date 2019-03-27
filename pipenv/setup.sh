#!/bin/bash

script_dir="$(dirname "$(readlink -f "$0")")"
ln -s $script_dir/docker-pipenv.sh /usr/local/bin/pipenv

