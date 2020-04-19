#!/bin/bash

# Loading Setup Configuration.
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NGROK_YML=${HOME}/.ngrok2/ngrok.yml

# Detect existing ~/.ngrok2/ngrok.yml, and if so back it up and proceed to replace it.
if [ -f $NGROK_YML ]; then
  NGROK_YML_BACK="`dirname "${NGROK_YML}"`/ngrok"
  num=`ls ${NGROK_YML_BACK}* | wc -l | xargs`
  NGROK_YML_BACK=$NGROK_YML_BACK${num}.yml
  # Backing up existent ngrok.yml.
  echo "Backing up existing ~/.ngrok2/ngrok.yml to ngrok${num}.yml"
  mv $NGROK_YML $NGROK_YML_BACK
fi

echo "" > ${NGROK_YML}
source $SCRIPT_DIRECTORY/../../setup_options.sh
echo "authtoken: $CONFIG_NGROK_TOKEN" >> ${NGROK_YML}
echo "tunnels:" >> ${NGROK_YML}

for (( COUNT=1; COUNT<=${CONFIG_NUM_PUBLISHERS}; COUNT++ ))
do
  echo "  publisher$COUNT:" >> ${NGROK_YML}
  echo "    proto: \"http\"" >> ${NGROK_YML}
  echo "    addr: \"${CONFIG_PUB_BINDING_PORT[${COUNT}]}\"" >> ${NGROK_YML}
  echo "    hostname: ${CONFIG_PUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo "    host_header: ${CONFIG_PUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo ""
done

for (( COUNT=1; COUNT<=${CONFIG_NUM_SUBSCRIBERS}; COUNT++ ))
do
  echo "  subscriber$COUNT:" >> ${NGROK_YML}
  echo "    proto: \"http\"" >> ${NGROK_YML}
  echo "    addr: \"${CONFIG_SUB_BINDING_PORT[${COUNT}]}\"" >> ${NGROK_YML}
  echo "    hostname: ${CONFIG_SUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo "    host_header: ${CONFIG_SUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo "" >> ${NGROK_YML}
done

echo "Created ~/.ngrok2/ngrok.yml file."
