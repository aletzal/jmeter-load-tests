#!/bin/bash

set -e

# Parameters passed to the script
THREAD_NUM=$1
REPO_URL=$2
USERNAME=$3
PASSWORD=$4

# Target directory for the package installation
TARGET_DIR="./tmp/testfolder_${THREAD_NUM}"

# Remove old target directory
rm -rf ${TARGET_DIR}

# Create the target directory if it doesn't exist
mkdir -p ${TARGET_DIR}

# Run pip install with the custom repository and authentication
pip install -r requirements.txt --disable-pip-version-check --index-url https://${USERNAME}:${PASSWORD}@${REPO_URL}/simple ${PACKAGE_NAME} --trusted-host localhost --no-cache-dir --target ${TARGET_DIR}

echo "Cleanuo"
rm -rf ${TARGET_DIR}

echo "Kodera - successfully installed packages"
