#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETUP_FILE="${SCRIPT_DIRECTORY}/../../include/setup_options.sh"

# @TODO: Check that docker-compose.yml exists, if so... ask to do a quick-setup.

# @TODO: Check if there are containers running, if so ask to destroy them, including volumes.

# @TODO: Check if there is codebase in the 'html' directory. If so, ask to delete it.


# Start Questionaire.
echo "#!/bin/bash" > ${SETUP_FILE};
echo "" >> ${SETUP_FILE};

echo "Configuration Setup for Content Hub Farm"
echo "----------------------------------------"
echo ""

# Enable NFS Volume Mount?
CONFIG_ENABLE_NFS=0;
echo "NFS Volume Mount."
read -p "Do you want to enable NFS Mounts? " line
if [[ $line =~ ^[yY]$ ]] ; then
  CONFIG_ENABLE_NFS=1
  echo "Enabling NFS Mounts."
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
echo "We recomment a maximum of 3 publishers and 3 subscribers."
read -p "How many publishers? (1) " CONFIG_NUM_PUBLISHERS
read -p "How many subscribers? (1) " CONFIG_NUM_SUBSCRIBERS

echo "You inserted ${CONFIG_NUM_PUBLISHERS} publisher(s) and ${CONFIG_NUM_SUBSCRIBERS} subscriber(s)."
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
