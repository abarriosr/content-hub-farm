#!/bin/bash

# Restart services.
echo "Restarting services..."
docker-compose restart $args
