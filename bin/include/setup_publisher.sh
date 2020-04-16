#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETUP_FILE="${SCRIPT_DIRECTORY}/setup_options.sh"

# Setting up initial definitions.
COUNT=$1
CONFIG_PUB_BINDING_PORT[${COUNT}]=$((8080+${COUNT}))
IP=$((10+${COUNT}))
CONFIG_PUB_IP_ADDRESS[${COUNT}]="192.168.1.${IP}"

# Publisher Questionaire Setup.
echo "Publisher${COUNT} Configuration."
while : ; do
  echo "Insert your Hostname (publisher${COUNT}.ngrok.io):"
  echo "This same hostname will be used as your ngrok domain."
  read CONFIG_PUB_HOSTNAME[$COUNT]
  echo "Insert your Acquia Content Client Name:"
  read CONFIG_PUB_ACH_CLIENT_NAME[$COUNT]
  echo "The following are PHP Debugging environment variables."
  echo "PHP_IDE_CONFIG:"
  read CONFIG_PUB_PHP_IDE_CONFIG[$COUNT]
  echo "XDEBUG_CONFIG:"
  read CONFIG_PUB_XDEBUG_CONFIG[$COUNT]
  echo "PHP_INI_XDEBUG_REMOTE_PORT:"
  read CONFIG_PUB_PHP_INI_XDEBUG_REMOTE_PORT[$COUNT]

  # Asking for verification.
  echo "Are the following values correct:"
  echo "  - Publisher$COUNT Hostname: ${CONFIG_PUB_HOSTNAME[$COUNT]}"
  echo "  - Acquia Content Client Name: ${CONFIG_PUB_ACH_CLIENT_NAME[$COUNT]}"
  echo "  - PHP_IDE_CONFIG: ${CONFIG_PUB_PHP_IDE_CONFIG[$COUNT]}"
  echo "  - XDEBUG_CONFIG: ${CONFIG_PUB_XDEBUG_CONFIG[$COUNT]}"
  echo "  - PHP_INI_XDEBUG_REMOTE_PORT: ${CONFIG_PUB_PHP_INI_XDEBUG_REMOTE_PORT[$COUNT]}"
  read -p "(y/n)? " line
    [[ ! $line =~ ^[Yy]$ ]] || break
done

echo "Saving Publisher$COUNT configuration..."
echo "# Publisher$COUNT." >> ${SETUP_FILE}
echo "CONFIG_PUB_HOSTNAME[${COUNT}]=\"${CONFIG_PUB_HOSTNAME[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_PUB_ACH_CLIENT_NAME[${COUNT}]=\"${CONFIG_PUB_ACH_CLIENT_NAME[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_PUB_PHP_IDE_CONFIG[${COUNT}]=\"${CONFIG_PUB_PHP_IDE_CONFIG[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_PUB_XDEBUG_CONFIG[${COUNT}]=\"${CONFIG_PUB_XDEBUG_CONFIG[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_PUB_PHP_INI_XDEBUG_REMOTE_PORT[${COUNT}]=\"${CONFIG_PUB_PHP_INI_XDEBUG_REMOTE_PORT[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_PUB_BINDING_PORT[${COUNT}]=\"${CONFIG_PUB_BINDING_PORT[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_PUB_IP_ADDRESS[${COUNT}]=\"${CONFIG_PUB_IP_ADDRESS[${COUNT}]}\";" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
