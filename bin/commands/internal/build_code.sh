#!/bin/bash

# Provide help if
if [ $1 == "--help" ]; then
  echo "This command builds the codebase that will be used to deploy the sites."
  echo ""
  echo "By default, it will download Acquia Content Hub using Drupal's public repository."
  echo "You can provide a Content Hub branch as an argument (8.x-2.x):"
  echo ""
  echo "    $./bin/chf build_code 8.x-2.x public"
  echo ""
  echo "To build from Acquia's private repository, use:"
  echo ""
  echo "    $./bin/chf build_code LCH-XXXX private"
  echo ""
  exit
fi

# Build Code base.
sh bin/include/build.sh @args
