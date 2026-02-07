#!/usr/bin/env bash
  HOOK_INPUT=$(cat)
  PROJECT_NAME=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' | xargs basename 2>/dev/null || echo "unknown")
  DURATION_MS=$(echo "$HOOK_INPUT" | jq -r '.cost.total_duration_ms // 0')
  REASON=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_reason // "Session ended"')
  DURATION_S=$(( DURATION_MS / 1000 )); MINUTES=$(( DURATION_S / 60 )); SECONDS=$(( DURATION_S % 60 ))
  [ "$MINUTES" -gt 0 ] && FORMATTED="${MINUTES}m ${SECONDS}s" || FORMATTED="${SECONDS}s"
  BODY="Task complete in ${PROJECT_NAME}
  Duration: ${FORMATTED}
  Reason: ${REASON}"
  curl -s -H "Title: Claude Code: Task Complete" -H "Priority: default" -H "Tags: white_check_mark" -d "$BODY" "https://ntfy.sh/vscodealert" > /dev/null 2>&1
  exit 0

  notification-hook.sh:

  #!/usr/bin/env bash
  HOOK_INPUT=$(cat)
  PROJECT_NAME=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' | xargs basename 2>/dev/null || echo "unknown")
  MESSAGE=$(echo "$HOOK_INPUT" | jq -r '.message // "Waiting for input"')
  BODY="Waiting in ${PROJECT_NAME}
  ${MESSAGE}"
  curl -s -H "Title: Claude Code: Action Needed" -H "Priority: high" -H "Tags: rotating_light" -d "$BODY" "https://ntfy.sh/vscodealert" > /dev/null 2>&1
  exit 0
