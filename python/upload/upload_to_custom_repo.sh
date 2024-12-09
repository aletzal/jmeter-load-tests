#!/bin/bash

set -e

REPO_URL=$1
REPO_USERNAME=$2
REPO_PASSWORD=$3

echo "Installing required dependencies..."
pip install --upgrade pip setuptools wheel twine

echo "Removing existing .pypirc file (if any)..."
rm -rf ./.pypirc

echo "Creating .pypirc file..."
cat <<EOF > ./.pypirc
[distutils]
index-servers =
    kodera

[kodera]
repository = https://${REPO_URL}
username = ${REPO_USERNAME}
password = ${REPO_PASSWORD}
EOF

DOWNLOAD_DIR="dist"
echo "Recreate downloaded packages folder"
rm -rf ${DOWNLOAD_DIR}
mkdir -p ${DOWNLOAD_DIR}

echo "Downloading packages from requirements.txt..."
if [[ -f "../requirements.txt" ]]; then
    pip download -r ../requirements.txt -d ${DOWNLOAD_DIR}
    # pip download -r ../requirements.txt -d $DOWNLOAD_DIR --no-binary :all:
else
    echo "requirements.txt file not found!"
    exit 1
fi

echo "Uploading packages to kodera repository..."
python3 -m twine upload --verbose --cert localhost.crt --repository kodera --config-file ./.pypirc ${DOWNLOAD_DIR}/*

echo "Kodera - successfully uploaded packages"

echo "Cleanup"
rm -rf ./.pypirc
rm -rf ${DOWNLOAD_DIR}
