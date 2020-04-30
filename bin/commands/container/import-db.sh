#!/bin/bash

# Provide help if "--help" is requested.
if [[ $2 == "--help" || -z "$2" ]]; then
  echo ""
  echo "Imports a database file into the site's database in <container>."
  echo "Supports the following extensions: sql, tar.gz, gz, zip:"
  echo ""
  echo "    $./bin/chf <container> import-db /path/to/file.(sql|tar.gz|gz|zip)"
  echo ""
  exit
fi

CONTAINER=$1
FILE=$2

if [ ! -f "${FILE}" ] ; then
  echo ""
  echo "The file '${FILE}' does not exist."
  echo ""
  exit
fi

# Process file according to its extension.
TARGET_FILE=$(md5 -q "${FILE}")

case "${FILE}" in
  *.tar.gz | *.tgz )
      # If it's a tarball.
      TARGET_FILE="/tmp/${TARGET_FILE}.tar.gz"
      ;;
  *.gz )
      # If it's gzipped.
      TARGET_FILE="/tmp/${TARGET_FILE}.gz"
      ;;
  *.zip )
      # If it's zipped.
      TARGET_FILE="/tmp/${TARGET_FILE}.zip"
      ;;
  *.sql )
      # it's a normal sql.
      TARGET_FILE="/tmp/${TARGET_FILE}.sql"
      ;;
  *)
      # File cannot be handled.
      echo ""
      echo "The file '${FILE}' cannot be imported. Is it a database file?"
      echo "Supported extensions: sql, gz, tar.gz, tgz, zip."
      echo ""
      exit
      ;;
esac


# Executing database import.
echo ""
echo "Importing database file ${FILE} into container '${CONTAINER}'"
docker cp ${FILE} ${CONTAINER}:${TARGET_FILE}
docker exec -it ${CONTAINER} import-db.sh ${TARGET_FILE} --delete
