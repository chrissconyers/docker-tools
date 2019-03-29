#!/bin/bash

script_dir="$(dirname "$(readlink -f "$0")")"
ln -s $script_dir/docker-pandoc.sh /usr/local/bin/pandoc

