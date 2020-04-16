#!/bin/bash

MYSQL_ROOT_PASSWORD=`openssl rand -base64 12`

# Loading Setup Configuration.
./setup_options.sh

cat  << EOF
version: "3.6"

services:

  database:
    hostname: database.docker
    build:
      context: ./database
    command: mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
      ACH_API_KEY: $CONF_ACH_API_KEY
      ACH_SECRET_KEY: $CONF_ACH_SECRET_KEY
      ACH_HOSTNAME: $CONF_ACH_HOSTNAME
    volumes:
      - db_data:/var/lib/mysql
      - ./database/initdb.d:/docker-entrypoint-initdb.d
    networks:
      ch_farm:
        ipv4_address: 192.168.1.100
EOF