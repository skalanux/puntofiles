#!/usr/bin/env sh
# provision.sh — runs `make install` inside a newly created worktree
#
# Environment injected by Herdr:
#   HERDR_PLUGIN_CONTEXT_JSON  — JSON with worktree, workspace, pane data
#   HERDR_PLUGIN_EVENT_JSON    — raw event payload
#   HERDR_BIN_PATH             — path to the running herdr binary
#   HERDR_PLUGIN_STATE_DIR     — persistent plugin state directory
#   HERDR_PLUGIN_ROOT          — absolute path to this plugin directory
#   HERDR_PLUGIN_EVENT         — "worktree.created"
#   HERDR_PLUGIN_CONFIG_DIR    — user-editable plugin config directory

set -e

# Extract worktree directory from the context JSON
WORKTREE_DIR=$(printf '%s' "$HERDR_PLUGIN_CONTEXT_JSON" \
  | python3 -c "
import sys, json
try:
    ctx = json.load(sys.stdin)
    print(ctx.get('worktree', {}).get('directory', '') or ctx.get('workspace', {}).get('directory', ''))
except Exception:
    sys.exit(0)
")

if [ -z "$WORKTREE_DIR" ]; then
  exit 0
fi

if [ ! -d "$WORKTREE_DIR" ]; then
  exit 0
fi

cd "$WORKTREE_DIR"

if ! command -v make >/dev/null 2>&1; then
  exit 0
fi

if [ ! -f Makefile ]; then
  exit 0
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running make install in $WORKTREE_DIR"

if make install; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] make install succeeded in $WORKTREE_DIR"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] make install failed in $WORKTREE_DIR"
  exit 1
fi
