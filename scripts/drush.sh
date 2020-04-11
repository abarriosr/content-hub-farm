#!/bin/bash

#Wrapper around Drush.
/var/www/html/vendor/bin/drush -l ${HOSTNAME} "$@"