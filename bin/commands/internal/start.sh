#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Start services.
echo "Start services..."
docker-compose start $args

# Site Installation.
sh $SCRIPT_DIRECTORY/../../include/site_installation.sh
