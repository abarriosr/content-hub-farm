#!/bin/bash

# Stop and remove containers, networks, images, and volumes.
echo "Stop and remove containers, networks, images, and volumes..."
docker-compose down $args
