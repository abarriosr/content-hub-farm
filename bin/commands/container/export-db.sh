#!/bin/bash

# Provide help if "--help" is requested.
if [[ $2 == "--help" ]]; then
  echo ""
  echo "Exports database from <container> into a file."
  echo ""
  echo "    $./bin/chf <container> export-db /path/to/file.sql"
  echo ""
  exit
fi

# Dumps database from the container
CONTAINER=$1
FILE=$2

if [ -z "${FILE}" ] ; then
  echo ""
  echo "You need to provide an output file, Ex:"
  echo ""
  echo "   ./chf <container> export-db database.sql"
  echo ""
  exit
fi

# Executing drush sql-dump
echo "Exporting database to '${FILE}'..."
docker exec -t -w /var/www/html/web $CONTAINER /usr/local/bin/drush.sh sql-dump > $FILE
echo "Done."
