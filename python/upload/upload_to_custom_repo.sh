#!/bin/bash

set -e

# Install dependencies (if they are not installed already)
echo "Installing required dependencies..."
pip install --upgrade pip setuptools wheel twine

# Remove any existing .pypirc file to ensure it is overwritten
echo "Removing existing .pypirc file (if any)..."
rm -rf ./.pypirc

# Define repository details for .pypirc file
REPO_URL=$1
REPO_USERNAME=$2
REPO_PASSWORD=$3

# Create .pypirc file dynamically
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

# Create a directory for downloaded packages
DOWNLOAD_DIR="dist"
echo "Delete downloaded packages folder"
rm -rf ${DOWNLOAD_DIR}
echo "Creating folder for downloaded packages"
mkdir -p ${DOWNLOAD_DIR}

# Download the specified packages from requirements.txt to the created directory
echo "Downloading packages from requirements.txt..."
if [[ -f "../requirements.txt" ]]; then
    pip download -r ../requirements.txt -d ${DOWNLOAD_DIR}
    # pip download -r ../requirements.txt -d $DOWNLOAD_DIR --no-binary :all:
else
    echo "requirements.txt file not found!"
    exit 1
fi

# Upload downloaded packages to the custom repository
echo "Uploading packages to custom repository..."
python3 -m twine upload --verbose --cert localhost.crt --repository kodera --config-file ./.pypirc ${DOWNLOAD_DIR}/*

echo "Cleanup"
rm -rf ./.pypirc
rm -rf ${DOWNLOAD_DIR}

echo "Kodera - successfully uploaded packages"
