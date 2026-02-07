#!/usr/bin/env bash
# Dotfiles install script — runs automatically on Codespace creation
# Configures Claude Code hooks for ntfy.sh notifications

set -e

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "[dotfiles] Setting up Claude Code hooks..."

mkdir -p "$CLAUDE_DIR"

# The hook scripts live in ControlCenter — find the workspace path
# Codespaces clone repos into /workspaces/<repo-name>
CC_HOOKS="/workspaces/_CONTROLCENTER/configs/hooks"

# Define the hooks we want to add
STOP_HOOK="$CC_HOOKS/stop-hook.sh"
NOTIF_HOOK="$CC_HOOKS/notification-hook.sh"

# Build the hooks JSON to merge
HOOKS_JSON=$(cat <<'HOOKEOF'
{
  "Stop": [
    {
      "type": "command",
      "command": "__STOP_HOOK__"
    }
  ],
  "Notification": [
    {
      "type": "command",
      "command": "__NOTIF_HOOK__"
    }
  ]
}
HOOKEOF
)

# Replace placeholders with actual paths
HOOKS_JSON=$(echo "$HOOKS_JSON" | sed "s|__STOP_HOOK__|$STOP_HOOK|g" | sed "s|__NOTIF_HOOK__|$NOTIF_HOOK|g")

if [ -f "$SETTINGS_FILE" ]; then
    # Merge hooks into existing settings (preserves GSD hooks, statusLine, etc.)
    MERGED=$(jq --argjson new_hooks "$HOOKS_JSON" '
        .hooks = (.hooks // {}) * $new_hooks
    ' "$SETTINGS_FILE")
    echo "$MERGED" > "$SETTINGS_FILE"
    echo "[dotfiles] Merged notification hooks into existing settings.json"
else
    # Create fresh settings with just the hooks
    echo "{\"hooks\": $HOOKS_JSON}" | jq '.' > "$SETTINGS_FILE"
    echo "[dotfiles] Created settings.json with notification hooks"
fi

# Remind about NTFY_TOPIC
if [ -z "$NTFY_TOPIC" ]; then
    echo "[dotfiles] WARNING: NTFY_TOPIC not set. Add it as a Codespace secret for notifications to work."
    echo "[dotfiles] Go to: https://github.com/settings/codespaces → Secrets → New secret"
fi

echo "[dotfiles] Done."
