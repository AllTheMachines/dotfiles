#!/usr/bin/env bash
  # Canonical Notification Hook for Claude Code (Linux/Codespace)
  # Bash equivalent of notification-hook.ps1 — uses curl instead of Invoke-RestMethod
  # Usage: Invoked automatically by Claude Code on ANY blocking wait
  # Requirement: NTFY_TOPIC environment variable must be set

  # Read hook input JSON from stdin
  HOOK_INPUT=$(cat)

  # Extract fields using jq
  PROJECT_NAME=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' | xargs basename 2>/dev/null || echo "unknown")
  MESSAGE=$(echo "$HOOK_INPUT" | jq -r '.message // "Waiting for input"')

  # Build message body
  BODY="Waiting in ${PROJECT_NAME}
  ${MESSAGE}"

  # Send notification
  if [ -z "$NTFY_TOPIC" ]; then
      echo "NTFY_TOPIC environment variable not set" >&2
      exit 1
  fi

  curl -s \
      -H "Title: Claude Code: Action Needed" \
      -H "Priority: high" \
      -H "Tags: rotating_light" \
      -d "$BODY" \
      "https://ntfy.sh/${NTFY_TOPIC}" > /dev/null 2>&1

  exit 0
