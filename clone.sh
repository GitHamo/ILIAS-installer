#!/bin/bash

# This script clones a specific branch of the ILIAS repository.

BRANCH_NAME=$1

if [ -z "$BRANCH_NAME" ]; then
  echo "Error: Missing required branch name as the first argument."
  echo "Usage: ./clone.sh <branch_name>"
  exit 1
fi

if echo "$BRANCH_NAME" | grep -q ' '; then
  echo "Error: Branch name must not contain spaces. Got: '$1'"
  exit 1
fi

if [ ! -d "versions/$BRANCH_NAME" ]; then
  echo "Error: Version '$BRANCH_NAME' is not supported or does not exist in the 'versions' directory."
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Error: 'git' command not found. Please install Git to proceed."
  exit 1
fi

echo "Preparing to clone ILIAS branch '$BRANCH_NAME'..."

if [ -d "src" ]; then
  echo "Warning: The 'src' directory already exists and will be replaced."
  read -p "Do you want to continue? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
  fi
  echo "Removing existing 'src' directory..."
  rm -rf src
  if [ $? -ne 0 ]; then
    echo "Error: Failed to remove the existing 'src' directory."
    exit 1
  fi
fi

echo "Cloning from https://github.com/ILIAS-eLearning/ILIAS.git into 'src'..."
git clone --branch "$BRANCH_NAME" --depth 1 https://github.com/ILIAS-eLearning/ILIAS.git src

if [ $? -ne 0 ]; then
  echo "Error: Failed to clone the repository."
  exit 1
fi

echo "Setting group ownership of 'src' directory to 'www-data'..."
sudo chown -R "$(id -u):$(getent group www-data | cut -d: -f3)" src

if [ $? -ne 0 ]; then
  echo "Error: Failed to set group ownership for the 'src' directory."
  exit 1
fi

echo "Successfully cloned branch '$BRANCH_NAME' into 'src'."
