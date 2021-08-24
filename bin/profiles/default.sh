#!/bin/bash

# Build Code base.

# Project Document Root Folder.
DOCROOT=html

# By default use 'public' repository.
BUILD="${1:-'public'}"
if [[ ! (-z "$1") && $BUILD != 'public' ]] ; then
  BUILD='private'
fi

# If provided a branch name, use it, otherwise use default 8.x-2.x
ACH_BRANCH=$2
if [ -z "$2" ]; then
  if [ $BUILD != 'public' ] ; then
    ACH_BRANCH=~2
  else
    ACH_BRANCH=8.x-2.x
  fi
fi

# Define default Drupal Core to be "^8".
DRUPAL="${3:-^8}"

# Detect whether we are installing Drupal 8.* or 9.* to decide versions of Drush and Phpunit.
DRUSH_VERSION="^9"
PHPUNIT_VERSION="^7"
DRUPAL_9=false;
# @TODO: Find a better way to figure out what Drupal version we are installing.
if [[ "$DRUPAL" =~ "9".* || "$DRUPAL" == "^9" ]]; then
  echo "Installing ${DRUPAL}..."
  DRUSH_VERSION="^10"
  PHPUNIT_VERSION="^9"
  DRUPAL_9=true
fi

echo "Building using Acquia Content Hub '${ACH_BRANCH}' on Drupal '${DRUPAL}' from '${BUILD}' repository."
echo "---------------------------------------------------"
echo "You can provide a Content Hub branch as an argument (8.x-2.x):"
echo "By default, it will build Acquia Content Hub using Drupal public repository."
echo "To build from Acquia's private repository, use:"
echo ""
echo "    $./bin/chf build_code private LCH-XXXX"
echo "---------------------------------------------------"
if [ -d "$DOCROOT" ]; then
  echo "Cleaning up existing directory $DOCROOT"
  chmod -R 777 $DOCROOT
  rm -Rf $DOCROOT
fi

echo "Creating directory $DOCROOT"
mkdir $DOCROOT
echo "Done."
echo "Creating Drupal project in folder '${DOCROOT}'..."
COMPOSER_MEMORY_LIMIT=-1 composer create-project drupal/recommended-project:${DRUPAL} ${DOCROOT} --no-interaction
echo "Done."
echo "Building Drupal contrib modules..."
cd $DOCROOT || exit

# DO NOT MODIFY THIS LIST OF PACKAGES.
COMPOSER_MEMORY_LIMIT=-1 composer require drush/drush:${DRUSH_VERSION} \
  phpunit/phpunit:${PHPUNIT_VERSION} \
  mikey179/vfsStream \
  drupal/environment_indicator \
  drupal/admin_toolbar \
  drupal/coder \
  squizlabs/php_codesniffer
COMPOSER_MEMORY_LIMIT=-1 composer require --dev phpcompatibility/php-compatibility

if ${DRUPAL_9} ; then
  COMPOSER_MEMORY_LIMIT=-1 composer require symfony/phpunit-bridge
  COMPOSER_MEMORY_LIMIT=-1 composer require --dev phpspec/prophecy-phpunit:^2
else
  COMPOSER_MEMORY_LIMIT=-1 composer require symfony/phpunit-bridge^3.4.3
fi

# Install devel module.
COMPOSER_MEMORY_LIMIT=-1 composer require drupal/devel \
  drupal/devel_php

# You can modify the list of packages defined in this block.
# -------------------------------------------------------------
COMPOSER_MEMORY_LIMIT=-1 composer require drupal/entity_browser \
  drupal/features \
  drupal/paragraphs \
  drupal/view_mode_selector
# -------------------------------------------------------------
echo "Done."
echo "Building Acquia Content Hub from branch '${ACH_BRANCH}'"

# Composer for Drupal 9 now requires minimum-stability "stable".
# So we cannot install dev packages anymore:
# https://www.drupal.org/project/user_guide/issues/3022675
if ${DRUPAL_9} ; then
  # Change composer to allow minimum-stability: dev:
  sed -i'.min-stability.original' -e 's/"minimum-stability": "stable"/"minimum-stability": "dev"/g' composer.json
fi

# Installing Acquia Content Hub.
if [ $BUILD != 'public' ] ; then
  echo "Using private repository."
  COMPOSER_MEMORY_LIMIT=-1 composer config repositories.acquia_contenthub '{"type":"vcs","url":"git@github.com:acquia/acquia_contenthub.git","no-api":true}'
  # Removing "require-dev: []". Why is it an array??? Possible composer bug.
  # TODO: Figure out why this is messed up when it reaches this line.
  sed -i'.original' -e '/"require-dev": \[\]/d' composer.json
  COMPOSER_MEMORY_LIMIT=-1 composer require drupal/acquia_contenthub:dev-${ACH_BRANCH}
else
  echo "Using public repository."
  COMPOSER_MEMORY_LIMIT=-1 composer require drupal/acquia_contenthub:${ACH_BRANCH}
fi
COMPOSER_MEMORY_LIMIT=-1 composer install
chmod -R 777 web/sites

# Configure Coding Standards
./vendor/bin/phpcs --config-set installed_paths vendor/drupal/coder/coder_sniffer,vendor/phpcompatibility/php-compatibility
#./vendor/bin/phpcs -n --standard=Drupal,DrupalPractice web/modules/contrib/acquia_contenthub/src web/modules/contrib/acquia_contenthub/tests
echo "Done."
