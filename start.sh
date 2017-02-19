#!/bin/bash
# Handles running Spigot Servers
sleep 3

cd /home/container
CHK_FILE="/home/container/${SERVER_JARFILE}"

if [ -f $CHK_FILE ]; then
   echo "A ${SERVER_JARFILE} file already exists in this location, not downloading a new one."
else
    if [ -z "$DL_PATH" ] || [ "$DL_PATH" == "build" ]; then
        echo "Building Spigot... This could take awhile."

        mkdir -p /home/container/.tmp-build
        cd /home/container/.tmp-build

	# set user.home explicity, Java in docker is not fetching this variable properly
	export _JAVA_OPTIONS=-Duser.home=/home/container/.tmp-build
        curl -sS -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
        git config --global --unset core.autocrlf
        java -jar BuildTools.jar --rev ${DL_VERSION}

        cp /home/container/.tmp-build/spigot-*.jar /home/container/${SERVER_JARFILE}

        if [ $? -eq 0 ]; then
            rm -rf /home/container/.tmp-build
        fi
	unset _JAVA_OPTIONS
        cd /home/container
    else
        # Download the file
        MODIFIED_DL_PATH=`echo ${DL_PATH} | perl -pe 's@\{\{(.*?)\}\}@$ENV{$1}@g'`
        echo "$ curl -sS -L -o ${SERVER_JARFILE} ${MODIFIED_DL_PATH}"
        curl -sS -L -o ${SERVER_JARFILE} ${MODIFIED_DL_PATH}
    fi
fi

cd /home/container

if [ -z "$STARTUP"  ]; then
    echo "error: no startup parameters have been set for this container"
else
    # Output java version to console for debugging purposes if needed.
    java -version

    # Pass in environment variables.
    MODIFIED_STARTUP=`echo ${STARTUP} | perl -pe 's@\{\{(.*?)\}\}@$ENV{$1}@g'`
    echo "$ java ${MODIFIED_STARTUP}"

    # Run the server.
    java ${MODIFIED_STARTUP}
fi
