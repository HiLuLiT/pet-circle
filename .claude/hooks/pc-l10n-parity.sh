#!/usr/bin/env bash
# pc-l10n-parity.sh — PostToolUse hook
# Triggered when lib/l10n/app_en.arb is edited.
# Compares keys against app_he.arb and warns about missing keys.
# Non-blocking: always exits 0 so it never breaks Claude Code.
#
# Input (from Claude Code): a JSON object on stdin with tool_input.file_path
# Output: optional message on stderr (Claude Code surfaces hook stderr to user)

set -uo pipefail

PROJECT_ROOT="/Users/hilabb/repos/pet-circle"
EN="$PROJECT_ROOT/lib/l10n/app_en.arb"
HE="$PROJECT_ROOT/lib/l10n/app_he.arb"

# Read the file path the tool wrote to
FILE_PATH="$(jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

# Only fire when app_en.arb itself was the edit target
case "$FILE_PATH" in
  *lib/l10n/app_en.arb) ;;
  *) exit 0 ;;
esac

# Sanity: both files must exist
[ -f "$EN" ] && [ -f "$HE" ] || exit 0

# Extract top-level keys from each (excludes @@locale and @-metadata)
# jq -r 'keys[]' returns one key per line.
EN_KEYS="$(jq -r 'keys[] | select(startswith("@") | not) | select(. != "@@locale")' "$EN" 2>/dev/null || echo "")"
HE_KEYS="$(jq -r 'keys[] | select(startswith("@") | not) | select(. != "@@locale")' "$HE" 2>/dev/null || echo "")"

# Find keys in en but not in he
MISSING="$(comm -23 <(echo "$EN_KEYS" | sort) <(echo "$HE_KEYS" | sort))"

if [ -n "$MISSING" ]; then
  COUNT="$(echo "$MISSING" | wc -l | tr -d ' ')"
  {
    echo ""
    echo "⚠️  [pc-l10n-parity] $COUNT key(s) in app_en.arb missing from app_he.arb:"
    echo "$MISSING" | sed 's/^/    - /'
    echo ""
    echo "   Run the pc-l10n-syncer agent to auto-translate, or edit app_he.arb manually,"
    echo "   then run \`flutter gen-l10n\`."
    echo ""
  } >&2
fi

exit 0
