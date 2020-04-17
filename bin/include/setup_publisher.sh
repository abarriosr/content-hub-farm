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
  echo "Your hostname will be used as your public ngrok domain."
  read -p "Insert your Hostname (publisher${COUNT}.ngrok.io): " CONFIG_PUB_HOSTNAME[$COUNT]
  read -p "Insert your Acquia Content Client Name: " CONFIG_PUB_ACH_CLIENT_NAME[$COUNT]
  echo "The following are Environmental variables used for PHP Debugging."
  echo "If you are unsure about the values, just leave them blank and we will use default values."
  echo "You can always change them later."
  read -p "PHP_IDE_CONFIG: " CONFIG_PUB_PHP_IDE_CONFIG[$COUNT]
  read -p "XDEBUG_CONFIG: " CONFIG_PUB_XDEBUG_CONFIG[$COUNT]
  read -p "PHP_INI_XDEBUG_REMOTE_PORT: " CONFIG_PUB_PHP_INI_XDEBUG_REMOTE_PORT[$COUNT]

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
