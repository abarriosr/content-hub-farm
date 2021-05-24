#!/bin/bash

# Executes a phpunit test in the docker container.
CONTAINER=$1

# Finding the DOCROOT...
# @TODO: Find a better way to find out the docroot.
if [ -d "html/docroot" ]
then
    echo "Using directory 'docroot' as the DOCROOT..."
    DOCROOT='docroot';
else
    echo "Using directory 'web' as the DOCROOT..."
    DOCROOT='web';
fi

# Eliminating first argument to pass to command script.
args=""
for i in "$@" ; do
  if [ "$i" != "$1" ]; then
    # Removing "html/${DOCROOT}/" from the arguments.
    i=${i//html\/${DOCROOT}\//}
    args="${args} $i"
  fi
done
# Executing phpunit test.
docker exec -t -w /var/www/html/${DOCROOT} $CONTAINER /usr/local/bin/phpunit.sh $args
