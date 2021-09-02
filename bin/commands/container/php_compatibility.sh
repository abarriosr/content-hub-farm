#!/bin/bash

# Executes a drush command in the docker container.
CONTAINER=$1

# Eliminating first argument to pass to command script.
args=""
for i in "$@" ; do
  if [ "$i" != "$1" ]; then
    args="${args} $i"
  fi
done
# Executing drush command.
docker exec -t -w /var/www/html $CONTAINER /usr/local/bin/check-php-compatibility.sh $args
