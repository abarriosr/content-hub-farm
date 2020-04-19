#!/bin/bash

# Capture all runnning containers.
database_container=`docker-compose images | sed -n '1,2!p' | cut -f 1 -d ' ' | grep -e database`
containers=`docker-compose images | sed -n '1,2!p' | cut -f 1 -d ' ' | grep -v database`

# Wait until MySQL is running to start installation.
# Do not start installation until database service is running.
echo "Waiting for database in container \"${database_container}\" to become active..."
while [ "$(docker inspect --format "{{json .State.Status }}" ${database_container})" != "\"running\"" ]; do
  echo ".";
  sleep 1;
done
sleep 2;
echo "Database service active, starting Site installation."

# Separating list of containers in lists of 3 containers to be processed in parallel.
num_containers=`echo $containers | wc -w`
rest=$(($num_containers % 3))
if [ $rest != 0 ] ; then
  limit=$(($num_containers/3))
else
  limit=$(($num_containers/3 - 1))
fi

# Starting installation 3 containers at a time.
containers_list=$containers
for ((i=0; i<=$limit; i++)) {
  P[1]=""; P[2]=""; P[3]=""
  for ((j=1; j<=3; j++)) {
    container=`echo $containers_list | cut -f 1 -d ' '`
    if [ -z "$container" ]; then break; fi;
    print_logs=true
    containers_list=`echo $containers_list | awk '{ $1=""; print substr($0,2) }' `
    docker exec -it $container docker-entrypoint.sh | awk -v c="$container" -v j=$(($j+1)) '$0="\033[1;3"j"m" c "> \033[0m"$0' &
    P[$j]=$!
  }
  if [ $print_logs ]; then
    wait ${P[1]} ${P[2]} ${P[3]}
    echo ""
    print_logs=false
  fi
}

# Finished installation.
echo "Environment is ready."

