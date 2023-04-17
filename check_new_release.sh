#!/bin/bash

# Replace these with your own GitHub username and repository name
GITHUB_USER="wvulibraries"
REPO_NAME="hydra_acda_portal_public"

# GITHUB_USER="scientist-softserv"
# REPO_NAME="west-virginia-university"


# GitHub API endpoint for release tags
API_URL="https://api.github.com/repos/$GITHUB_USER/$REPO_NAME/releases/latest"

# Get the latest release tag from the GitHub API
LATEST_TAG=$(curl --silent $API_URL | grep -Po '"tag_name": "\K.*?(?=")')
echo $LATEST_TAG
# Check if the tag exists
if [ -z "$LATEST_TAG" ]; then
  echo "Error: No release tags found."
  exit 1
fi

# Get the current checked-out tag
CURRENT_TAG=$(git describe --tags --abbrev=0)

# Check if the current tag matches the latest tag
if [ "$LATEST_TAG" == "$CURRENT_TAG" ]; then
  echo "Already on the latest release tag: $LATEST_TAG"
  exit 0
else
  echo "Found new release tag: $LATEST_TAG"
  echo "Checking out the new tag..."

  # Fetch the latest tags from the remote repository
  git fetch --tags

  # Check out the latest tag
  git checkout $LATEST_TAG

  # Show the current checked-out tag
  echo "Now on tag: $(git describe --tags --abbrev=0)"
fi
