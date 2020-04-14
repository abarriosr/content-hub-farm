#!/bin/bash

# Opens a browser to the Site URL in the container.
CONTAINER=$1

# Obtaining the Site domain.
DOMAIN=`docker exec -t $CONTAINER cat /etc/hostname`
URL="http://${DOMAIN//[$'\t\r\n']}"
open "$URL"