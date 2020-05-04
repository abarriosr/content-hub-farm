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
if [[ "$DRUPAL" =~ "9.0.0".* ]]; then
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
else
  echo "Creating directory $DOCROOT"
  mkdir $DOCROOT
fi
echo "Done."
echo "Creating Drupal project in folder '${DOCROOT}'..."
COMPOSER_MEMORY_LIMIT=-1 composer create-project drupal/recommended-project:${DRUPAL} ${DOCROOT} --no-interaction
echo "Done."
echo "Building Drupal contrib modules..."
cd $DOCROOT || exit

# DO NOT MODIFY THIS LIST OF PACKAGES.
COMPOSER_MEMORY_LIMIT=-1 composer require drush/drush:${DRUSH_VERSION} \
  && COMPOSER_MEMORY_LIMIT=-1 composer require phpunit/phpunit:${PHPUNIT_VERSION} \
  && COMPOSER_MEMORY_LIMIT=-1 composer require symfony/phpunit-bridge:^3.4.3 \
  && COMPOSER_MEMORY_LIMIT=-1 composer require mikey179/vfsStream \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/environment_indicator \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/admin_toolbar

if ! ${DRUPAL_9} ; then
  # Only install these packages if it is not Drupal 9.x
  COMPOSER_MEMORY_LIMIT=-1 composer require drupal/devel \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/devel_php
fi

# You can modify the list of packages defined in this block.
# -------------------------------------------------------------
COMPOSER_MEMORY_LIMIT=-1 composer require drupal/entity_browser \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/features \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/paragraphs

if ! ${DRUPAL_9} ; then
  # Only install these packages if it is not Drupal 9.x
  COMPOSER_MEMORY_LIMIT=-1 composer require drupal/view_mode_selector
fi
# -------------------------------------------------------------
echo "Done."
echo "Building Acquia Content Hub from branch '${ACH_BRANCH}'"

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
echo "Done."
