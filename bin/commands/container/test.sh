#!/bin/bash

# Executes a phpunit test in the docker container.
CONTAINER=$1

# Eliminating first argument to pass to command script.
args=""
for i in "$@" ; do
  if [ "$i" != "$1" ]; then
    # Removing "html/web/" from the arguments.
    i=${i//html\/web\//}
    args="${args} $i"
  fi
done
# Executing phpunit test.
docker exec -t -w /var/www/html/web $CONTAINER /usr/local/bin/phpunit.sh $args
