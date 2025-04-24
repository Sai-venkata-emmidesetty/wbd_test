#!/bin/bash

# Variables
ORG="sai-venkata-emmidesetty"
REPO_NAME="$1"
DESCRIPTION="$2"

# Check arguments
if [ -z "$REPO_NAME" ] || [ -z "$DESCRIPTION" ]; then
  echo "Usage: $0 <repo_name> <description>"
  exit 1
fi

# Create repository
gh repo create "$ORG/$REPO_NAME" \
  --private \
  --description="$DESCRIPTION" \
  --enable-issues \
  --enable-wiki

echo "Repository '$REPO_NAME' created in organization '$ORG'"

# Clone the repo locally
git clone "https://github.com/$ORG/$REPO_NAME.git"
cd "$REPO_NAME" || exit

# Create an initial commit (GitHub does not allow operations on an empty repo)
echo "# $REPO_NAME" > README.md
git add README.md
git commit -m "Initial commit"
git branch -M prod
git push -u origin prod

# Set prod as the default branch
gh api --method PATCH "repos/$ORG/$REPO_NAME" -f default_branch='prod'

# Create dev and qa branches from prod
git checkout -b dev
git push -u origin dev

git checkout prod
git checkout -b qa
git push -u origin qa

# Echo all remote branch names
echo "Current branches in the repository:"
git ls-remote --heads "https://github.com/$ORG/$REPO_NAME.git" | awk '{print $2}' | sed 's|refs/heads/||'
