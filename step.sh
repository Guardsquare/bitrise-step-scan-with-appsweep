#!/bin/bash
set -exo pipefail

APPSWEEP_API_KEY=${appsweep_api_key}
APP_PATH=${android_app_path}

if [ -z "$APP_PATH" ]; then
	APP_PATH=${ios_archive_path}
fi

if [ -z "$APPSWEEP_API_KEY" ]
then
	echo "Required input APPSWEEP_API_KEY is empty"	
	exit 1
fi

if [ -e  "$APP_PATH" ] ; then
	APPSWEEP_CLI_DIR=$(mktemp -d)
	curl --retry 3 \
		--retry-max-time 120 \
		--retry-all-errors \
		-sS https://platform.guardsquare.com/cli/install.sh \
		| sh -s -- --yes --bin-dir "$APPSWEEP_CLI_DIR"

	if [ -d "${ios_dsyms_dir_path}" ]; then
		DSYMS_FLAG="--dsym ${ios_dsyms_dir_path}"
	fi
	if [ -e "${android_mappingfile_path}" ]; then
		MAPPING_FLAG="--mapping-file ${android_mappingfile_path}_DIR_PATH"
	fi
	if [ -n "${commit_hash}" ]; then
		COMMIT_FLAG="--commit-hash ${commit_hash}"
	fi
	if [ -d "${android_project_location}" ]; then
		PROJECTDIR_FLAG="--project-dir ${android_project_location}"
	fi

	url=$($APPSWEEP_CLI_DIR/guardsquare scan $APP_PATH $DSYMS_FLAG $MAPPING_FLAG $COMMIT_FLAG $PROJECTDIR_FLAG --format '{{.URL}}')

	echo "You can view your scan results at $url"
	envman add --key APPSWEEP_UPLOAD_URL --value $url
else
	echo "Input file $APP_PATH does not exist"
	exit 1
fi
