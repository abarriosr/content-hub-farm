#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETUP_FILE="${SCRIPT_DIRECTORY}/../../../setup_options.sh"
CONTENT_HUB_FARM_DIRECTORY=`dirname "$(dirname "$(dirname "$SCRIPT_DIRECTORY")"))"`

echo "Configuration Setup for Content Hub Farm"
echo "----------------------------------------"
echo ""

# If provided options --fast, then recreate docker-compose.yml from the saved configuration.
if [[ $1 == "--fast" && -f "$SETUP_FILE" ]] ; then
  echo "Regenerating docker-compose.yml and ngrok.yml from previously saved configuration."
  # Regenerating docker-compose.yml from setup_options.sh.
  source $SETUP_FILE
  TEMPLATE='default'
  if [ "${CONFIG_ENABLE_NFS}" == 1 ] ; then
    TEMPLATE='nfs'
  fi
  echo "Regenerating docker-composer.yml..."
  bash ${CONTENT_HUB_FARM_DIRECTORY}/bin/templates/docker-compose.sh $TEMPLATE
  # Creating ngrok.yml.
  echo "Regenerating ~/.ngrok2/ngrok.yml..."
  bash ${CONTENT_HUB_FARM_DIRECTORY}/bin/templates/ngrok.sh
  echo "Finished Setup."
  exit
fi

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
  bash ${SCRIPT_DIRECTORY}/enable_nfs_mount.sh
else
  echo "Using native Docker mount."
fi
echo "# NFS Mount." >> ${SETUP_FILE}
echo "CONFIG_ENABLE_NFS=${CONFIG_ENABLE_NFS};" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
echo ""

# Setup Content Hub.
bash $SCRIPT_DIRECTORY/../../include/setup_contenthub.sh
echo ""

# Setup MySQL Local Port Mapping.
echo "Please provide the MySQL local port you want to use."
echo "You could use tools like 'Sequel Pro' to connect to the site's databases."
read -p "MySQL port (3306): " CONFIG_MYSQL_LOCAL_PORT
CONFIG_MYSQL_LOCAL_PORT="${CONFIG_MYSQL_LOCAL_PORT:-3306}"
echo "# MySQL Local Port." >> ${SETUP_FILE}
echo "CONFIG_MYSQL_LOCAL_PORT=\"${CONFIG_MYSQL_LOCAL_PORT}\";" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
echo ""

# Build code using Build Profiles.

# Obtaining list of available profiles.
PROFILE_FILES=`ls -1 ${SCRIPT_DIRECTORY}/../../profiles/ | sed -e 's/\.sh$//'`
BUILD_PROFILES=()
for i in ${PROFILE_FILES}; do
  BUILD_PROFILES=("${BUILD_PROFILES[@]}" "$i")
done

