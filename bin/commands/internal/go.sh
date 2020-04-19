#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Content Hub Farm Full Installation"
echo "----------------------------------"
echo "You are going to do a full installation of Content Hub Farm."
echo "If have code in the 'html' directory, it will be deleted and recreated based on your input."
echo "If you have already a 'docker-compose.yml' or '~/.ngrok2/ngrok.yml' file, they will be replaced by new ones."
echo "Make sure to backup any information before executing this command."
echo ""
read -p "Do you want to proceed? (y/n) " line
if [[ ! $line =~ ^[yY]$ ]] ; then
  echo "Aborted."
  exit;
fi

# Stopping containers
echo "Stopping running containers and removing them all including volumes..."
docker-compose down -v
echo "Done."

# Stopping ngrok service.
echo "Killing Ngrok Service..."
pkill -9 ngrok
echo "Done."

# Starting installation.
cd $SCRIPT_DIRECTORY/../../../ || return

# Setting up Configuration file setup_options.sh
sh $SCRIPT_DIRECTORY/setup.sh

echo ""
echo "Starting Installation. This process might take a while..."
echo ""

# Reading configuration options.
source $SCRIPT_DIRECTORY/../../../setup_options.sh

# Building Source code.
if [ "${CONFIG_BUILD_CODE_SOURCE}" == 'public' ] ; then
  sh $SCRIPT_DIRECTORY/build_code.sh
else
  sh $SCRIPT_DIRECTORY/build_code.sh ${CONFIG_BUILD_CODE_BRANCH} ${CONFIG_BUILD_CODE_SOURCE}
fi

# Building containers.
echo "Building Docker containers."
docker-compose build
echo "Done."

# Starting ngrok service.
ngrok start --all --config="${HOME}/.ngrok2/ngrok.yml" &

# Starting Containers.
sh $SCRIPT_DIRECTORY/up.sh