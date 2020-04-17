#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETUP_FILE="${SCRIPT_DIRECTORY}/setup_options.sh"

# Setting up initial definitions.
COUNT=$1
NUM_PUBLISHERS=$2
CONFIG_SUB_BINDING_PORT[${COUNT}]=$((8080+${NUM_PUBLISHERS}+${COUNT}))
IP=$((10+${NUM_PUBLISHERS}+${COUNT}))
CONFIG_SUB_IP_ADDRESS[${COUNT}]="192.168.1.${IP}"

# Subscriber Questionaire Setup.
echo "Subscriber${COUNT} Configuration."
while : ; do
  echo "Insert your Hostname (subscriber${COUNT}.ngrok.io):"
  echo "This same hostname will be used as your ngrok domain."
  read CONFIG_SUB_HOSTNAME[$COUNT]
  echo "Insert your Acquia Content Client Name:"
  read CONFIG_SUB_ACH_CLIENT_NAME[$COUNT]
  echo "The following are PHP Debugging environment variables."
  echo "PHP_IDE_CONFIG:"
  read CONFIG_SUB_PHP_IDE_CONFIG[$COUNT]
  echo "XDEBUG_CONFIG:"
  read CONFIG_SUB_XDEBUG_CONFIG[$COUNT]
  echo "PHP_INI_XDEBUG_REMOTE_PORT:"
  read CONFIG_SUB_PHP_INI_XDEBUG_REMOTE_PORT[$COUNT]

  # Asking for verification.
  echo "Are the following values correct:"
  echo "  - Subscriber$COUNT Hostname: ${CONFIG_SUB_HOSTNAME[$COUNT]}"
  echo "  - Acquia Content Client Name: ${CONFIG_SUB_ACH_CLIENT_NAME[$COUNT]}"
  echo "  - PHP_IDE_CONFIG: ${CONFIG_SUB_PHP_IDE_CONFIG[$COUNT]}"
  echo "  - XDEBUG_CONFIG: ${CONFIG_SUB_XDEBUG_CONFIG[$COUNT]}"
  echo "  - PHP_INI_XDEBUG_REMOTE_PORT: ${CONFIG_SUB_PHP_INI_XDEBUG_REMOTE_PORT[$COUNT]}"
  read -p "(y/n)? " line
    [[ ! $line =~ ^[Yy]$ ]] || break
done

echo "Saving Subscriber$COUNT configuration..."
echo "# Subscriber$COUNT." >> ${SETUP_FILE}
echo "CONFIG_SUB_HOSTNAME[${COUNT}]=\"${CONFIG_SUB_HOSTNAME[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_ACH_CLIENT_NAME[${COUNT}]=\"${CONFIG_SUB_ACH_CLIENT_NAME[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_PHP_IDE_CONFIG[${COUNT}]=\"${CONFIG_SUB_PHP_IDE_CONFIG[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_XDEBUG_CONFIG[${COUNT}]=\"${CONFIG_SUB_XDEBUG_CONFIG[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_PHP_INI_XDEBUG_REMOTE_PORT[${COUNT}]=\"${CONFIG_SUB_PHP_INI_XDEBUG_REMOTE_PORT[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_BINDING_PORT[${COUNT}]=\"${CONFIG_SUB_BINDING_PORT[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_IP_ADDRESS[${COUNT}]=\"${CONFIG_SUB_IP_ADDRESS[${COUNT}]}\";" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
