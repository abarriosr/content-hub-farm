#!/bin/bash

# Loading Setup Configuration.
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPT_DIRECTORY/../../../setup_options.sh

MYSQL_ROOT_PASSWORD=`openssl rand -base64 12`
cat  << EOF
version: "3.6"

services:

  database:
    hostname: database.docker
    build:
      context: ./database
    command: mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --max_allowed_packet=64MB
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
      ACH_API_KEY: $CONFIG_ACH_API_KEY
      ACH_SECRET_KEY: $CONFIG_ACH_SECRET_KEY
      ACH_HOSTNAME: $CONFIG_ACH_HOSTNAME
    volumes:
      - db_data:/var/lib/mysql
      - ./database/initdb.d:/docker-entrypoint-initdb.d
    ports:
      - ${CONFIG_MYSQL_LOCAL_PORT}:3306
    networks:
      ch_farm:
        ipv4_address: 192.168.1.100
EOF