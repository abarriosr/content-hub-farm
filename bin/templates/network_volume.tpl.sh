#!/bin/bash

# Loading Setup Configuration.
./setup_options.sh

cat  << EOF

networks:
  ch_farm:
    ipam:
      config:
        - subnet: 192.168.1.0/24
volumes:
  db_data:
    name: "content-hub-farm-database"
EOF