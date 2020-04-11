#!/bin/bash

# Enables Xdebug in the docker container.
CONTAINER=$1

echo "Enabling Xdebug in container ${CONTAINER}"
docker exec -t $CONTAINER /usr/local/bin/enable_xdebug.sh
echo "Done."