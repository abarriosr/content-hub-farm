#!/bin/bash

DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"
# Enable additional contrib modules for publishers.
# echo "Enabling additional contributed modules for publishers..."
# $DRUSH en -y features
# echo "Done."

# Enable Content Hub modules.
echo "Enabling Acquia Content Hub modules for publishers..."
$DRUSH pm-enable -y acquia_contenthub \
  acquia_contenthub_publisher \
  acquia_contenthub_curation
echo "Done."

# Configure API/Secret Keys.
#  ../vendor/drush/drush/drush -y acquia:contenthub-connect-site --api_key=aaa --secret=aaa --hostname=http://172.28.1.1:5000 --client_name=docker-publisher

