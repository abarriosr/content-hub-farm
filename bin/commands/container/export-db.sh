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
  echo "   ./chf <container> export-db database.sql.gz"
  echo ""
  exit
fi

if ! type pv > /dev/null; then
  # Tell them to install pv
  echo ""
  echo "Install 'pv' to monitor progress of the database export process, like transfer rate and size."
  echo " \$brew install pv"
  echo ""
  PV=false
else
  PV=true
fi

TARGET_FILE=${FILE}
case "${FILE}" in
  *.sql.gz )
      # If it's gzipped.
      export_cmd() {
        if [ $PV ] ; then
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | pv | gzip > ${TARGET_FILE}
        else
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | gzip > ${TARGET_FILE}
        fi
      }
      ;;
  *.gz )
      # If it's gzipped.
      TARGET_FILE="${FILE%.*}.sql.gz"
      export_cmd() {
        if [ $PV ] ; then
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | pv | gzip > ${TARGET_FILE}
        else
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | gzip > ${TARGET_FILE}
        fi
      }
      ;;
  *.sql )
      # it's a normal sql.
      export_cmd() {
        if [ $PV ] ; then
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | pv > ${TARGET_FILE}
        else
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump > ${TARGET_FILE}
        fi
      }
      ;;
  *)
      # If it's a random name.
      TARGET_FILE="${FILE}.sql.gz"
      export_cmd() {
        if [ $PV ] ; then
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | pv | gzip > ${TARGET_FILE}
        else
          docker exec -t -w /var/www/html/web ${CONTAINER} /usr/local/bin/drush.sh sql-dump | gzip > ${TARGET_FILE}
        fi
      }
      ;;
esac

# Executing drush sql-dump
echo "Exporting database to '${TARGET_FILE}'..."
export_cmd
echo "Done."
