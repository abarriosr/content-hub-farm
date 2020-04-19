#!/bin/bash

# Loading Setup Configuration.
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPT_DIRECTORY/../../../setup_options.sh

cat  << EOF

networks:
  ch_farm:
    ipam:
      config:
        - subnet: 192.168.1.0/24

volumes:
  db_data:
    name: "content-hub-farm-database"
  nfsmount:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=host.docker.internal,hard,nolock,rw"
      device: ":/System/Volumes/Data/${CONFIG_VOLUME_DEVICE_PATH}/html"
EOF