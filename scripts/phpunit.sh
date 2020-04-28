#!/bin/bash

# Setting up variables.
DB_NAME=$(echo "${HOSTNAME//[-._]}" | awk -F'.' '{print $1}')
#PHPUNIT=/var/www/html/vendor/bin/phpunit
PHPUNIT=../vendor/bin/phpunit
#PHPUNIT_XML="/var/www/html/web/core/phpunit-${DB_NAME}.xml"
PHPUNIT_XML="./core/phpunit-${DB_NAME}.xml"

# Executing PHPUnit tests.
echo "Running test from DOCROOT=\"/var/www/html/web\":"
command="$PHPUNIT --color=always --stop-on-failure -c $PHPUNIT_XML $@"
echo "Executing: \$$command"
echo ""
cd /var/www/html/web || return
$PHPUNIT --color=always --stop-on-failure -c $PHPUNIT_XML "$@"
