#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETUP_FILE="${SCRIPT_DIRECTORY}/setup_options.sh"

# Content Hub Questionaire Setup.
echo "Content Hub Credentials"
while : ; do
  read -p "Insert your Acquia Content Hub API Key: " CONFIG_ACH_API_KEY
  read -p "Insert your Acquia Content Hub Secret Key: " CONFIG_ACH_SECRET_KEY
  read -p "Insert your Acquia Content Hub Hostname: " CONFIG_ACH_HOSTNAME
  echo "Are the following values correct:"
  echo "  - Content Hub API Key = ${CONFIG_ACH_API_KEY}"
  echo "  - Content Hub Secret Key = ${CONFIG_ACH_SECRET_KEY}"
  echo "  - Content Hub Hostname = ${CONFIG_ACH_HOSTNAME}"
  read -p "(y/n)? " line
    [[ ! $line =~ ^[Yy]$ ]] || break
done

echo "Saving Content Hub Credentials."
echo "# Content Hub Credentials." >> ${SETUP_FILE}
echo "CONFIG_ACH_API_KEY=\"${CONFIG_ACH_API_KEY}\";" >> ${SETUP_FILE}
echo "CONFIG_ACH_SECRET_KEY=\"${CONFIG_ACH_SECRET_KEY}\";" >> ${SETUP_FILE}
echo "CONFIG_ACH_HOSTNAME=\"${CONFIG_ACH_HOSTNAME}\";" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
