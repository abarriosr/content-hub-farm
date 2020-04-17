#!/bin/bash

TEMPLATE=$1

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEMPLATE_DIRECTORY=${SCRIPT_DIRECTORY}/${TEMPLATE}
DOCKER_COMPOSE_YAML=${SCRIPT_DIRECTORY}/../../docker-compose.yml

# @TODO: Detect existent docker-compose.yml, print it... back it up and proceed to replace it.

# Creating template.
echo "" > ${DOCKER_COMPOSE_YAML}
sh ${TEMPLATE_DIRECTORY}/database.tpl.sh >> ${DOCKER_COMPOSE_YAML}
sh ${TEMPLATE_DIRECTORY}/publisher.tpl.sh >> ${DOCKER_COMPOSE_YAML}
sh ${TEMPLATE_DIRECTORY}/subscriber.tpl.sh >> ${DOCKER_COMPOSE_YAML}
sh ${TEMPLATE_DIRECTORY}/network_volume.tpl.sh >> ${DOCKER_COMPOSE_YAML}

echo "Created Configuration file: `basename ${DOCKER_COMPOSE_YAML}.`"
