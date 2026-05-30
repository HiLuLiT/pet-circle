# Pet Circle Automation

Quick reference for the project-local automation in `.claude/`. If you're new
(or returning after a break), start here.

---

## TL;DR

```
Edit code → hooks auto-fire on save (analyze, l10n parity, model nudge)
   ↓
git push  → pre-push gate: analyze + tests (~30s, automatic, blocks broken pushes)
   ↓
When ready for PR → you run /pc-phase manually (full review with auto-fix)
   ↓
gh pr create → opens PR (existing CI runs flutter analyze + test)
```

Two automatic things (save-hooks and pre-push gate) and one manual thing
(`/pc-phase` when you're ready for the deeper review). That's the whole flow.

---

## What runs automatically

| When | What | Where | Time |
|------|------|-------|------|
| File edit | `flutter analyze` on `.dart` files | PostToolUse hook | <5s |
| Edit `app_en.arb` | Warn about missing keys in `app_he.arb` | PostToolUse hook | <1s |
| Edit `app_he.arb` | Auto-run `flutter gen-l10n` | PostToolUse hook | ~3s |
| Edit `lib/models/*.dart` | Print copyWith/Firestore/test checklist | PostToolUse hook | <1s |
| `npm`/`firebase deploy` in `functions/` | Inject Node 20 PATH | PreToolUse hook | <1s |
| `git push` | Run `gen-l10n` + analyze + tests, block on failure | PreToolUse hook | ~30s |

## What you trigger manually

| When | What | Time |
|------|------|------|
| You're ready for PR or deep check | `/pc-phase` — full review with 3 reviewers + auto-fix HIGHs | ~3–5min |
| Quick mid-feature sanity check | `/pc-phase --skip-reviewers` — just analyze + tests | ~30s |

## What runs in CI

Whatever was there before — `.github/workflows/ci.yml` runs
`flutter analyze` + `flutter test` on every push and PR. No new CI added.

---

## Files

```
.claude/
├── pc-config.yaml                        # knobs (locales, commands, severities)
├── settings.json                         # wires all hooks
│
├── skills/
│   └── pc-phase/
│       └── SKILL.md                      # /pc-phase orchestrator
│
├── agents/
│   ├── pc-issue-fixer.md                 # parallel HIGH-finding fixer (spawned by /pc-phase)
│   └── pc-l10n-syncer.md                 # en/he ARB parity + Hebrew translation
│
├── hooks/
│   ├── pc-l10n-parity.sh                 # warns on missing he keys
│   ├── pc-model-edit-reminder.sh         # nudge after lib/models/*.dart edits
│   ├── pc-node-20-pre.sh                 # inject Node 20 PATH for functions/ + firebase
│   └── pc-pre-push.sh                    # analyze + tests on git push
│
└── AUTOMATION.md                         # this file
```

---

## The `/pc-phase` skill

The orchestrator. Run it manually when you're ready for the full review:

```bash
/pc-phase                              # full gate: analyze + test + 3 reviewers + auto-fix HIGH
/pc-phase --skip-reviewers             # quick: only analyze + test (~30s)
/pc-phase --no-autofix                 # run reviewers but report only, don't fix
/pc-phase --auto                       # autonomous mode (used by pre-push hook on failure)
/pc-phase --phase "Phase 3 — name"     # tag the run with phase context for reviewers
```

**When to run it:**
- ✅ Finished a feature, about to push and open a PR
- ✅ Want a quality check mid-feature
- ✅ The pre-push hook denied your push and told you to run it

**What it does:**
1. `gen-l10n` if any `.arb` was edited
2. `flutter analyze` (fail-fast on errors)
3. `flutter test` (parses machine output for failures + their messages)
4. Dispatches **3 reviewers in parallel** — `flutter-reviewer`, `code-reviewer`, `security-reviewer`
5. Aggregates findings, deduplicates across reviewers
6. **Auto-fixes HIGH findings** by dispatching N `pc-issue-fixer` agents in parallel
7. On **CRITICAL** findings: stops and asks you (CRITICAL = security/data-loss, never auto-fixed silently)
8. Final verdict: `✅ PHASE PASSED`, `⚠️ NEEDS REVIEW`, or `❌ BUILD BROKEN`

---

## The pre-push gate (the only automatic gate)

Hook: `.claude/hooks/pc-pre-push.sh` (PreToolUse on Bash matching `git push`)

What it runs:
1. `flutter gen-l10n` (silent)
2. `flutter analyze --no-pub`
3. `flutter test --machine` (parses failure names + first-line errors)

**On green:** writes `/tmp/pc-gate-<branch-hash>.pass` marker, allows push.

**On failure:** denies the push with structured output telling Claude:
- exactly which test/analyze line broke it
- to run `/pc-phase --auto` to investigate + fix

If Claude is in the loop, this becomes the autonomous-recovery loop:

```
1. Claude:   git push
2. Hook:     test X failing → DENY
3. Claude:   /pc-phase --auto
4. Skill:    runs full gate, dispatches pc-issue-fixer per HIGH (parallel)
5. Skill:    on PASS → writes /tmp/pc-gate-*.pass marker
6. Claude:   retries git push
7. Hook:     marker fresh → ALLOW
```

If you're pushing manually (from your terminal, no Claude), the hook still
denies and tells you what broke; you fix it and re-push.

**Marker semantics:** 10-min TTL, invalidated if any file in `lib/`, `test/`,
or `functions/src/` was edited after the marker was written. Two pushes
within seconds of each other won't re-run the full gate; pushes after a
real edit will.

---

## Bypass mechanisms

When you genuinely need to skip the pre-push gate:

```bash
PC_SKIP=1 git push          # project-specific escape hatch
export PC_SKIP=1            # bypass for the whole shell session
unset PC_SKIP               # re-enable
```

`git push --no-verify` would also work in theory but the Claude harness
blocks `--no-verify` at a higher level, so `PC_SKIP=1` is the real escape.

---

## Setup needed

**Nothing.** Everything works out of the box:
- All hooks fire automatically based on `.claude/settings.json` (which is checked in)
- `/pc-phase` uses your existing Claude Code session — no API key, no GitHub secrets

CI in `.github/workflows/ci.yml` is whatever you already had before this
automation work — `flutter analyze` + `flutter test` on every PR. Not touched.

---

## Troubleshooting

**"My push is denied and I don't know why."**
The deny output includes the failing analyze line or test name + first-line
error. If it suggests `/pc-phase --auto`, just run that.

**"`flutter gen-l10n` is running too often."**
The PostToolUse hook only runs it when `app_he.arb` is edited. If you see
it constantly, something is repeatedly editing that file.

**"I want to push without checks for 30 minutes."**
```bash
export PC_SKIP=1
# push freely
unset PC_SKIP
```

**"The marker exists but I just edited a file — will the next push re-run?"**
Yes. The hook checks `find lib test functions/src -newer <marker>` and
invalidates if anything is newer.

**"Where do hooks log their output?"**
Hook stderr surfaces in the Claude Code transcript. For shell debugging:
```bash
echo '{"tool_input":{"command":"git push"}}' | bash .claude/hooks/pc-pre-push.sh
```

---

## Quick command cheat sheet

```bash
# Manual full review (run before opening a PR)
/pc-phase

# Quick static check
/pc-phase --skip-reviewers

# What's the state of my marker?
ls -la /tmp/pc-gate-*.pass 2>/dev/null

# Force re-run of the pre-push gate
rm /tmp/pc-gate-*.pass 2>/dev/null

# Bypass pre-push gate
PC_SKIP=1 git push

# Run the same checks the gate does (for debugging)
flutter gen-l10n
flutter analyze --no-pub
flutter test
```

---

## Adding to the automation

1. **New hook scripts** → `.claude/hooks/`. Make executable. Read stdin via
   `jq -r '.tool_input.command // empty'` or `.tool_input.file_path`.
   Exit 0 unless intentionally denying via PreToolUse JSON contract.
2. **Wire the hook** in `.claude/settings.json`. Order matters.
3. **New skills** → `.claude/skills/<name>/SKILL.md` with YAML frontmatter.
4. **New agents** → `.claude/agents/<name>.md` with frontmatter.
5. **Update this file** when you change the architecture.

---

## Why this exists

Manual orchestration (dispatching reviewers, reading reports, fixing HIGHs
serially, re-verifying) used to take ~30 min per feature phase. Across a
5-phase feature that was ~2 hours of pure ritual.

The pre-push gate catches the boring stuff (broken builds, failing tests)
automatically. `/pc-phase` consolidates the rest into one command. The
manual trigger is deliberate — code review is the moment to **decide**
"this is ready," and that decision belongs to you, not a hook.
