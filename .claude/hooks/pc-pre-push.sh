#!/usr/bin/env bash
# pc-pre-push.sh — PreToolUse hook on Bash for `git push`
#
# Runs the STATIC gate (gen-l10n if needed + flutter analyze + flutter test)
# before allowing any `git push`. Pure shell, no LLM, ~30–60 seconds.
#
# On failure: returns a JSON deny + recovery hint telling Claude to invoke
# `/pc-phase --auto`. Claude can then run the full skill (with reviewers and
# auto-fix), and on success write the pass-marker that lets the retry through.
#
# Bypass mechanisms (either works):
#   - `git push --no-verify`        — standard Git escape hatch
#   - `PC_SKIP=1 git push`          — project-specific escape hatch
#
# Pass-marker:
#   /tmp/pc-gate-<branch-sha1>.pass  — written by `/pc-phase --auto` on PASS,
#   read by this hook to short-circuit consecutive pushes within 10 minutes.

set -uo pipefail

PROJECT_ROOT="/Users/hilabb/repos/pet-circle"
MARKER_TTL_SECONDS=600  # 10 minutes

# Read the tool_input.command
CMD="$(jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$CMD" ] && exit 0

# Only act on `git push` commands. Match start-of-word `git push` (so e.g.
# `git pushd` or `gitlab push` don't trigger).
if ! echo "$CMD" | grep -qE '(^|[[:space:];&|])git[[:space:]]+push([[:space:]]|$)'; then
  exit 0
fi

# --- Bypass checks --------------------------------------------------------

# Bypass: --no-verify is in the command
if echo "$CMD" | grep -qE -- '--no-verify\b'; then
  echo "[pc-pre-push] --no-verify detected — bypassing static gate." >&2
  exit 0
fi

# Bypass: PC_SKIP=1 is in the command (e.g. `PC_SKIP=1 git push`)
if echo "$CMD" | grep -qE 'PC_SKIP=1\b'; then
  echo "[pc-pre-push] PC_SKIP=1 detected — bypassing static gate." >&2
  exit 0
fi

# Bypass: PC_SKIP=1 is exported in the calling environment
if [ "${PC_SKIP:-0}" = "1" ]; then
  echo "[pc-pre-push] PC_SKIP env var set — bypassing static gate." >&2
  exit 0
fi

# --- Marker check ---------------------------------------------------------

BRANCH="$(cd "$PROJECT_ROOT" && git rev-parse --abbrev-ref HEAD 2>/dev/null)"
BRANCH_HASH="$(echo -n "$BRANCH" | shasum | awk '{print $1}' | cut -c1-12)"
MARKER="/tmp/pc-gate-${BRANCH_HASH}.pass"

if [ -f "$MARKER" ]; then
  MARKER_AGE=$(($(date +%s) - $(stat -f %m "$MARKER" 2>/dev/null || stat -c %Y "$MARKER" 2>/dev/null || echo 0)))
  if [ "$MARKER_AGE" -lt "$MARKER_TTL_SECONDS" ]; then
    # Also verify nothing has been edited since the marker was written.
    NEWER=$(find "$PROJECT_ROOT/lib" "$PROJECT_ROOT/test" "$PROJECT_ROOT/functions/src" \
              -type f -newer "$MARKER" 2>/dev/null | head -1)
    if [ -z "$NEWER" ]; then
      echo "[pc-pre-push] ✓ recent pass-marker (${MARKER_AGE}s ago, no edits since) — allowing push." >&2
      exit 0
    fi
    echo "[pc-pre-push] marker found but files edited since — re-running gate." >&2
  fi
fi

# --- Run the static gate --------------------------------------------------

cd "$PROJECT_ROOT" || { echo "[pc-pre-push] cannot cd to $PROJECT_ROOT" >&2; exit 0; }

GATE_LOG="$(mktemp -t pc-gate.XXXXXX)"

# Step 1: gen-l10n (best-effort, only matters if .arb is in recent changes)
# Cheap so we just run it.
flutter gen-l10n >/dev/null 2>&1 || true

# Step 2: analyze
flutter analyze --no-pub > "$GATE_LOG" 2>&1
if grep -qE 'error • ' "$GATE_LOG"; then
  ERR_COUNT=$(grep -cE 'error • ' "$GATE_LOG")
  ERR_LINES=$(grep -E 'error • ' "$GATE_LOG" | head -5)
  REASON="[pc-pre-push] STATIC GATE FAILED — flutter analyze reports $ERR_COUNT error(s):\n\n$ERR_LINES\n\nRun /pc-phase --auto to investigate and auto-fix, then retry the push.\n\nTo bypass intentionally: git push --no-verify  OR  PC_SKIP=1 git push"
  # JSON-escape: newlines and quotes
  REASON_JSON=$(printf '%s' "$REASON" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo "\"$REASON\"")
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": $REASON_JSON
  }
}
EOF
  rm -f "$GATE_LOG"
  exit 0
fi

# Step 3: test (machine reporter so we can extract failure details)
TEST_JSON="$(mktemp -t pc-test.XXXXXX.json)"
flutter test --machine > "$TEST_JSON" 2>/dev/null

TEST_SUMMARY=$(python3 <<PYEOF
import json
events = []
with open("$TEST_JSON") as f:
    for line in f:
        try:
            obj = json.loads(line)
            if isinstance(obj, dict):
                events.append(obj)
        except json.JSONDecodeError:
            pass

# id -> name
tests = {}
for e in events:
    if e.get('type') == 'testStart':
        t = e.get('test', {})
        tests[t.get('id')] = t.get('name', '')

passed = failed = 0
fail_ids = []
for e in events:
    if e.get('type') == 'testDone':
        if e.get('result') == 'success':
            passed += 1
        elif e.get('result') == 'error':
            failed += 1
            fail_ids.append(e.get('testID'))

errs = {}
for e in events:
    if e.get('type') == 'error' and e.get('testID') in fail_ids:
        msg = (e.get('error') or '').strip().split('\n')[0]
        errs.setdefault(e.get('testID'), msg[:200])

if failed == 0:
    print(f"PASS:{passed}")
else:
    print(f"FAIL:{failed}/{passed+failed}")
    for tid in fail_ids[:5]:
        print(f"  • {tests.get(tid,'<unknown>')}")
        if tid in errs:
            print(f"    → {errs[tid]}")
    if len(fail_ids) > 5:
        print(f"  ... and {len(fail_ids)-5} more")
PYEOF
)

rm -f "$TEST_JSON"

if echo "$TEST_SUMMARY" | grep -q '^FAIL:'; then
  REASON="[pc-pre-push] STATIC GATE FAILED — tests failing:

$TEST_SUMMARY

Run /pc-phase --auto to investigate and auto-fix, then retry the push.

To bypass intentionally: git push --no-verify  OR  PC_SKIP=1 git push"
  REASON_JSON=$(printf '%s' "$REASON" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo "\"$REASON\"")
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": $REASON_JSON
  }
}
EOF
  rm -f "$GATE_LOG"
  exit 0
fi

# --- All green: write marker and allow ------------------------------------

touch "$MARKER"
echo "[pc-pre-push] ✓ static gate passed ($TEST_SUMMARY) — marker written, allowing push." >&2

rm -f "$GATE_LOG"
exit 0
