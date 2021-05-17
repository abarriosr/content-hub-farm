#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Build Code base.

# Project Document Base Root Folder.
BASE_ROOT=html

# Gathering data to build the code base.
GIT_REPOSITORY="${1:-'NONE'}"
GIT_BRANCH="${2:-'NONE'}"

if [ $GIT_REPOSITORY == 'NONE' ] || [ $GIT_BRANCH == 'NONE' ] ; then
  echo "Using existing codebase from '${BASE_ROOT}'."
  echo "---------------------------------------------------"
else
  echo "Building Codebase from Customer Repository using GIT REPOSITORY = '${GIT_REPOSITORY}' and GIT BRANCH = '${GIT_BRANCH}'."
  echo "---------------------------------------------------"
  if [ -d "$BASE_ROOT" ]; then
    echo "Cleaning up existing directory $BASE_ROOT"
    chmod -R 777 $BASE_ROOT
    rm -Rf $BASE_ROOT
  else
    echo "Creating directory $BASE_ROOT"
    mkdir $BASE_ROOT
  fi
  echo "Done."
  echo "Building Drupal project in folder '${BASE_ROOT}'..."
  git clone --branch ${GIT_BRANCH} --single-branch --depth=1 ${GIT_REPOSITORY} ${BASE_ROOT}
  echo "Done."
fi
# echo "Adding Drupal contrib modules..."
cd $BASE_ROOT || exit

# DO NOT MODIFY THIS LIST OF PACKAGES.
# COMPOSER_MEMORY_LIMIT=-1 composer require drupal/environment_indicator \
#  drupal/admin_toolbar \

# -------------------------------------------------------------
# echo "Done."

# Finding the DOCROOT...
# @TODO: Find a better way to find out the docroot.
if [ -d "./docroot" ]
then
    echo "Using directory 'docroot' as the DOCROOT..."
    DOCROOT='docroot';
else
    echo "Using directory 'web' as the DOCROOT..."
    DOCROOT='web';
fi

chmod -R 777 ${DOCROOT}/sites

# Apply Content Hub patch.
PATCH_FILE="${SCRIPT_DIRECTORY}/../../config/patches/no-client-cdf-update.patch"
ACH_FOLDER=`find ./ -iname acquia_contenthub`
cd ${ACH_FOLDER} || exit

echo "Applying patch 'config/patches/no-client-cdf-update.patch'..."
patch -p1 < $PATCH_FILE

# Configure Coding Standards
# ./vendor/bin/phpcs --config-set installed_paths vendor/drupal/coder/coder_sniffer
echo "Done."
