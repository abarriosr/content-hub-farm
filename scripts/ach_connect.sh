#!/bin/bash

# Connects this site to Acquia Content Hub.
DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"

# Obtain Plexus Credentials from Database Server.
DB_USER='db';
DB_PASS='db';
DB_HOST='database';
ACH_CREDENTIALS=`mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} -s -N -e 'SELECT CONCAT_WS("|",api_key, secret_key, hostname) FROM plexus.credentials;'`
DB_API_KEY=`echo ${ACH_CREDENTIALS} | awk -F'|' '{print $1}'`
DB_SECRET_KEY=`echo ${ACH_CREDENTIALS} | awk -F'|' '{print $2}'`
DB_HOSTNAME=`echo ${ACH_CREDENTIALS} | awk -F'|' '{print $3}'`

# If there are credentials set for this site use them, otherwise use the global ones from the Database Server.
# Local set values override database values.
API_KEY="${ACH_API_KEY:-${DB_API_KEY}}"
SECRET_KEY="${ACH_SECRET_KEY:-${DB_SECRET_KEY}}"
HOSTNAME="${ACH_HOSTNAME:-${DB_HOSTNAME}}"
ACH_ORIGIN="${ACH_ORIGIN:-""}"

# If version is empty then we are on CH 1.x, otherwise CH 2.x:
VERSION=`$DRUSH pml |grep acquia_contenthub_publisher`
if [ -z "$VERSION" ]; then
  # CH 1.x
  echo "Configuring Content Hub 1.x:"
  SECRET_VAR="secret"
else
  # CH 2.x
  echo "Configuring Content Hub 2.x:"
  SECRET_VAR="secret_key"
fi

# If the ORIGIN is defined then we do not want to register again, just adjust the settings with provided origin.
if [ -z "$ACH_ORIGIN" ]; then
  echo "Registering site to Content Hub using following credentials:"
  echo "API_KEY=$API_KEY, SECRET_KEY=$SECRET_KEY, HOSTNAME=$HOSTNAME, CLIENT_NAME=$ACH_CLIENT_NAME."
  $DRUSH ach-connect --hostname=$HOSTNAME --api_key=$API_KEY --$SECRET_VAR=$SECRET_KEY --client_name=$ACH_CLIENT_NAME -y
  echo "Done."
else
  echo "Using existing client origin to connect to Content Hub:"
  echo "API_KEY=$API_KEY, SECRET_KEY=$SECRET_KEY, HOSTNAME=$HOSTNAME, CLIENT_NAME=$ACH_CLIENT_NAME ORIGIN=$ACH_ORIGIN."
  $DRUSH cset acquia_contenthub.admin_settings hostname $HOSTNAME -y
  $DRUSH cset acquia_contenthub.admin_settings api_key $API_KEY -y
  $DRUSH cset acquia_contenthub.admin_settings secret_key $SECRET_KEY -y
  $DRUSH cset acquia_contenthub.admin_settings client_name $ACH_CLIENT_NAME -y
  $DRUSH cset acquia_contenthub.admin_settings origin $ACH_ORIGIN -y
  $DRUSH acquia:contenthub-webhooks register
  echo "Done."
fi
