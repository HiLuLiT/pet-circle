# Pet Circle Automation

Quick reference for the project-local automation in `.claude/`. Everything
here was built to remove repetitive ritual around analyze + tests + code
review. If you're new (or returning after a break), start here.

---

## TL;DR

```
Edit code → hooks auto-fire on save (analyze, l10n parity, model nudge)
   ↓
git push → Layer 1: analyze + tests (~30s, automatic, blocks broken pushes)
   ↓
gh pr create → Layer 2: full review locally (~3–5min, blocks on CRITICAL)
   ↓
PR opens → Layer 3: same reviewers in CI, posts comment, blocks merge on issue
```

You usually don't invoke anything by hand. The hooks fire on the right
commands, and on failure they tell Claude exactly which skill to run.

---

## Layer overview

| Layer | Where | Trigger | What | Time |
|-------|-------|---------|------|------|
| **PostToolUse hooks** | Local | File edits | analyze, l10n parity, model nudges | <5s |
| **PreToolUse: `pc-node-20-pre.sh`** | Local | `npm`/`firebase deploy` in `functions/` | Inject Node 20 PATH | <1s |
| **Layer 1: `pc-pre-push.sh`** | Local | `git push` | `gen-l10n` + `analyze` + `test` | ~30s |
| **Layer 2: `pc-pr-create.sh`** | Local | `gh pr create`, `gh pr ready` | Require fresh full-review marker | <1s (gates) / ~3–5min (review) |
| **Layer 3: `pr-review.yml`** | GitHub CI | PR opened/sync | Same 3 reviewers, posts PR comment | ~3–5min (server-side) |

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
│   ├── pc-issue-fixer.md                 # parallel HIGH-finding fixer
│   └── pc-l10n-syncer.md                 # en/he ARB parity + Hebrew translation
│
├── hooks/
│   ├── pc-l10n-parity.sh                 # warns on missing he keys
│   ├── pc-model-edit-reminder.sh         # nudge after lib/models/*.dart edits
│   ├── pc-node-20-pre.sh                 # inject Node 20 PATH for functions/ + firebase
│   ├── pc-pre-push.sh                    # Layer 1 — static gate on git push
│   └── pc-pr-create.sh                   # Layer 2 — require full-review marker on gh pr create
│
└── AUTOMATION.md                         # this file

