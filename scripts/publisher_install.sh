#!/bin/bash

DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"

# -------------------------------------------------------------
# Enable additional contrib/custom modules for publishers.
echo "Enabling additional contributed modules for publishers..."
$DRUSH pm-enable -y features
echo "Done."
# -------------------------------------------------------------

# Enable Content Hub modules.
echo "Enabling Acquia Content Hub modules for publishers..."
$DRUSH pm-enable -y acquia_contenthub \
  acquia_contenthub_publisher \
  acquia_contenthub_curation
echo "Done."

# Adding additional configuration to settings.php.
echo "Adding additional publisher configuration to settings.php ..."
chmod u+w /var/www/html/web/sites/${HOSTNAME}/settings.php
echo "
//********************** Custom Settings ***************************
\$config['environment_indicator.indicator']['bg_color'] = '#008117';
\$config['environment_indicator.indicator']['fg_color'] = '#DDDDDD';
\$config['environment_indicator.indicator']['name'] = 'Publisher';
" >> /var/www/html/web/sites/${HOSTNAME}/settings.php
chmod u-w /var/www/html/web/sites/${HOSTNAME}/settings.php
echo "Done."
