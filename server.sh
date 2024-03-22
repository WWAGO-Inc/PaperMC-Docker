#!/bin/bash

# Enter server directory
cd server

# The Project Name
PROJECT="paper"

# Get the newest version from the URL
MINECRAFT_VERSION=$(curl -s https://raw.githubusercontent.com/WWAGO-Inc/PaperMC-Docker/master/VERSION)

RAM=$(curl -s https://raw.githubusercontent.com/WWAGO-Inc/PaperMC-Docker/master/RAM)

# Get the Latest Paper version
LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/${PROJECT} | \
    jq -r '.versions[-1]')
# Get the Latest Paper Build
LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds | \
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

# Build The Jarname
JAR_NAME=${PROJECT}-${LATEST_VERSION}-${LATEST_BUILD}.jar

# Set the Paper Download URL
PAPERMC_URL="https://api.papermc.io/v2/projects/${PROJECT}/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"

# Add Aikar's GC Flags
JAVA_FLAGS="-Xmx$RAM -Xms$RAM -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"


# If The $JAR_NAME Variable File Doesnt Exist Then Update
if [ ! -e "$JAR_NAME" ]; 
then
  if [[ ! -e eula.txt ]]
  then
    echo Installing Paper...
    echo "eula=true" > "eula.txt"
    curl -so $JAR_NAME $PAPERMC_URL
    fi
  echo Updating Paper...
	rm paper*.jar
	curl -so $JAR_NAME $PAPERMC_URL
fi

# Start server
exec java -server $JAVA_FLAGS -jar "$JAR_NAME" nogui
