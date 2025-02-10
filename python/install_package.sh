#!/bin/bash

set -e

THREAD_NUM=$1
REPO_URL=$2
USERNAME=$3
PASSWORD=$4

TARGET_DIR="./tmp/testfolder_${THREAD_NUM}"

echo "Recreate target folder"
rm -rf ${TARGET_DIR}
mkdir -p ${TARGET_DIR}

echo "Install packages by test-requirements.txt from the kodera repository"
pip install -r test-requirements.txt --disable-pip-version-check --index-url https://${USERNAME}:${PASSWORD}@${REPO_URL}/simple --cert upload/localhost.crt --no-cache-dir --target ${TARGET_DIR}

echo "Kodera - successfully installed packages"

echo "Cleanup"
rm -rf ${TARGET_DIR}
