#!/bin/bash

# Loading Setup Configuration.
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NGROK_YML=${SCRIPT_DIRECTORY}/../../ngrok.yml

# @TODO: Detect existent ~/.ngrok2/ngrok.yml, print it... back it up and proceed to replace it.
echo "" > ${NGROK_YML}

source $SCRIPT_DIRECTORY/../include/setup_options.sh
echo "authtoken: $CONFIG_NGROK_TOKEN" >> ${NGROK_YML}
echo "tunnels:" >> ${NGROK_YML}

for (( i=1; i<=${CONFIG_NUM_PUBLISHERS}; i++ ))
do
  echo "  publisher$i:" >> ${NGROK_YML}
  echo "    proto: \"http\"" >> ${NGROK_YML}
  echo "    addr: \"${CONFIG_PUB_BINDING_PORT[${COUNT}]}\"" >> ${NGROK_YML}
  echo "    hostname: ${CONFIG_PUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo "    host_header: ${CONFIG_PUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo ""
done

for (( i=1; i<=${CONFIG_NUM_SUBSCRIBERS}; i++ ))
do
  echo "  subscriber$i:" >> ${NGROK_YML}
  echo "    proto: \"http\"" >> ${NGROK_YML}
  echo "    addr: \"${CONFIG_SUB_BINDING_PORT[${COUNT}]}\"" >> ${NGROK_YML}
  echo "    hostname: ${CONFIG_SUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo "    host_header: ${CONFIG_SUB_HOSTNAME[${COUNT}]}" >> ${NGROK_YML}
  echo "" >> ${NGROK_YML}
done

echo "Created ~/.ngrok2/ngrok.yml file."
