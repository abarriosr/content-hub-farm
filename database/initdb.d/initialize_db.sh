#!/bin/bash

# Initialize MySQL database.
# It has to be added to "/docker-entrypoint-initdb.d" directory inside the container via volume sharing.

file=`basename "$0"`
sql="/docker-entrypoint-initdb.d/${file}.sql"
rm -f $sql; touch $sql

# Create databases passed in the $MYSQL_DATABASES environment variable.
DATABASES=`echo $MYSQL_DATABASES | awk -F, '{for(i=1;i<=NF;i++) print $i}'`
for i in $DATABASES ; do
  echo "CREATE DATABASE IF NOT EXISTS \`$i\`;" >> $sql
done

# Create user 'db' with password 'db' with access to all databases from any host.
echo "CREATE USER IF NOT EXISTS 'db'@'%' IDENTIFIED BY 'db';" >> $sql
echo "GRANT ALL PRIVILEGES ON *.* TO 'db'@'%';" >> $sql

# Create a database 'plexus' with the plexus credentials taken from environment variables
echo "CREATE DATABASE IF NOT EXISTS \`plexus\`;" >> $sql
echo "CREATE TABLE IF NOT EXISTS \`plexus\`.\`credentials\` (
    \`api_key\` VARCHAR(100),
    \`secret_key\` VARCHAR(100),
    \`hostname\` VARCHAR(255)
);" >> $sql
echo "DELETE FROM \`plexus\`.\`credentials\`;" >> $sql
echo "INSERT INTO \`plexus\`.\`credentials\` (api_key, secret_key, hostname)
VALUES ('${ACH_API_KEY}', '${ACH_SECRET_KEY}', '${ACH_HOSTNAME}');" >> $sql
