#!/usr/bin/env bash
  HOOK_INPUT=$(cat)
  PROJECT_NAME=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' | xargs basename 2>/dev/null || echo "unknown")
  MESSAGE=$(echo "$HOOK_INPUT" | jq -r '.message // "Waiting for input"')
  BODY="Waiting in ${PROJECT_NAME}
  ${MESSAGE}"
  curl -s -H "Title: Claude Code: Action Needed" -H "Priority: high" -H "Tags: rotating_light" -d "$BODY" "https://ntfy.sh/vscodealert" > /dev/null 2>&1
  exit 0
