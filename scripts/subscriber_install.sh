#!/bin/bash

DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"

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
echo "Adding additional subscriber configuration to settings.php ..."
chmod u+w /var/www/html/web/sites/${HOSTNAME}/settings.php
echo "
//********************** Custom Settings ***************************
\$config['environment_indicator.indicator']['bg_color'] = '#FFFA49';
\$config['environment_indicator.indicator']['fg_color'] = '#565656';
\$config['environment_indicator.indicator']['name'] = 'Subscriber';
" >> /var/www/html/web/sites/${HOSTNAME}/settings.php
chmod u-w /var/www/html/web/sites/${HOSTNAME}/settings.php
echo "Done."

