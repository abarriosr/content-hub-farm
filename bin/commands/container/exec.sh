#!/bin/bash

# Executes a command in the docker container.
CONTAINER=$1

# Eliminating first argument to pass to command script.
args=""
for i in "$@" ; do
  if [ "$i" != "$1" ]; then
    args="${args} $i"
  fi
done
# Executing command.
docker exec -it $CONTAINER $args
