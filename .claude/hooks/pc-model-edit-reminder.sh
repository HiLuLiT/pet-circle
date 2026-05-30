#!/usr/bin/env bash
# pc-model-edit-reminder.sh — PostToolUse hook
# Triggered when a file in lib/models/*.dart is edited.
# Prints a one-line reminder about copyWith / Firestore / tests.
# Non-blocking. Just a nudge, no enforcement.

set -uo pipefail

FILE_PATH="$(jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

# Only fire for Dart files in lib/models/
case "$FILE_PATH" in
  */lib/models/*.dart) ;;
  *) exit 0 ;;
esac

# Don't fire for the abstract base class or anything containing "test"
case "$FILE_PATH" in
  *_test.dart) exit 0 ;;
esac

MODEL_NAME="$(basename "$FILE_PATH" .dart)"

{
  echo ""
  echo "📝 [pc-model-edit] Edited $MODEL_NAME — quick checklist before /pc-phase:"
  echo "   • copyWith() updated for any new/changed fields"
  echo "   • toFirestore() includes new fields (with empty-omit for optional strings)"
  echo "   • fromFirestore() handles missing optional fields with defaults"
  echo "   • test/models/${MODEL_NAME}_test.dart covers new fields (roundtrip + copyWith)"
  echo ""
} >&2

exit 0
