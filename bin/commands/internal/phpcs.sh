#!/bin/bash

# Runs phpcs on the acquia_contenthub module.
echo "Checking Coding Standards for 'acquia_contenthub' module..."
cd html
./vendor/bin/phpcs -n --standard=Drupal web/modules/contrib/acquia_contenthub/src
