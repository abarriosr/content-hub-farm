#!/bin/bash

# Project Document Root Folder.
DOCROOT=html

# By default use 'public' repository.
BUILD="${2:-'public'}"
if [[ ! (-z "$2") && $BUILD != 'public' ]] ; then
  BUILD='private'
fi

# If provided a branch name, use it, otherwise use default 8.x-2.x
ACH_BRANCH=$1
if [ -z "$1" ]; then
  if [ $BUILD != 'public' ] ; then
    ACH_BRANCH=~2
  else
    ACH_BRANCH=8.x-2.x
  fi
fi

echo "Building using Acquia Content Hub '${ACH_BRANCH}' from '${BUILD}' repository."
echo "---------------------------------------------------"
echo "You can provide a Content Hub branch as an argument (8.x-2.x):"
echo "By default, it will build Acquia Content Hub using Drupal public repository."
echo "To build from Acquia's private repository, use:"
echo ""
echo "    $./bin/chf build_code LCH-XXXX private"
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
COMPOSER_MEMORY_LIMIT=-1 composer create-project drupal/recommended-project $DOCROOT --no-interaction
echo "Done."
echo "Building Drupal contrib modules..."
cd $DOCROOT || exit
# DO NOT MODIFY THIS LIST OF PACKAGES.
COMPOSER_MEMORY_LIMIT=-1 composer require drush/drush:^9 \
  && COMPOSER_MEMORY_LIMIT=-1 composer require phpunit/phpunit \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/devel \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/devel_php \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/environment_indicator \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/admin_toolbar

# You can modify the list of packages defined in this block.
# -------------------------------------------------------------
COMPOSER_MEMORY_LIMIT=-1 composer require drupal/entity_browser \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/features \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/view_mode_selector \
  && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/paragraphs
# -------------------------------------------------------------
echo "Done."
echo "Building Acquia Content Hub from branch '${ACH_BRANCH}'"
if [ $BUILD != 'public' ] ; then
  echo "Using public repository."
  COMPOSER_MEMORY_LIMIT=-1 composer require drupal/acquia_contenthub:${ACH_BRANCH}
else
  echo "Using private repository."
  COMPOSER_MEMORY_LIMIT=-1 composer config repositories.acquia_contenthub '{"type":"vcs","url":"git@github.com:acquia/acquia_contenthub.git","no-api":true}'
  COMPOSER_MEMORY_LIMIT=-1 composer require drupal/acquia_contenthub:dev-${ACH_BRANCH}
fi
COMPOSER_MEMORY_LIMIT=-1 composer install
echo "Done."
echo "Building Docker containers."
docker-compose build
echo "Done."