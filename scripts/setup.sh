#!/bin/bash

script_dir="$(dirname "$(readlink -f "$0")")"
ln -s $script_dir/docker-clear-logs.sh /usr/local/bin/docker-clear-logs

