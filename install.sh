#!/usr/bin/env bash                                     
  # Dotfiles install script — runs automatically on Codespace creation
  # Copies hook scripts to ~/.claude/hooks/ and configures Claude Code settings
  #
  # Self-contained: works in ANY Codespace, no dependency on ControlCenter.
  # Hook scripts are bundled alongside this file in the dotfiles repo.

  set -e

  CLAUDE_DIR="$HOME/.claude"
  HOOKS_DIR="$CLAUDE_DIR/hooks"
  SETTINGS_FILE="$CLAUDE_DIR/settings.json"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo "[dotfiles] Setting up Claude Code hooks..."

  # Ensure directories exist
  mkdir -p "$CLAUDE_DIR" "$HOOKS_DIR"

  # Copy hook scripts from dotfiles repo to ~/.claude/hooks/
  if [ -f "$SCRIPT_DIR/stop-hook.sh" ] && [ -f "$SCRIPT_DIR/notification-hook.sh" ]; then
      cp "$SCRIPT_DIR/stop-hook.sh" "$HOOKS_DIR/stop-hook.sh"
      cp "$SCRIPT_DIR/notification-hook.sh" "$HOOKS_DIR/notification-hook.sh"
      chmod +x "$HOOKS_DIR/stop-hook.sh" "$HOOKS_DIR/notification-hook.sh"
      echo "[dotfiles] Copied hook scripts to $HOOKS_DIR/"
  else
      echo "[dotfiles] ERROR: stop-hook.sh or notification-hook.sh not found next to install.sh"
      echo "[dotfiles] Expected at: $SCRIPT_DIR/"
      exit 1
  fi

  # Build the hooks JSON to merge
  HOOKS_JSON=$(cat <<HOOKEOF
  {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOKS_DIR/stop-hook.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOKS_DIR/notification-hook.sh"
          }
        ]
      }
    ]
  }
  HOOKEOF
  )

  if [ -f "$SETTINGS_FILE" ]; then
      # Merge hooks into existing settings (preserves GSD hooks, statusLine, etc.)
      MERGED=$(jq --argjson new_hooks "$HOOKS_JSON" '
          .hooks = (.hooks // {}) * $new_hooks
      ' "$SETTINGS_FILE")
      echo "$MERGED" > "$SETTINGS_FILE"
      echo "[dotfiles] Merged notification hooks into existing settings.json"
  else
      # Create fresh settings with just the hooks
      jq -n --argjson hooks "$HOOKS_JSON" '{ hooks: $hooks }' > "$SETTINGS_FILE"
      echo "[dotfiles] Created settings.json with notification hooks"
  fi

  echo "[dotfiles] Done."
