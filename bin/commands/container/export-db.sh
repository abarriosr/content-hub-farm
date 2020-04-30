#!/bin/bash

# Provide help if "--help" is requested.
if [[ $2 == "--help" ]]; then
  echo ""
  echo "Exports database from <container> into a file."
  echo ""
  echo "    $./bin/chf <container> export-db /path/to/file       ; Produces: /path/to/file.sql.gz"
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

TARGET_FILE=${FILE}
case "${FILE}" in
  *.sql.gz )
      # If it's gzipped.
      export_cmd() {
        docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | gzip > ${TARGET_FILE}
      }
      ;;
  *.gz )
      # If it's gzipped.
      TARGET_FILE="${FILE%.*}.sql.gz"
      export_cmd() {
        docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | gzip > ${TARGET_FILE}
      }
      ;;
  *.sql )
      # it's a normal sql.
      export_cmd() {
        docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump > ${TARGET_FILE}
      }
      ;;
  *)
      # If it's a random name.
      TARGET_FILE="${FILE}.sql.gz"
      export_cmd() {
        docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | gzip > ${TARGET_FILE}
      }
      ;;
esac

# Executing drush sql-dump
echo "Exporting database to '${TARGET_FILE}'..."
export_cmd
echo "Done."
