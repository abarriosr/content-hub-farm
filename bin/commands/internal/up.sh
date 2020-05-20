#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Creates and starts containers.
echo "Creating and starting containers containers..."
docker-compose up -d $args

# Site Installation.
bash $SCRIPT_DIRECTORY/../../include/site_installation.sh
