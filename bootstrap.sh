#!/bin/sh
set -eu

SOURCE_DIR="/source"
TARGET_DIR="/target"

if [ ! -d /target ]; then
  echo "Error - No volume mounted on /target !"
  echo "Please use one of the following commands:"
  echo "- Git Bash (Windows): docker run --pull always --rm -v \"\$(pwd -W):/target\" davidozvald/vps-saas-deployer:latest"
  echo "- PowerShell (Windows): docker run --pull always --rm -v \"\${pwd}:/target\" davidozvald/vps-saas-deployer:latest"
  echo "- Linux/macOS: docker run --pull always --rm -v .:/target davidozvald/vps-saas-deployer:latest"
  exit 1
fi

# Gets user id and group id
UID_CUR=$(id -u)
GID_CUR=$(id -g)

echo "Running as UID=$UID_CUR GID=$GID_CUR"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error - Target directory $TARGET_DIR does not exist or is not a directory."
  exit 1
fi

# Check current user rights
if [ ! -w "$TARGET_DIR" ]; then
  echo "Error - $TARGET_DIR not writable by UID=$UID_CUR."
  
  # if user is not root, try with root user
  if [ "$UID_CUR" -ne 0 ]; then
    echo "Retrying as root..."
	#replaces the process with a new user (root)
    exec su -s /bin/sh root -c "$0 $@"
  else
    echo "Error - Even root cannot write to $TARGET_DIR. Check volume permissions."
    exit 1
  fi
fi

echo "Starting copy..."
mkdir $TARGET_DIR/vps-saas-deployer
cp -rnv $SOURCE_DIR/* $TARGET_DIR/vps-saas-deployer
rm $TARGET_DIR/vps-saas-deployer/bootstrap.sh

FINAL_UID=$(id -u)
FINAL_USER=$(id -un 2>/dev/null || echo "UID:$FINAL_UID")

echo "Success - Files were copied by user '$FINAL_USER' (UID=$FINAL_UID) in folder: $TARGET_DIR."
echo "Package correctly deployed. Please take a look at Readme file. Enjoy."