echo "Select a Build Profile:"
select BUILD_PROFILE in "${BUILD_PROFILES[@]}"
do
  CONFIG_BUILD_PROFILE="${BUILD_PROFILE##*/}"
  if ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
    echo "  Incorrect Input: Select a number from the options presented."
  elif [ 1 -le "$REPLY" ] && [ "$REPLY" -le $((${#BUILD_PROFILES[@]})) ]; then
    echo "You selected Build Profile: \"$CONFIG_BUILD_PROFILE\"."
    break;
  else
    echo "Incorrect Input: Select a number from the options presented."
  fi
done

# If user selects customer environment the provide git repository.
case $CONFIG_BUILD_PROFILE in
  "customer-environment")
    # This is the "Customer Environment" Profile.
    echo "To replicate a Customer Environment, please provide the Git Repository and branch/tag to clone it from..."
    echo ""
    while : ; do
      read -p "Insert the Customer's Git Repository: " CONFIG_BUILD_CODE_REPOSITORY
      read -p "Insert the branch/tag name: " CONFIG_BUILD_CODE_BRANCH
      echo "Are the following values correct:"
      echo "  - Customer's Git Repository = ${CONFIG_BUILD_CODE_REPOSITORY}"
      echo "  - Branch/tag name = ${CONFIG_BUILD_CODE_BRANCH}"
      read -p "(y/n)? " line
        [[ ! $line =~ ^[Yy]$ ]] || break
    done
    echo "Saving Customer Environment information..."
    echo "# Build Site Codebase." >> ${SETUP_FILE}
    echo "CONFIG_BUILD_PROFILE=\"${CONFIG_BUILD_PROFILE}\";" >> ${SETUP_FILE}
    echo "CONFIG_BUILD_CODE_REPOSITORY=\"${CONFIG_BUILD_CODE_REPOSITORY}\";" >> ${SETUP_FILE}
    echo "CONFIG_BUILD_CODE_BRANCH=\"${CONFIG_BUILD_CODE_BRANCH}\";" >> ${SETUP_FILE}
    ;;
  *)
    # This is the "Default" Profile.
    echo "Do you want to install Acquia Content Hub from Public or Private Repository?"
    CONFIG_BUILD_CODE_SOURCE="public"
    CONFIG_BUILD_CODE_BRANCH="^2"
    options=("Public" "Private")
    select opt in "${options[@]}"
    do
      case $opt in
        "Public")
          echo "Using latest public release of Content Hub 2.x from Drupal.org."
          break;
          ;;
        "Private")
          CONFIG_BUILD_CODE_SOURCE="private"
          echo "Using Acquia's Private repository."
          read -p "Insert a Branch (8.x-2.x): " CONFIG_BUILD_CODE_BRANCH
          CONFIG_BUILD_CODE_BRANCH="${CONFIG_BUILD_CODE_BRANCH:-"8.x-2.x"}"
          break;
          ;;
        *) echo "Invalid option $REPLY";;
      esac
    done
    echo "Select the version of Drupal core you want to use. Default is D8 (^8). You can also select D9 (^9)."
    read -p "Drupal Core (^8): " CONFIG_BUILD_DRUPAL_CORE
    CONFIG_BUILD_DRUPAL_CORE="${CONFIG_BUILD_DRUPAL_CORE:-^8}"

    echo "# Build Site Codebase." >> ${SETUP_FILE}
    echo "CONFIG_BUILD_PROFILE=\"${CONFIG_BUILD_PROFILE}\";" >> ${SETUP_FILE}
    echo "CONFIG_BUILD_CODE_SOURCE=\"${CONFIG_BUILD_CODE_SOURCE}\";" >> ${SETUP_FILE}
    echo "CONFIG_BUILD_CODE_BRANCH=\"${CONFIG_BUILD_CODE_BRANCH}\";" >> ${SETUP_FILE}
    echo "CONFIG_BUILD_DRUPAL_CORE=\"${CONFIG_BUILD_DRUPAL_CORE}\";" >> ${SETUP_FILE}
    ;;
esac
echo "" >> ${SETUP_FILE}
echo ""

# Number of Publishers/Subscribers.
echo "Number of Publishers / Subscribers."
while : ; do
  echo "We recommend a maximum of 3 publishers and 3 subscribers."
  read -p "How many publishers? (1) " CONFIG_NUM_PUBLISHERS
  read -p "How many subscribers? (1) " CONFIG_NUM_SUBSCRIBERS
  CONFIG_NUM_PUBLISHERS_DEFAULT=1
  CONFIG_NUM_SUBSCRIBERS_DEFAULT=1
  CONFIG_NUM_PUBLISHERS="${CONFIG_NUM_PUBLISHERS:-${CONFIG_NUM_PUBLISHERS_DEFAULT}}"
  CONFIG_NUM_SUBSCRIBERS="${CONFIG_NUM_SUBSCRIBERS:-${CONFIG_NUM_SUBSCRIBERS_DEFAULT}}"
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
  bash $SCRIPT_DIRECTORY/../../include/setup_publisher.sh $i ${CONFIG_BUILD_PROFILE}
  echo ""
done

# Looping through each Subscriber.
for (( i=1; i<=${CONFIG_NUM_SUBSCRIBERS}; i++ ))
do
  bash $SCRIPT_DIRECTORY/../../include/setup_subscriber.sh $i ${CONFIG_NUM_PUBLISHERS} ${CONFIG_BUILD_PROFILE}
  echo ""
done

# Volume Device Path.
echo "# Volume basepath and Ngrok Token." >> ${SETUP_FILE}
echo "CONFIG_VOLUME_DEVICE_PATH=\"$CONTENT_HUB_FARM_DIRECTORY\"" >> ${SETUP_FILE}

# Ngrok Token.
echo "Please Provide your Ngrok Token. You can obtain it from https://dashboard.ngrok.com/auth."
read -p "Ngrok token: " CONFIG_NGROK_TOKEN
echo "CONFIG_NGROK_TOKEN=\"${CONFIG_NGROK_TOKEN}\";" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
echo ""

echo "Configuration Options saved in './setup_options.sh'."
echo "Creating docker-compose.yml file."

# Creating docker-compose.yml.
TEMPLATE='default'
if [ "${CONFIG_ENABLE_NFS}" == 1 ] ; then
  TEMPLATE='nfs'
fi
bash ${CONTENT_HUB_FARM_DIRECTORY}/bin/templates/docker-compose.sh $TEMPLATE

# Creating ngrok.yml.
bash ${CONTENT_HUB_FARM_DIRECTORY}/bin/templates/ngrok.sh

echo "Finished Setup."
