#!/bin/bash

# Disables Xdebug in the docker container.
CONTAINER=$1

echo "Disabling Xdebug in container ${CONTAINER}"
docker exec -t $CONTAINER /usr/local/bin/disable_xdebug.sh
echo "Done."