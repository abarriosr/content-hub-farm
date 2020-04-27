#!/bin/bash

# Disable Xdebug...
echo "..."
rm -f /etc/php7/conf.d/00_xdebug.ini
supervisorctl restart php-fpm 1>/dev/null
