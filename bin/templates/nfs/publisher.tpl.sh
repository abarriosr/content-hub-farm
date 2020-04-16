#!/bin/bash

# Loading Setup Configuration.
./setup_options.sh

cat  << EOF

  publisher$COUNT:
    hostname: ${CONF_PUBLISHER_HOSTNAME[$COUNT]}
    build:
      context: .
    depends_on:
      - database
    environment:
      - SITE_ROLE=publisher
      - PERSISTENT=true
      - ACH_CLIENT_NAME=publisher$COUNT-docker
      - PHP_IDE_CONFIG=${CONF_PUBLISHER_PHP_IDE_CONFIG[$COUNT]}
      - XDEBUG_CONFIG=${CONF_PUBLISHER_XDEBUG_CONFIG[$COUNT]}
      - PHP_INI_XDEBUG_REMOTE_PORT=${CONF_PHP_INI_XDEBUG_REMOTE_PORT[$COUNT]}
    volumes:
      - type: volume
        source: nfsmount
        target: /var/www/html
        volume:
          nocopy: true
    ports:
      - 8081:80
    networks:
      ch_farm:
        ipv4_address: 192.168.1.10
EOF