.github/workflows/
├── ci.yml                                # existing — flutter analyze + test on push/PR
└── pr-review.yml                         # Layer 3 — Claude reviewers on PR
```

---

## The `/pc-phase` skill

The orchestrator. Runs 1+2+3+auto-fix in one invocation:

```bash
/pc-phase                              # full gate: analyze + test + 3 reviewers + auto-fix HIGH
/pc-phase --skip-reviewers             # quick: only analyze + test (~30s)
/pc-phase --no-autofix                 # run reviewers but only report, don't fix
/pc-phase --auto                       # autonomous mode (used by hooks)
/pc-phase --phase "Phase 3 — name"     # tag the run with phase context
```

**`--auto` mode** is what the hooks invoke. It:
- Never prompts on CRITICAL — just reports + returns verdict `BLOCKED`
- On `PHASE PASSED`: writes two pass-markers (`/tmp/pc-gate-*.pass` for Layer 1, `/tmp/pc-review-*.pass` for Layer 2)
- Lets the autonomous retry loop work without user interaction

**You invoke it manually** when:
- You finished a phase of a multi-phase feature
- You want a quality check mid-stream
- A gate hook denied your action and told you to run it

**Claude invokes it autonomously** when:
- A gate hook denied a `git push` or `gh pr create` and the recovery hint pointed at this skill

---

## The hook-driven autonomous loop

This is the part that "just works" without you remembering anything.

```
1. Claude:   git push origin feat/X
2. Hook:     pc-pre-push.sh runs analyze + tests
3. Hook:     a test fails → DENY with "Run /pc-phase --auto to investigate"
4. Claude:   reads the deny, invokes /pc-phase --auto
5. Skill:    runs full gate, dispatches pc-issue-fixer on each HIGH (parallel)
6. Skill:    on PASS → writes /tmp/pc-gate-*.pass + /tmp/pc-review-*.pass
7. Claude:   retries git push
8. Hook:     marker is fresh → ALLOW
9. Push succeeds.
```

Same shape for `gh pr create`:

```
1. Claude:   gh pr create --title "..."
2. Hook:     pc-pr-create.sh checks /tmp/pc-review-*.pass marker
3. Hook:     no marker → DENY with "Run /pc-phase --auto first"
4. Claude:   /pc-phase --auto
5. Skill:    runs full review, fixes HIGHs, finds CRITICAL → BLOCKED, no marker
6. Skill:    reports CRITICAL to user
7. User:     fixes CRITICAL manually
8. User:     re-runs /pc-phase --auto → marker written
9. Claude:   retries gh pr create → hook allows → PR opens
```

---

## Bypass mechanisms

When you genuinely need to skip a gate (WIP, urgent hotfix, intentional):

| Bypass | Skips Layer 1 (push) | Skips Layer 2 (PR create) |
|--------|---------------------|---------------------------|
| `PC_SKIP=1 git push` | ✓ | n/a |
| `PC_SKIP=1 gh pr create ...` | n/a | ✓ |
| `git push --no-verify` | ✓ (if global block-no-verify isn't active) | n/a |
| `export PC_SKIP=1` then push | ✓ | ✓ |

**Layer 3 (CI) cannot be bypassed** — it's the canonical check. If something must merge despite Layer 3, do it via GitHub's "require admin override" or temporarily set the repository variable `ENABLE_CLAUDE_REVIEW=false`.

---

## Setup needed for full power

**Already works out of the box:**
- All PostToolUse + PreToolUse local hooks
- `/pc-phase` skill (uses Anthropic's API via your normal Claude Code session)
- Layer 1 (pc-pre-push.sh) and Layer 2 (pc-pr-create.sh) — pure shell

**Needs setup once:**
- **Layer 3 (GitHub Actions PR review)** — requires the `ANTHROPIC_API_KEY` secret:
  1. Get an API key from [console.anthropic.com](https://console.anthropic.com)
  2. Repo → Settings → Secrets and variables → Actions → New repository secret
  3. Name: `ANTHROPIC_API_KEY`, Value: your key
  4. Done. Every future PR triggers automatically.

Without that secret, Layer 3 still runs the static gate (analyze + test) and just posts a polite notice that the LLM review was skipped.

---

## How the markers work

`/pc-phase --auto` writes two timestamped marker files when it passes:

```
/tmp/pc-gate-<branch-hash>.pass     # written by both /pc-phase --auto and pc-pre-push.sh
/tmp/pc-review-<branch-hash>.pass   # written ONLY by /pc-phase --auto when reviewers ran
```

- `<branch-hash>` is a 12-char prefix of `sha1(current branch name)`
- Both markers have a TTL (10 min for static, 15 min for review) AND are invalidated when any source file under `lib/`, `test/`, or `functions/src/` is edited after the marker was written
- Used to short-circuit consecutive runs (push twice in 30 seconds → second push allowed instantly)

To force a re-run, delete the marker or edit any source file:
```bash
rm /tmp/pc-gate-*.pass /tmp/pc-review-*.pass
```

---

## Troubleshooting

**"My push is denied and I don't know why."**
The deny reason contains the failing analyze line or test name. If it
suggests `/pc-phase --auto`, run that — it will investigate and fix
automatically. Read the hook output carefully; it includes specific paths.

**"The hook is firing on a command it shouldn't."**
All hook scripts use specific regex matchers (e.g. `pc-pre-push.sh` only
fires on word-boundary `git push`). If you see false positives, the
matcher needs tightening — open the relevant `.sh` and adjust.

**"`flutter gen-l10n` is running too often."**
The PostToolUse hook only runs it when `app_he.arb` is edited. If it's
running constantly, something is repeatedly editing that file — check
which tool is writing it.

**"Layer 2 keeps denying even after I run /pc-phase --auto."**
The skill must complete with verdict `✅ PHASE PASSED` AND reviewers
must have actually run (not `--skip-reviewers`). The review marker is
only written under those conditions. Check the skill's final output.

**"I want to push without running tests for 30 minutes."**
```bash
export PC_SKIP=1
# now push as much as you want
unset PC_SKIP   # when done
```

**"The marker is stale but I just ran /pc-phase."**
Marker is invalidated if you edited any file in `lib/`, `test/`, or
`functions/src/` after `/pc-phase` finished. Re-run the skill — it's
designed to be fast on a green codebase (marker write + static gate ≈ 30s).

**"Where do hooks log their output?"**
Hook stderr surfaces in the Claude Code transcript as a system reminder.
For shell debugging, `bash -x .claude/hooks/pc-pre-push.sh < fixture.json`.

---

## Quick command cheat sheet

```bash
# Manual full review (e.g. before opening a PR if you're not relying on the hook)
/pc-phase

