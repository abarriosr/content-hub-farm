#!/bin/bash

# Provides a terminal to the container.
CONTAINER=$1

# Executing /bin/bash.
docker exec -it $CONTAINER /bin/bash
