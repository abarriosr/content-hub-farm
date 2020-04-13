#!/bin/bash

# Pause services.
echo "Pausing services..."
docker-compose pause $args
