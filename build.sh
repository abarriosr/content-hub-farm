#!/bin/bash

DOCROOT=html

# If provided a branch name, use it, otherwise use default 8.x-2.x
ACH_BRANCH=$1
if [ -z "$1" ]; then
  ACH_BRANCH=8.x-2.x
fi

echo "---------------------------------------------------"
echo "You can provide a Content Hub branch as an argument (8.x-2.x):"
echo "$./build.sh LCH-XXXX"
echo "---------------------------------------------------"
echo "Cleaning up existing directory $DOCROOT"
chmod -R 777 $DOCROOT
rm -Rf $DOCROOT
mkdir $DOCROOT
echo "Done."
echo "Downloading Drupal..."
COMPOSER_MEMORY_LIMIT=-1 composer create-project drupal/recommended-project $DOCROOT --no-interaction
echo "Done."
echo "Building Drupal contrib modules..."
cd $DOCROOT
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
echo "Building Content Hub Module using branch ${ACH_BRANCH}"
COMPOSER_MEMORY_LIMIT=-1 composer config repositories.acquia_contenthub '{"type":"vcs","url":"git@github.com:acquia/acquia_contenthub.git","no-api":true}'
COMPOSER_MEMORY_LIMIT=-1 composer require drupal/acquia_contenthub:dev-${ACH_BRANCH}
COMPOSER_MEMORY_LIMIT=-1 composer install
echo "Done."
echo "Building Docker containers."
docker-compose build
echo "Done."