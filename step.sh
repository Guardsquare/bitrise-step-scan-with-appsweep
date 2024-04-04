#!/bin/bash
set -exo pipefail

export APPSWEEP_API_KEY=${appsweep_api_key}
export IOS_ARCHIVE_PATH=${ios_archive_path}
export IOS_DSYMS_DIR_PATH=${ios_dsyms_dir_path}

if [ -z "$APPSWEEP_API_KEY" ]
then
	echo "Required input APPSWEEP_API_KEY is empty"	
	exit 1
fi

# iOS
if [ -e  "$IOS_ARCHIVE_PATH" ]; then
	if [ -e  "$IOS_ARCHIVE_PATH" ]; then
		APPSWEEP_CLI_DIR=$(mktemp -d)
		curl --retry 3 \
			--retry-max-time 120 \
			--retry-all-errors \
			-sS https://platform.guardsquare.com/cli/install.sh \
			| sh -s -- --yes --bin-dir "$APPSWEEP_CLI_DIR"

		if [ -d "$IOS_DSYMS_DIR_PATH" ]; then
			DSYMS_FLAG="--dsym $IOS_DSYMS_DIR_PATH"
		fi

		url=$("$APPSWEEP_CLI_DIR/guardsquare" scan "$IOS_ARCHIVE_PATH" $DSYMS_FLAG --format '{{.URL}}')

		echo "APPSWEEP_UPLOAD_URL=$url"
		envman add --key APPSWEEP_UPLOAD_URL --value $url
		exit 0
	fi

	echo "The iOS archive path at '$IOS_ARCHIVE_PATH' could not be found."
	exit 1
fi

# Gradle/Android
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

basename="uploadToAppSweep"
if [ -z "${build_variant+x}" ];
then
  # Build variant absent, we default to release
  output=$($GRADLEW "${basename}Release")
else
  capitalized="$(echo ${build_variant} | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}')"
  output=$($GRADLEW "$basename$capitalized")
fi

url=$(echo $output | grep 'Your scan results will be available at' | sed 's/.*Your scan results will be available at //')

envman add --key APPSWEEP_UPLOAD_URL --value $url
echo "APPSWEEP_UPLOAD_URL=$url"

