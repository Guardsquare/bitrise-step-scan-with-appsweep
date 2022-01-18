#!/bin/bash
set -ex

export APPSWEEP_API_KEY=${appsweep_api_key}

if [ -z "$APPSWEEP_API_KEY" ]
then
	echo "Required input APPSWEEP_API_KEY is empty"	
	exit 1
fi

cd ${project_location}
BUILD_FILE=./app/build.gradle

if [ ! -f "$BUILD_FILE" ]; then
    echo "$BUILD_FILE does not exist. Probably you are using not standard project structure, please add \"com.guardsquare.appsweep\" to the plugin section of your app's build.gradle script."
else
	if grep -Fq "\"com.guardsquare.appsweep\"" $BUILD_FILE
	then
		echo "AppSweep plugin already exists in $BUILD_FILE. Not injecting."
	else
		echo "AppSweep plugin was not found in $BUILD_FILE. Injecting..."
		#remove all white lines
		sed -i '/^[[:space:]]*$/d' $BUILD_FILE
		#remove potential new line characters after 'plugins'
		sed -i '/plugins/{N;s/\n//;}' $BUILD_FILE
		#inject AppSweep plugin
		sed -i "s/plugins\s*{/plugins\n{\n\tid \"com.guardsquare.appsweep\" version \"${gradle_plugin_version}\"\n/1" $BUILD_FILE
		if grep -Fq "\"com.guardsquare.appsweep\"" $BUILD_FILE
		then
			echo "AppSweep plugin succesfully injected to $BUILD_FILE."
		else
			echo "AppSweep plugin was not injected to $BUILD_FILE. Please add \"com.guardsquare.appsweep\" to the plugin section of your app's build.gradle script."
		fi   
	fi
fi

if [ -f "./gradlew" ];
then
	echo "The gradlew wrapper was found in ${project_location}/gradlew"
	GRADLEW=./gradlew
else
	echo "The gradlew wrapper was not found. Please provide the correct project_location."
	exit 1
fi
if [ "${build_variant}" = "debug" ]
then
	output=$($GRADLEW uploadToAppSweepDebug)
else
    output=$($GRADLEW uploadToAppSweepRelease)
fi

url=$(echo $output | grep -oP '(?<=Your scan results will be available at )[^ ]*' )

envman add --key APPSWEEP_UPLOAD_URL --value $url
echo "APPSWEEP_UPLOAD_URL="$url

