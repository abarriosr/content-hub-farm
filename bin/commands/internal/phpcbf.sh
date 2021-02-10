#!/bin/bash

# Runs phpcs on the acquia_contenthub module.
echo "Fixing Coding Standards for 'acquia_contenthub' module..."
cd html
./vendor/bin/phpcbf --standard=Drupal,DrupalPractice web/modules/contrib/acquia_contenthub/src web/modules/contrib/acquia_contenthub/tests
