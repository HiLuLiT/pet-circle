#!/usr/bin/env bash
# pc-pr-create.sh — PreToolUse hook on Bash for `gh pr create` / `gh pr ready`
#
# Blocks PR creation/readiness if the full /pc-phase review hasn't passed
# recently. This is Layer 2 of the autonomous gate stack:
#
#   Layer 1: pc-pre-push.sh    — analyze + tests on `git push` (~30s)
#   Layer 2: pc-pr-create.sh   — full review on `gh pr create` (~3-5min)
#   Layer 3: .github/workflows/pr-review.yml — CI reviewers on PR sync
#
# On missing or stale review-marker: DENY the PR creation with a clear hint
# telling Claude to run `/pc-phase --auto` first. The skill writes the review
# marker only when reviewers pass cleanly with zero CRITICAL findings.
#
# Bypass:
#   - PC_SKIP=1 gh pr create  (project-specific escape hatch)

set -uo pipefail

PROJECT_ROOT="/Users/hilabb/repos/pet-circle"
MARKER_TTL_SECONDS=900  # 15 minutes (longer than the static gate's 10min — full review is slower so re-runs are more painful)

CMD="$(jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$CMD" ] && exit 0

# Match `gh pr create` or `gh pr ready` (the latter converts a draft to
# ready-for-review, equivalent moment).
if ! echo "$CMD" | grep -qE '(^|[[:space:];&|])gh[[:space:]]+pr[[:space:]]+(create|ready)([[:space:]]|$)'; then
  exit 0
fi

# --- Bypass checks --------------------------------------------------------

if echo "$CMD" | grep -qE 'PC_SKIP=1\b'; then
  echo "[pc-pr-create] PC_SKIP=1 detected — bypassing review gate." >&2
  exit 0
fi

if [ "${PC_SKIP:-0}" = "1" ]; then
  echo "[pc-pr-create] PC_SKIP env var set — bypassing review gate." >&2
  exit 0
fi

# --- Marker check ---------------------------------------------------------

BRANCH="$(cd "$PROJECT_ROOT" && git rev-parse --abbrev-ref HEAD 2>/dev/null)"
BRANCH_HASH="$(echo -n "$BRANCH" | shasum | awk '{print $1}' | cut -c1-12)"
MARKER="/tmp/pc-review-${BRANCH_HASH}.pass"

if [ -f "$MARKER" ]; then
  MARKER_AGE=$(($(date +%s) - $(stat -f %m "$MARKER" 2>/dev/null || stat -c %Y "$MARKER" 2>/dev/null || echo 0)))
  if [ "$MARKER_AGE" -lt "$MARKER_TTL_SECONDS" ]; then
    # Verify no source file has been edited since the marker was written.
    NEWER=$(find "$PROJECT_ROOT/lib" "$PROJECT_ROOT/test" "$PROJECT_ROOT/functions/src" \
              -type f -newer "$MARKER" 2>/dev/null | head -1)
    if [ -z "$NEWER" ]; then
      echo "[pc-pr-create] ✓ recent review-marker (${MARKER_AGE}s ago, no edits since) — allowing PR action." >&2
      exit 0
    fi
    echo "[pc-pr-create] review marker found but files edited since — denying." >&2
  else
    echo "[pc-pr-create] review marker is stale (${MARKER_AGE}s old, TTL ${MARKER_TTL_SECONDS}s) — denying." >&2
  fi
fi

# --- DENY with recovery instructions --------------------------------------

REASON="[pc-pr-create] PR creation BLOCKED — full review has not passed recently.

Before opening or marking this PR ready-for-review, run:

    /pc-phase --auto --phase \"PR review for $BRANCH\"

This will dispatch the three code reviewers (flutter-reviewer, code-reviewer,
security-reviewer) in parallel, auto-fix any HIGH findings, and write the
review marker on PASS. Then retry the gh pr command.

If a CRITICAL issue is found, /pc-phase --auto will report it and refuse to
write the marker — you must resolve the CRITICAL manually before the gate
will allow PR creation.

To bypass intentionally: PC_SKIP=1 gh pr create ..."

REASON_JSON=$(printf '%s' "$REASON" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '"%s"' "${REASON//\"/\\\"}")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": $REASON_JSON
  }
}
EOF

exit 0
