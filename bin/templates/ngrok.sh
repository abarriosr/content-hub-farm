#!/bin/bash

# Loading Setup Configuration.
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPT_DIRECTORY/../include/setup_options.sh
echo "authtoken: $CONFIG_NGROK_TOKEN"
echo "tunnels:"

for (( i=1; i<=${CONFIG_NUM_PUBLISHERS}; i++ ))
do
  echo "  publisher$i:"
  echo "    proto: \"http\""
  echo "    addr: \"${CONFIG_PUB_BINDING_PORT[${COUNT}]}\""
  echo "    hostname: ${CONFIG_PUB_HOSTNAME[${COUNT}]}"
  echo "    host_header: ${CONFIG_PUB_HOSTNAME[${COUNT}]}"
  echo ""
done

for (( i=1; i<=${CONFIG_NUM_SUBSCRIBERS}; i++ ))
do
  echo "  subscriber$i:"
  echo "    proto: \"http\""
  echo "    addr: \"${CONFIG_SUB_BINDING_PORT[${COUNT}]}\""
  echo "    hostname: ${CONFIG_SUB_HOSTNAME[${COUNT}]}"
  echo "    host_header: ${CONFIG_SUB_HOSTNAME[${COUNT}]}"
  echo ""
done

