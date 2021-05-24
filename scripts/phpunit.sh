#!/bin/bash

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

# Setting up variables.
DB_NAME=$(echo "${HOSTNAME//[-._]}" | awk -F'.' '{print $1}')
#PHPUNIT=/var/www/html/vendor/bin/phpunit
PHPUNIT=../vendor/bin/phpunit
#PHPUNIT_XML="/var/www/html/${DOCROOT}/core/phpunit-${DB_NAME}.xml"
PHPUNIT_XML="./core/phpunit-${DB_NAME}.xml"

# Executing PHPUnit tests.
echo "Running test from DOCROOT=\"/var/www/html/${DOCROOT}\":"
command="$PHPUNIT --color=always --stop-on-failure -c $PHPUNIT_XML $@"
echo "Executing: \$$command"
echo ""
cd /var/www/html/${DOCROOT} || return
$PHPUNIT --color=always --stop-on-failure -c $PHPUNIT_XML "$@"
