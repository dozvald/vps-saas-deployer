#!/bin/sh
set -eu

SOURCE_DIR="/source"
TARGET_DIR="/target"

KERNEL_INFO=$(cat /proc/sys/kernel/osrelease 2>/dev/null || echo "")
IS_WINDOWS_DOCKER=0

# Check Kernel info
if echo "$KERNEL_INFO" | grep -qi "microsoft"; then
  IS_WINDOWS_DOCKER=1
  echo "Detected Docker Desktop (Windows/WSL kernel): $KERNEL_INFO"
fi

error_missing_env=0
error_missing_volume=0

# Case no volume -v mounted on /target
if [ ! -d /target ]; then
  error_missing_volume=1
  echo "Error - No volume mounted for /target folder !"
fi

# Case no -e UID/GID provided
if [ -z "${HOST_UID:-}" ] || [ -z "{$HOST_GID:-}" ]; then
  if [ "$IS_WINDOWS_DOCKER" -eq 1 ]; then
    # if Kernel is microsoft, no user rights to handle, behave as "root"
	# On Windows, files will be created by the current docker image user
    echo "Running under Docker Desktop (Windows/WSL) —> skipping UID/GID enforcement."
    HOST_UID=0
    HOST_GID=0
  else	
	error_missing_env=1
    echo "Error - Environment variables HOST_UID and HOST_GID must be provided."
  fi
fi

if [ "$error_missing_env" -eq 1 ] || [ "$error_missing_volume" -eq 1 ]; then
  echo ""
  echo "Please use one of the following commands to deploy the package in the current folder:"
  echo "- Git Bash (Windows): docker run --pull always --rm -e HOST_UID=\$(id -u) -e HOST_GID=\$(id -g) -v \"\$(pwd -W):/target\" davidozvald/vps-saas-deployer:latest"
  echo "- PowerShell (Windows): docker run --pull always --rm -e HOST_UID=\$(id -u) -e HOST_GID=\$(id -g) -v \"\${pwd}:/target\" davidozvald/vps-saas-deployer:latest"
  echo "- Linux/macOS: docker run --pull always --rm -e HOST_UID=\$(id -u) -e HOST_GID=\$(id -g) -v .:/target davidozvald/vps-saas-deployer:latest"
fi

# Creates a virtual user with provided UID/GID if the current user is not root
if [ "$HOST_UID" -eq 0 ]; then
  echo "Running as root (UID=0) — skipping user creation."
  HOST_USER="root"
else
  echo "Creating virtual user (UID=$HOST_UID, GID=$HOST_GID)"
  addgroup -g "$HOST_GID" hostgroup 2>/dev/null || true
  adduser -D -u "$HOST_UID" -G hostgroup hostuser 2>/dev/null || true
  HOST_USER="hostuser"
fi

echo "Now running as UID=$HOST_UID GID=$HOST_GID"

# Case /target directory does not exist
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error - Target directory $TARGET_DIR does not exist or is not a directory."
  exit 1
fi

# Check current user rights
if [ "$HOST_USER" = "root" ]; then
  sh -c "[ -w '$TARGET_DIR' ]" || {
    echo "Error - $TARGET_DIR not writable by root."
    exit 1
  }
else 
  runuser -u "$HOST_USER" -- sh -c "[ -w '$TARGET_DIR' ]" || {
    echo "Error - $TARGET_DIR not writable by UID=$HOST_UID."
    echo "Check your volume permissions or adjust UID/GID."
    exit 1
  }
fi

# Copy
echo "Starting copy..."
if [ "$HOST_USER" = "root" ]; then
  mkdir -p "$TARGET_DIR/vps-saas-deployer"
  cp -rnv "$SOURCE_DIR"/* "$TARGET_DIR/vps-saas-deployer"
  rm -f "$TARGET_DIR/vps-saas-deployer/bootstrap.sh"
else
  runuser -u "$HOST_USER" -- sh -c "
    mkdir -p '$TARGET_DIR/vps-saas-deployer' &&
    cp -rnv '$SOURCE_DIR'/* '$TARGET_DIR/vps-saas-deployer' &&
    rm -f '$TARGET_DIR/vps-saas-deployer/bootstrap.sh'
  "
fi

# Print sumup and final user used for files creation
FINAL_UID=$(id -u)
FINAL_USER=$(id -un 2>/dev/null || echo "UID:$FINAL_UID")

echo "Success - Files were copied by user '$FINAL_USER' (UID=$FINAL_UID) in folder: $TARGET_DIR/vps-saas-deployer."
echo "Package correctly deployed. Please take a look at Readme file. Enjoy."