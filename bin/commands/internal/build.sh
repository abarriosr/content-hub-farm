#!/bin/bash

echo "Stopping running services..."
docker-compose down
echo "Done."
# Build or rebuild services.
echo "Build or rebuild services..."
docker-compose build $args
