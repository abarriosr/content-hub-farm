#!/bin/bash

DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"
# Enable additional contrib modules for subscribers.
# echo "Enabling additional contributed modules for subscribers..."
# $DRUSH pm-enable -y features
# echo "Done."

# Enable Content Hub modules.
echo "Enabling Acquia Content Hub modules for subscribers..."
$DRUSH pm-enable -y acquia_contenthub \
  acquia_contenthub_subscriber
echo "Done."

# Configure API/Secret Keys.
#  ../vendor/drush/drush/drush -y acquia:contenthub-connect-site --api_key=aaa --secret=aaa --hostname=http://172.28.1.1:5000 --client_name=docker-subscriber

