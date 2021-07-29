#!/bin/bash

# Default Site parameters.
profile="${DRUPAL_PROFILE:-'standard'}"
site_admin="admin"
site_password="admin"
site_mail="test@test.com"

# Database credentials
DB_USER='db';
DB_PASS='db';
DB_HOST='database';
DB_NAME=`echo ${HOSTNAME//[-._]} | awk -F'.' '{print $1}'`

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

# Use the hostname as database name. Create it if it does not exist yet.
mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} -s -N -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
DB_URL="mysql://${DB_USER}:${DB_PASS}@${DB_HOST}:3306/${DB_NAME}"

# If the site is not persistent then delete it and start over.
if [ ${PERSISTENT} = false ]; then
  chmod -R 777 /var/www/html/${DOCROOT}/sites/${HOSTNAME}
  rm -Rf /var/www/html/${DOCROOT}/sites/${HOSTNAME}
fi

# Verifying if site is installed.
FILE=/var/www/html/${DOCROOT}/sites/${HOSTNAME}/settings.php
echo "Checking file: ${FILE}"
if [ -f "$FILE" ]; then
  echo "Site ${HOSTNAME} is already installed."
else
  echo "Installing Drupal for site ${HOSTNAME}."
  mkdir /var/www/html/${DOCROOT}/sites/${HOSTNAME}
  chmod -R 777 /var/www/html/${DOCROOT}/sites/${HOSTNAME}

  cd /var/www/html/${DOCROOT} || return;
  mkdir -p ./sites/${HOSTNAME}/files
  cp /var/www/html/${DOCROOT}/sites/default/default.settings.php ./sites/${HOSTNAME}/settings.php
  chmod 777 ./sites/${HOSTNAME}/settings.php

  # Site installation.
  if [ "${DATABASE_BACKUP}" ]; then
    # If we are provided a backup then install the minimal profile as we will override with db backup.
    profile='minimal'
  fi
  ../vendor/drush/drush/drush si -y $profile install_configure_form.enable_update_status_emails=NULL -y --account-name=${site_admin} --account-pass=${site_password} --account-mail=${site_mail} --site-mail=${site_mail} --site-name=${HOSTNAME} --sites-subdir=${HOSTNAME} --db-url=${DB_URL}
  DRUSH="/var/www/html/vendor/bin/drush -l ${HOSTNAME}"
  echo "Done."

  # Enabling PHPUnit XML.
  PHPUNIT_XML="/var/www/html/${DOCROOT}/core/phpunit-${DB_NAME}.xml"
  echo "Configuring PHPUnit: ${PHPUNIT_XML}..."
  cp /var/www/html/${DOCROOT}/core/phpunit.xml.dist $PHPUNIT_XML
  DB_URL="mysql:\/\/${DB_USER}:${DB_PASS}@${DB_HOST}:3306\/${DB_NAME}"
  sed -i "s/<env name=\"SIMPLETEST_BASE_URL\" value=\"\"/<env name=\"SIMPLETEST_BASE_URL\" value=\"http:\/\/${HOSTNAME}\"/g" $PHPUNIT_XML
  sed -i "s/<env name=\"SIMPLETEST_DB\" value=\"\"/<env name=\"SIMPLETEST_DB\" value=\"${DB_URL}\"/g" $PHPUNIT_XML
  echo "Done."

  # If we are not provided with a database backup then proceed normal installation.
  if [ -z "${DATABASE_BACKUP}" ]; then
    # Enable common contrib/custom modules.
    # ----------------------------------------------
    echo "Enabling common contributed modules..."
    $DRUSH pm-enable -y admin_toolbar \
      admin_toolbar_tools \
      devel \
      environment_indicator
    $DRUSH pm-enable -y  simpletest
    echo "Done."
    # ----------------------------------------------

    # Customize site according to site role.
    case ${SITE_ROLE} in
    'publisher')
      /usr/local/bin/publisher_install.sh
      ;;
    'subscriber')
      /usr/local/bin/subscriber_install.sh
      ;;
    esac

    # Run any related updates and share status
    # echo "Running database updates..."
    # $DRUSH updatedb
    # $DRUSH updatedb-status
    # echo "Done."


    # Disable aggregation and rebuild cache (helps with non-port/hostname alignment issues)
    echo "Setting up variables."
    $DRUSH -y config-set system.performance js.preprocess 0
    $DRUSH -y config-set system.performance css.preprocess 0
  else
    echo "Importing database backup: '${DATABASE_BACKUP}'..."
    import-db.sh /var/www/backups/${DATABASE_BACKUP}

    # Delete existing configuration.
    $DRUSH config:delete acquia_contenthub.admin_settings -y
  fi

  # Assign write permissions to the site directory.
  chmod -R 777 /var/www/html/${DOCROOT}/sites/${HOSTNAME}/files

  # Connect to Acquia Content Hub.
  /usr/local/bin/ach_connect.sh

  $DRUSH cr
  echo "Done."
fi
