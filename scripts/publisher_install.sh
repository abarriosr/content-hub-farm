#!/bin/bash

DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"

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

# -------------------------------------------------------------
# Enable additional contrib/custom modules for publishers.
echo "Enabling additional contributed modules for publishers..."
$DRUSH pm-enable -y features
echo "Done."
# -------------------------------------------------------------

# Enable Content Hub modules.
echo "Enabling Acquia Content Hub modules for publishers..."
# If version is empty then we are on CH 1.x, otherwise CH 2.x:
VERSION=`$DRUSH pml |grep acquia_contenthub_publisher`
if [ -z "$VERSION" ]; then
  # CH 1.x
  echo " --> On Content Hub 1.x..."
  $DRUSH pm-enable -y acquia_contenthub
else
  # CH 2.x
  echo " --> On Content Hub 2.x..."
  $DRUSH pm-enable -y acquia_contenthub \
  acquia_contenthub_publisher \
  acquia_contenthub_curation
fi
echo "Done."

# Adding additional configuration to settings.php.
SETTINGS_PHP=/var/www/html/${DOCROOT}/sites/${HOSTNAME}/settings.php
echo "Adding additional publisher configuration to settings.php ..."
chmod u+w ${SETTINGS_PHP}
echo "
//********************** Custom Settings ***************************
\$config['environment_indicator.indicator']['bg_color'] = '#008117';
\$config['environment_indicator.indicator']['fg_color'] = '#DDDDDD';
\$config['environment_indicator.indicator']['name'] = 'Publisher';
" >> ${SETTINGS_PHP}
chmod u-w ${SETTINGS_PHP}
echo "Done."
