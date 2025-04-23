#!/bin/bash

# USAGE:
# ./create_rulesets.sh <target-repo-name>

# Validate input
if [[ -z "$1" ]]; then
  echo "Usage: $0 <target-repo-name>"
  exit 1
fi

# Set the full target repository path
TARGET_REPO="venkata-sai-emmidesetty/$1"

# Function to create a ruleset for a specific branch
create_ruleset() {
  local RULESET_NAME="$1"
  local TARGET_BRANCH="$2"
  local APPROVERS="$3"

  RULESET_PAYLOAD=$(cat <<EOF
{
  "name": "$RULESET_NAME",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {
    "ref_name": {
      "include": ["$TARGET_BRANCH"],
      "exclude": []
    }
  },
  "rules": {
    "required_pull_request_reviews": {
      "required_approving_review_count": $APPROVERS,
      "dismiss_stale_reviews_on_push": true,
      "require_code_owner_review": true,
      "require_last_push_approval": false,
      "require_conversation_resolution": true
    },
    "pull_request": {
      "enabled": true
    },
    "required_linear_history": {
      "enabled": true
    },
    "required_deployments": {
      "enabled": false,
      "required_deployment_environments": []
    },
    "required_signatures": {
      "enabled": true
    },
    "merge_queue": {
      "enabled": true
    },
    "restrict_creations": {
      "enabled": true
    },
    "restrict_updates": {
      "enabled": true
    },
    "restrict_deletions": {
      "enabled": true
    },
    "required_status_checks": {
      "enabled": false,
      "strict": false,
      "contexts": []
    },
    "force_push": {
      "enabled": false
    },
    "allowed_merge_strategies": {
      "merge": true,
      "squash": true,
      "rebase": true
    }
  },
  "target": "branch"
}
EOF
)

  # Send ruleset to GitHub API
  RESPONSE=$(gh api repos/"$TARGET_REPO"/rulesets \
    --method POST \
    --header "Accept: application/vnd.github+json" \
    --input <(echo "$RULESET_PAYLOAD") 2>&1)

  # Check if the API call was successful
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to apply ruleset '$RULESET_NAME' to branch '$TARGET_BRANCH'."
    echo "Error: $RESPONSE"
    exit 1
  else
    echo "✅ Ruleset '$RULESET_NAME' applied successfully to branch '$TARGET_BRANCH' in repo '$TARGET_REPO'"
  fi
}

# Create rulesets for dev, qa, and prod branches
create_ruleset "dev" "dev" 1
create_ruleset "qa" "qa" 2
create_ruleset "prod" "prod" 2
