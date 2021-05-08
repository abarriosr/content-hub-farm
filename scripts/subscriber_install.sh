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
# Enable additional contrib/custom modules for subscribers.
echo "Enabling additional contributed modules for subscribers..."
$DRUSH pm-enable -y features
echo "Done."
# -------------------------------------------------------------

# Enable Content Hub modules.
echo "Enabling Acquia Content Hub modules for subscribers..."
$DRUSH pm-enable -y acquia_contenthub \
  acquia_contenthub_subscriber
echo "Done."

# Adding additional configuration to settings.php.
SETTINGS_PHP=/var/www/html/${DOCROOT}/sites/${HOSTNAME}/settings.php
echo "Adding additional subscriber configuration to settings.php ..."
chmod u+w ${SETTINGS_PHP}
echo "
//********************** Custom Settings ***************************
\$config['environment_indicator.indicator']['bg_color'] = '#FFFA49';
\$config['environment_indicator.indicator']['fg_color'] = '#565656';
\$config['environment_indicator.indicator']['name'] = 'Subscriber';
" >> ${SETTINGS_PHP}
chmod u-w ${SETTINGS_PHP}
echo "Done."