# Quick static check mid-feature
/pc-phase --skip-reviewers

# What's the state of my markers?
ls -la /tmp/pc-gate-*.pass /tmp/pc-review-*.pass 2>/dev/null

# Force a re-run of the gates by clearing markers
rm /tmp/pc-gate-*.pass /tmp/pc-review-*.pass 2>/dev/null

# Bypass any local gate for one command
PC_SKIP=1 git push
PC_SKIP=1 gh pr create --title "WIP - bypass"

# Run analyze + test the same way the gate does (for debugging)
flutter gen-l10n
flutter analyze --no-pub
flutter test --machine | python3 -c "import sys,json
events = [json.loads(l) for l in sys.stdin if l.strip().startswith('{')]
p=f=0
for e in events:
    if e.get('type')=='testDone':
        p += e.get('result')=='success'; f += e.get('result')=='error'
print(f'{p} pass, {f} fail')"

# Check Layer 3 secret status (from CLI)
gh secret list --repo HiLuLiT/pet-circle | grep ANTHROPIC_API_KEY
```

---

## Adding to the automation

If you want to add a new hook or skill, follow the existing pattern:

1. **Hook scripts** go in `.claude/hooks/`. Make them executable (`chmod +x`).
   Read tool input from stdin via `jq -r '.tool_input.command // empty'`.
   Exit 0 always (non-blocking) unless intentionally denying via the
   PreToolUse JSON contract.

2. **Wire the hook** in `.claude/settings.json`. Match on the right tool
   (`Bash`, `Edit|Write`, etc.) and order matters — earlier hooks fire first.

3. **New skills** go in `.claude/skills/<name>/SKILL.md` with the YAML
   frontmatter (`name`, `description`, `trigger`).

4. **New agents** go in `.claude/agents/<name>.md` with frontmatter
   (`name`, `description`, `tools`, `model`).

5. **Test before committing** — every hook should be testable by piping
   a JSON fixture to it: `echo '{"tool_input":{"command":"..."}}' | bash .claude/hooks/your.sh`.

6. **Update this file** if you change the architecture.

---

## Why this exists

Without these gates: every phase of a multi-phase feature took ~30 min
of manual orchestration overhead (dispatch 3 reviewers, read 3 reports,
fix HIGHs one by one, re-verify, repeat for the next phase). Across the
push-notifications feature that was ~1.5–2 hours of pure orchestration.

With these gates: zero. The reviewers fire when they need to fire, fixes
happen in parallel, markers prevent redundant work, and you focus on
writing code.

If a gate is more friction than it removes for you, **remove it** —
delete the hook entry from `settings.json` and the related script.
This is project-local infrastructure, fully under your control.
