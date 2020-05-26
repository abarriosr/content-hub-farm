#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Provide help if "--help" is provided as argument.
if [ $1 == "--help" ]; then
  echo "This command builds the codebase that will be used to deploy the sites."
  echo ""
  echo "    $./bin/chf build_code <Source> <Content Hub version> <Drupal Core version> <Build Profile>"
  echo ""
  echo "By default, it will download Acquia Content Hub using Drupal's public repository:"
  echo ""
  echo "    $./bin/chf build_code public ^2             ; By default drupal core=^8 and using default profile."
  echo "    $./bin/chf build_code public ^2 ^9"
  echo "    $./bin/chf build_code public ^1 ^8 default"
  echo ""
  echo "To build from Acquia's private repository, use Content Hub branch as an argument:"
  echo ""
  echo "    $./bin/chf build_code private LCH-XXXX             ; By default drupal core=^8 and using default profile."
  echo "    $./bin/chf build_code private                      ; Using 8.x-2.x as default branch."
  echo "    $./bin/chf build_code private 8.x-2.x 9.0.0-beta2"
  echo "    $./bin/chf build_code private LCH-XXXX 9.0.0-beta2 default"
  echo ""
  exit
fi

# Build Code base.

# By default use 'public' repository.
BUILD="${1:-public}"
if [[ ! (-z "$1") && $BUILD != 'public' ]] ; then
  BUILD='private'
fi

# If provided a branch name, use it, otherwise use default 8.x-2.x
ACH_BRANCH=$2
if [ -z "$2" ]; then
  if [ $BUILD != 'public' ] ; then
    ACH_BRANCH=^2
  else
    ACH_BRANCH=8.x-2.x
  fi
fi

# Define default Drupal Core to be "^8".
DRUPAL="${3:-^8}"

# Set Profile. Use "default" profile if not given.
PROFILE="${4:-default}"

# Executing build profile $PROFILE.
bash ${SCRIPT_DIRECTORY}/../../profiles/${PROFILE}.sh ${BUILD} ${ACH_BRANCH} ${DRUPAL}