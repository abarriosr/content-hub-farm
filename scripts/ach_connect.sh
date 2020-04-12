#!/bin/bash

# Connects this site to Acquia Content Hub.

DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"

if [-z "$ACH_ORIGIN"]; then
  echo "Using existing client origin to connect to Content Hub..."
  $DRUSH cset acquia_contenthub.admin_settings hostname $ACH_HOSTNAME -y
  $DRUSH cset acquia_contenthub.admin_settings api_key $ACH_API_KEY -y
  $DRUSH cset acquia_contenthub.admin_settings secret_key $ACH_SECRET_KEY -y
  $DRUSH cset acquia_contenthub.admin_settings client_name $ACH_ACH_CLIENT_NAME -y
  $DRUSH cset acquia_contenthub.admin_settings origin $ACH_ORIGIN -y
  $DRUSH acquia:contenthub-webhooks register
  echo "Done."
else
  echo "Registering site to Content Hub..."
  $DRUSH ach-connect --hostname=$ACH_HOSTNAME --api_key=$API_KEY --secret_key=$ACH_SECRET_KEY --client_name=$ACH_CLIENT_NAME -y
  echo "Registering webhook."
  $DRUSH acquia:contenthub-webhooks register
  echo "Done."
fi
