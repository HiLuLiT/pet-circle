#!/usr/bin/env bash
# pc-node-20-pre.sh — PreToolUse hook on Bash commands
# Detects npm/firebase commands that touch the functions/ Cloud Functions
# and instructs Claude (via permissionDecision=deny + clear retry hint) to
# rerun with the Node 20 PATH prepended.
#
# The repo's system default node is v12; Cloud Functions and the TypeScript
# compiler require Node 20 (per functions/package.json engines.node).
# Without this hook every `npm run build` / `firebase deploy --only functions`
# silently fails with "Unexpected token '?'" or similar syntax errors.

set -uo pipefail

NODE_PATH_REQUIRED='$HOME/.nvm/versions/node/v20.12.2/bin'

# Read the tool_input.command
CMD="$(jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$CMD" ] && exit 0

# Triggers we care about:
#   * Anything that mentions "npm run" or "npx" and the cwd is functions/
#   * Anything containing "firebase deploy" with --only functions (or no --only at all)
#   * Direct `tsc` invocations in functions/
# Skip if the command already explicitly sets the v20 PATH.
case "$CMD" in
  *"$NODE_PATH_REQUIRED"*) exit 0 ;;
  *"nvm use 20"*) exit 0 ;;
esac

NEEDS_NODE_20=0

# Cloud Functions npm/npx/tsc
if echo "$CMD" | grep -qE '(cd[[:space:]]+[^[:space:]]*functions|functions/[^[:space:]]*)'; then
  if echo "$CMD" | grep -qE '\b(npm|npx|tsc|yarn)\b'; then
    NEEDS_NODE_20=1
  fi
fi

# firebase deploy that touches functions
if echo "$CMD" | grep -qE 'firebase[[:space:]]+deploy'; then
  if echo "$CMD" | grep -qE -- '--only[[:space:]]+functions' || ! echo "$CMD" | grep -qE -- '--only'; then
    NEEDS_NODE_20=1
  fi
fi

if [ "$NEEDS_NODE_20" -eq 0 ]; then
  exit 0
fi

# Emit a JSON hookSpecificOutput that DENIES the original command and
# instructs Claude to retry with the Node 20 PATH prepended.
SUGGESTED="PATH=\"$NODE_PATH_REQUIRED:\$PATH\" $CMD"

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "[pc-node-20] This command needs Node 20 (Cloud Functions / firebase deploy). The system default is v12. Retry with the Node 20 PATH prepended:\n\n    $SUGGESTED\n\nIf this is a one-off and you really want system node, manually re-issue the command and the hook will not fire if it already contains the Node 20 PATH."
  }
}
EOF

exit 0
