#!/bin/bash

# Loading Setup Configuration.
./setup_options.sh

cat  << EOF

  subscriber$COUNT:
    hostname: ${CONF_SUBSCRIBER_CONFIG[$COUNT]}
    build:
      context: .
    depends_on:
      - database
    environment:
      - SITE_ROLE=subscriber
      - PERSISTENT=true
      - ACH_CLIENT_NAME=subscriber$COUNT-docker
      - PHP_IDE_CONFIG=${CONF_SUBSCRIBER_PHP_IDE_CONFIG[$COUNT]}
      - XDEBUG_CONFIG=remote_port=9000 remote_autostart=1
      - PHP_INI_XDEBUG_REMOTE_PORT=9000
    volumes:
      - type: volume
        source: nfsmount
        target: /var/www/html
        volume:
          nocopy: true
    ports:
      - 8082:80
    networks:
      ch_farm:
        ipv4_address: 192.168.1.11
EOF