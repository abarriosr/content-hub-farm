#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETUP_FILE="${SCRIPT_DIRECTORY}/../../include/setup_options.sh"
CONTENT_HUB_FARM_DIRECTORY=`dirname "$(dirname "$(dirname "$SCRIPT_DIRECTORY")"))"`

# @TODO: Check that docker-compose.yml exists, if so... ask to do a quick-setup.

# @TODO: Check if there are containers running, if so ask to destroy them, including volumes.

# @TODO: Check if there is codebase in the 'html' directory. If so, ask to delete it.

# @TODO: Add default values to configuration variables.

echo "Configuration Setup for Content Hub Farm"
echo "----------------------------------------"
echo ""

# Start Questionaire.
echo "#!/bin/bash" > ${SETUP_FILE};
echo "" >> ${SETUP_FILE};

# Enable NFS Volume Mount?
CONFIG_ENABLE_NFS=0;
echo "NFS Volume Mount."
read -p "Do you want to enable NFS Mounts (y/n)? " line
if [[ $line =~ ^[yY]$ ]] ; then
  CONFIG_ENABLE_NFS=1
  echo "Enabling NFS Mounts."
#  sh ${SCRIPT_DIRECTORY}/enable_nfs_mount.sh
else
  echo "Using native Docker mount."
fi
echo "# NFS Mount." >> ${SETUP_FILE}
echo "CONFIG_ENABLE_NFS=${CONFIG_ENABLE_NFS};" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
echo ""

# Setup Content Hub.
sh $SCRIPT_DIRECTORY/../../include/setup_contenthub.sh
echo ""

# Number of Publishers/Subscribers.
echo "Number of Publishers / Subscribers."
while : ; do
  echo "We recommend a maximum of 3 publishers and 3 subscribers."
  read -p "How many publishers? (1) " CONFIG_NUM_PUBLISHERS
  read -p "How many subscribers? (1) " CONFIG_NUM_SUBSCRIBERS
  [[ -z "${CONFIG_NUM_PUBLISHERS##*[!1-9]*}" || -z "${CONFIG_NUM_SUBSCRIBERS##*[!1-9]*}" ]] || break
done

echo "Your Content Hub Farm will contain ${CONFIG_NUM_PUBLISHERS} publisher(s) and ${CONFIG_NUM_SUBSCRIBERS} subscriber(s)."
echo "# Number of Publishers/Subscribers." >> ${SETUP_FILE}
echo "CONFIG_NUM_PUBLISHERS=${CONFIG_NUM_PUBLISHERS};" >> ${SETUP_FILE}
echo "CONFIG_NUM_SUBSCRIBERS=${CONFIG_NUM_SUBSCRIBERS};" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
echo ""

# Looping through each Publisher.
for (( i=1; i<=${CONFIG_NUM_PUBLISHERS}; i++ ))
do
  sh $SCRIPT_DIRECTORY/../../include/setup_publisher.sh $i
  echo ""
done

# Looping through each Subscriber.
for (( i=1; i<=${CONFIG_NUM_SUBSCRIBERS}; i++ ))
do
  sh $SCRIPT_DIRECTORY/../../include/setup_subscriber.sh $i ${CONFIG_NUM_PUBLISHERS}
  echo ""
done

# Volume Device Path.
echo "# Volume basepath and Ngrok Token." >> ${SETUP_FILE}
echo "CONFIG_VOLUME_DEVICE_PATH=$CONTENT_HUB_FARM_DIRECTORY" >> ${SETUP_FILE}

# Ngrok Token.
echo "Please Provide your Ngrok Token. You can obtain it from https://dashboard.ngrok.com/auth."
read -p "Ngrok token: " CONFIG_NGROK_TOKEN
echo "CONFIG_NGROK_TOKEN=\"${CONFIG_NGROK_TOKEN}\";" >> ${SETUP_FILE}
echo ""

echo "Configuration Options saved in './bin/include/setup_options.sh'."
echo "Creating docker-compose.yml file."

# Creating docker-compose.yml.
TEMPLATE='default'
if [ "${CONFIG_ENABLE_NFS}" == 1 ] ; then
  TEMPLATE='nfs'
fi
sh ${CONTENT_HUB_FARM_DIRECTORY}/bin/templates/docker-compose.sh $TEMPLATE

# Creating ngrok.yml.
sh ${CONTENT_HUB_FARM_DIRECTORY}/bin/templates/ngrok.sh


echo "Finished Setup."
