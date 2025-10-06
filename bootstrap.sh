#!/bin/sh
set -eu

if [ ! -d /target ]; then
  echo "Error - No volume mounted on /target !"
  echo "Please use one of the following commands:"
  echo "- Git Bash (Windows): docker run --pull always --rm -v \"$(pwd -W):/target\" davidozvald/vps-saas-deployer:latest"
  echo "- PowerShell (Windows): docker run --pull always --rm -v \"${pwd}:/target\" davidozvald/vps-saas-deployer:latest"
  echo "- Linux/macOS: docker run --pull always --rm -v .:/target davidozvald/vps-saas-deployer:latest"
  exit 1
fi

echo "Starting copy..."
mkdir /target/vps-saas-deployer
cp -rnv /source/* /target/vps-saas-deployer
rm /target/vps-saas-deployer/bootstrap.sh
mkdir /target/vps-saas-deployer/vps
echo "Package correctly deployed. Take a quick moment to configure variables before using. Enjoy."