#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Restart services.
echo "Restarting services..."
docker-compose restart $args

# Site Installation.
sh $SCRIPT_DIRECTORY/../../include/site_installation.sh
