#!/bin/bash

TEMPLATE=$1

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEMPLATE_DIRECTORY=${SCRIPT_DIRECTORY}/${TEMPLATE}
DOCKER_COMPOSE_YML=${SCRIPT_DIRECTORY}/../../docker-compose.yml

# Detect existing docker-compose.yml, and if so back it up and proceed to replace it.
if [ -f $DOCKER_COMPOSE_YML ]; then
  DOCKER_COMPOSE_YML_BACK="`dirname "${DOCKER_COMPOSE_YML}"`/docker-compose"
  num=`ls ${DOCKER_COMPOSE_YML_BACK}* | wc -l | xargs`
  DOCKER_COMPOSE_YML_BACK=$DOCKER_COMPOSE_YML_BACK${num}.yml
  # Backing up existent docker-compose.yml.
  echo "Backing up existing docker-compose.yml to docker-compose${num}.yml"
  mv $DOCKER_COMPOSE_YML $DOCKER_COMPOSE_YML_BACK
fi

# Creating template.
echo "" > ${DOCKER_COMPOSE_YML}
sh ${TEMPLATE_DIRECTORY}/database.tpl.sh >> ${DOCKER_COMPOSE_YML}
sh ${TEMPLATE_DIRECTORY}/publisher.tpl.sh >> ${DOCKER_COMPOSE_YML}
sh ${TEMPLATE_DIRECTORY}/subscriber.tpl.sh >> ${DOCKER_COMPOSE_YML}
sh ${TEMPLATE_DIRECTORY}/network_volume.tpl.sh >> ${DOCKER_COMPOSE_YML}

echo "Created Configuration file: `basename ${DOCKER_COMPOSE_YML}.`"
