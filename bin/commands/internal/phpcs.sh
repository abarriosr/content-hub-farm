#!/bin/bash

# Finding the DOCROOT...
# @TODO: Find a better way to find out the docroot.
if [ -d "html/docroot" ]
then
    echo "Using directory 'docroot' as the DOCROOT..."
    DOCROOT='docroot';
else
    echo "Using directory 'web' as the DOCROOT..."
    DOCROOT='web';
fi

# Runs phpcs on the acquia_contenthub module.
echo "Checking Coding Standards for 'acquia_contenthub' module..."
cd html
./vendor/bin/phpcs -n --standard=Drupal ${DOCROOT}/modules/contrib/acquia_contenthub/src
