#!/bin/bash

# Disable Xdebug...
rm -f /etc/php7/conf.d/00_xdebug.ini
supervisorctl restart php-fpm