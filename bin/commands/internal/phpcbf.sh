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
echo "Fixing Coding Standards for 'acquia_contenthub' module..."
cd html
./vendor/bin/phpcbf --standard=Drupal ${DOCROOT}/modules/contrib/acquia_contenthub/src ${DOCROOT}/modules/contrib/acquia_contenthub/tests
