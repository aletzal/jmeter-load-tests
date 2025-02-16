#!/bin/bash

set -e

REPO_URL=$1
REPO_USERNAME=$2
REPO_PASSWORD=$3

# Configuration
PUBLIC_MODULES=(
    "github.com/gin-gonic/gin@v1.9.1"
    "github.com/stretchr/testify@v1.8.4"
)  # Add the public modules you want to download
LOCAL_MODULES_DIR="go-dist"  # Local folder to store downloaded modules
PRIVATE_REPO="https://$REPO_USERNAME:$REPO_PASSWORD@kodera.perf/api/golang/test-repo-go"  # Your private repository URL
TEMP_DIR=$(mktemp -d)  # Temporary directory for cloning and modifying modules

# Ensure the local modules directory exists
mkdir -p "$LOCAL_MODULES_DIR"

# Create a temporary Go module to download dependencies
cd "$TEMP_DIR" || exit
go mod init temp-module

# Function to download a module and its dependencies
download_module() {
    local module=$1
    echo "Downloading module: $module"
    go get "$module"
}

# Function to copy a module to the local folder
copy_module_to_local() {
    local module=$1
    local module_path=$(echo "$module" | cut -d'@' -f1)
    local version=$(echo "$module" | cut -d'@' -f2)
    local module_dir="$LOCAL_MODULES_DIR/$(echo "$module_path" | tr '/' '-')-$version"

    echo "Copying module: $module_path@$version to $module_dir"
    mkdir -p "$module_dir"
    cp -r "$GOPATH/pkg/mod/$module_path@$version"/* "$module_dir/"
}

# Function to upload a module to the private repository
upload_module_to_private_repo() {
    local module=$1
    local module_path=$(echo "$module" | cut -d'@' -f1)
    local version=$(echo "$module" | cut -d'@' -f2)
    local module_name=$(basename "$module_path")
    local private_repo_url="$PRIVATE_REPO/$module_name"

    echo "Uploading module: $module_path@$version to $private_repo_url"

    # Clone the module source code
    local clone_dir="$TEMP_DIR/$module_name"
    git clone "https://$module_path" "$clone_dir"
    cd "$clone_dir" || exit

#    git config --local http.postBuffer 157286400

    git checkout "$version"

    # Create a new Git repository for the private module
    rm -rf .git  # Remove existing Git history
    git init
    git remote add origin "$private_repo_url"

    # Commit and push to the private repository
    git add .
    git commit -m "Add $module_path@$version"
    git tag "$version"
    git push origin main --tags

    echo "Uploaded $module_path@$version to $private_repo_url"
}

# Main script
for module in "${PUBLIC_MODULES[@]}"; do
    download_module "$module"
    copy_module_to_local "$module"
#    upload_module_to_private_repo "$module"
done

# Clean up
echo "$TEMP_DIR"
rm -rf "$TEMP_DIR"
echo "Done!"

## Configuration
#PUBLIC_MODULES=(
#    "github.com/gin-gonic/gin@v1.9.1"
#    "github.com/stretchr/testify@v1.8.4"
#)  # Add the public modules you want to download
#LOCAL_MODULES_DIR="go-dist"  # Local folder to store downloaded modules
#PRIVATE_REPO="https://$REPO_USERNAME:$REPO_PASSWORD@kodera.perf/api/golang/test-repo-go"  # Your private repository URL
#TEMP_DIR=$(mktemp -d)  # Temporary directory for cloning and modifying modules
#
## Ensure the local modules directory exists
#mkdir -p "$LOCAL_MODULES_DIR"
#
## Function to download a module and its dependencies
#download_module() {
#    local module=$1
#    echo "Downloading module: $module"
#    go get -d "$module"
#}
#
## Function to copy a module to the local folder
#copy_module_to_local() {
#    local module=$1
#    local module_path=$(echo "$module" | cut -d'@' -f1)
#    local version=$(echo "$module" | cut -d'@' -f2)
#    local module_dir="$LOCAL_MODULES_DIR/$(echo "$module_path" | tr '/' '-')-$version"
#
#    echo "Copying module: $module_path@$version to $module_dir"
#    mkdir -p "$module_dir"
#    cp -r "$GOPATH/pkg/mod/$module_path@$version"/* "$module_dir/"
#}
#
## Function to upload a module to the private repository
#upload_module_to_private_repo() {
#    local module=$1
#    local module_path=$(echo "$module" | cut -d'@' -f1)
#    local version=$(echo "$module" | cut -d'@' -f2)
#    local module_name=$(basename "$module_path")
#    local private_repo_url="$PRIVATE_REPO/$module_name"
#
#    echo "Uploading module: $module_path@$version to $private_repo_url"
#
#    # Clone the module source code
#    local clone_dir="$TEMP_DIR/$module_name"
#    git clone "https://$module_path" "$clone_dir"
#    cd "$clone_dir" || exit
#
#    # Checkout the specific version
#    git checkout "$version"
#
#    # Create a new Git repository for the private module
#    rm -rf .git  # Remove existing Git history
#    git init
#    git remote add origin "$private_repo_url"
#
#    # Commit and push to the private repository
#    git add .
#    git commit -m "Add $module_path@$version"
#    git tag "$version"
#    git push origin master --tags
#
#    echo "Uploaded $module_path@$version to $private_repo_url"
#}
#
## Main script
#for module in "${PUBLIC_MODULES[@]}"; do
#    download_module "$module"
#    copy_module_to_local "$module"
#    upload_module_to_private_repo "$module"
#done
#
## Clean up
#rm -rf "$TEMP_DIR"
#echo "Done!"

#echo "Installing required dependencies..."
#pip install --upgrade pip setuptools wheel twine
#
#echo "Removing existing .pypirc file (if any)..."
#rm -rf ./.pypirc
#
#echo "Creating .pypirc file..."
#cat <<EOF > ./.pypirc
#[distutils]
#index-servers =
#    kodera
#
#[kodera]
#repository = ${REPO_URL}
#username = ${REPO_USERNAME}
#password = ${REPO_PASSWORD}
#EOF
#
#DOWNLOAD_DIR="dist"
#echo "Recreate downloaded packages folder"
#rm -rf ${DOWNLOAD_DIR}
#mkdir -p ${DOWNLOAD_DIR}
#
#echo "Downloading packages from requirements.txt..."
#if [[ -f "python/test-requirements.txt" ]]; then
#    pip download -r python/test-requirements.txt -d ${DOWNLOAD_DIR}
#    # pip download -r ../requirements.txt -d $DOWNLOAD_DIR --no-binary :all:
#else
#    echo "python/test-requirements.txt file not found!"
#    exit 1
#fi
#
#echo "Uploading packages to kodera repository..."
#python3 -m twine upload --verbose --cert certs/kodera-perf.crt --repository kodera --config-file ./.pypirc ${DOWNLOAD_DIR}/*
#
#echo "Kodera - successfully uploaded packages"
#
#echo "Cleanup"
#rm -rf ./.pypirc
#rm -rf ${DOWNLOAD_DIR}
