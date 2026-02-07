#!/usr/bin/env bash
  # Canonical Stop Hook for Claude Code (Linux/Codespace)
  # Bash equivalent of stop-hook.ps1 — uses curl instead of Invoke-RestMethod
  # Usage: Invoked automatically by Claude Code when session ends
  # Requirement: NTFY_TOPIC environment variable must be set

  # Read hook input JSON from stdin
  HOOK_INPUT=$(cat)

  # Extract fields using jq
  PROJECT_NAME=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' | xargs basename 2>/dev/null || echo "unknown")
  DURATION_MS=$(echo "$HOOK_INPUT" | jq -r '.cost.total_duration_ms // 0')
  REASON=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_reason // "Session ended"')

  # Format duration
  DURATION_S=$(( DURATION_MS / 1000 ))
  MINUTES=$(( DURATION_S / 60 ))
  SECONDS=$(( DURATION_S % 60 ))
  if [ "$MINUTES" -gt 0 ]; then
      FORMATTED="${MINUTES}m ${SECONDS}s"
  else
      FORMATTED="${SECONDS}s"
  fi

  # Build message body
  BODY="Task complete in ${PROJECT_NAME}
  Duration: ${FORMATTED}
  Reason: ${REASON}"

  # Send notification
  if [ -z "$NTFY_TOPIC" ]; then
      echo "NTFY_TOPIC environment variable not set" >&2
      exit 1
  fi

  curl -s \
      -H "Title: Claude Code: Task Complete" \
      -H "Priority: default" \
      -H "Tags: white_check_mark" \
      -d "$BODY" \
      "https://ntfy.sh/${NTFY_TOPIC}" > /dev/null 2>&1

  exit 0
