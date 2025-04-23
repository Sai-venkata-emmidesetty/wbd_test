#!/bin/bash
#variables
ORG="sai-venkata-emmidesetty"
REPO_NAME="$1"
DESCRIPTION="$2"
#check arguments
if [ -z "$REPO_NAME" ] || [ -z "$DESCRIPTION" ]; then
  echo "Usage: $0 <repo_name> <description>"
  exit 1
fi
#create repository
gh repo create "$ORG/$REPO_NAME" \
  --private \
  --description="$DESCRIPTION" \
  --enable-issues \
  --enable-wiki
echo "Repository '$REPO_NAME' created in organization '$ORG'"
