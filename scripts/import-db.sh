#!/bin/bash

FILE=$1

if [ ! -f "${FILE}" ] ; then
  echo ""
  echo "The file '${FILE}' does not exist."
  echo ""
  exit
fi

# Process file according to its extension.
case "${FILE}" in
  *.tar.gz | *.tgz )
        # If it's a tarball.
        import_cmd() {
          pv ${FILE} | tar -xOzf - | `drush.sh sql-connect`
        }
        ;;
  *.gz )
        # If it's gzipped.
        import_cmd() {
          pv ${FILE} | gunzip -c | `drush.sh sql-connect`
        }
        ;;
  *.zip )
        # If it's zipped.
        import_cmd() {
          pv ${FILE} | busybox unzip -p - | `drush.sh sql-connect`
        }
        ;;
  *.sql )
        # it's a normal sql.
        import_cmd() {
          pv ${FILE} | `drush.sh sql-connect`
        }
        ;;
  *)
        # File cannot be handled.
        echo ""
        echo "The file '${FILE}' cannot be imported. Is it a database file?"
        echo "Supported extensions: sql, gz, tar.gz, tgz, zip."
        echo ""
        ;;
esac

# Executing database import.
echo "Processing import..."
import_cmd
# If option to delete input file, then delete it.
if [ $2 == "--delete" ] ; then
  rm -f ${FILE}
fi
echo "Done."
