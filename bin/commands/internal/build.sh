#!/bin/bash

# Build or rebuild services.
echo "Build or rebuild services..."
docker-compose build $args
