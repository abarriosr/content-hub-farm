#!/bin/bash

VERSION="${1:-"7.4"}"

# Finding the DOCROOT...
# @TODO: Find a better way to find out the docroot.
if [ -d "/var/www/html/docroot" ]
then
    echo "Using directory 'docroot' as the DOCROOT..."
    DOCROOT='docroot';
else
    echo "Using directory 'web' as the DOCROOT..."
    DOCROOT='web';
fi

# Verifying PHP Compatibility for the Drupal module.
PHPCS="/var/www/html/vendor/bin/phpcs  -p /var/www/html/${DOCROOT}/modules/contrib/acquia_contenthub /var/www/html/vendor/acquia --standard=PHPCompatibility --runtime-set testVersion ${VERSION}"
echo "Executing Command: \$${PHPCS}"
echo ""
$PHPCS
