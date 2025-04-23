#!/bin/bash

# USAGE:
# ./create_rulesets.sh <target-repo-name>

TARGET_REPO="Sai-venkata-emmidesetty/$1"

if [[ -z "$1" ]]; then
  echo "Usage: $0 <target-repo-name>"
  exit 1
fi

create_ruleset() {
  local RULESET_NAME="$1"
  local TARGET_BRANCH="$2"
  local APPROVERS="$3"

  RULESET_PAYLOAD=$(cat << EOF
{
  "name": "$RULESET_NAME",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {
    "ref_name": {
      "include": ["$TARGET_BRANCH"]
    }
  },
  "rules": [
    {
      "type": "required_pull_request_reviews",
      "parameters": {
        "required_approving_review_count": $APPROVERS,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "require_conversation_resolution": true
      }
    },
    {
      "type": "required_linear_history",
      "parameters": {
        "enabled": true
      }
    }
  ],
  "target": "branch"
}
EOF
)

  RESPONSE=$(gh api repos/$TARGET_REPO/rulesets \
    --method POST \
    --header "Accept: application/vnd.github+json" \
    --input - <<< "$RULESET_PAYLOAD" 2>&1)

  if [[ $? -ne 0 ]]; then
    echo "Failed to apply ruleset '$RULESET_NAME' to branch '$TARGET_BRANCH'."
    echo "Error: $RESPONSE"
    exit 1
  else
    echo "Ruleset '$RULESET_NAME' applied successfully to branch '$TARGET_BRANCH' in repo '$TARGET_REPO'"
  fi
}

# Apply to branches
create_ruleset "dev" "dev" 1
create_ruleset "qa" "qa" 2
create_ruleset "prod" "prod" 2
