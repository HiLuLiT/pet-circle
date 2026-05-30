---
name: pc-phase
description: Pet Circle phase-completion gate — runs gen-l10n + analyze + test, dispatches flutter-reviewer + code-reviewer + security-reviewer in parallel, auto-fixes HIGH findings via pc-issue-fixer, prompts on CRITICAL. Use after each phase of a multi-phase feature, or before opening a PR.
trigger: /pc-phase
---

# /pc-phase — Phase Completion Gate

Run this skill after finishing the code changes for a feature phase. It performs the same 8-step ritual you used to do manually across all 5 phases of the push-notifications feature, but in ~5 minutes instead of ~30.

## Usage

```
/pc-phase                            # full gate: gen-l10n + analyze + test + 3 reviewers + auto-fix HIGH
/pc-phase --phase "Phase 3 — Measurement Reminders"   # name the phase for reviewer context
/pc-phase --skip-reviewers           # quick mid-phase check: only gen-l10n + analyze + test
/pc-phase --no-autofix               # run reviewers but report only — no pc-issue-fixer dispatch
```

## What it does

1. **Pre-flight context** — `git status` + `git diff --stat HEAD` to understand the changeset.
2. **Localization sync** — Runs `flutter gen-l10n` only if `.arb` files are in the diff.
3. **Static checks** — `flutter analyze --no-pub` then `flutter test`. Fails the gate on `error • ` lines (warnings/infos tolerated to match CI policy).
4. **Parallel review** — Dispatches `flutter-reviewer`, `code-reviewer`, and `security-reviewer` in a single message (true parallelism).
5. **Aggregation** — Parses findings, deduplicates across reviewers, prints a summary table grouped by severity.
6. **Auto-fix HIGH** — Dispatches one `pc-issue-fixer` agent per HIGH finding in parallel. Re-runs analyze + test after.
7. **CRITICAL gate** — If any CRITICAL surfaces, STOP. Print findings and ask the user how to proceed.
8. **Verdict** — `✅ PHASE PASSED`, `⚠️ NEEDS REVIEW`, or `❌ BUILD BROKEN`.

---

## What You Must Do When Invoked

Follow these steps in order. Do not skip steps.

### Step 0 — Parse arguments

Read the user's invocation for these flags:

- `--phase "<name>"` — capture phase name (default: read from `.claude/plans/*.md` if a single plan exists, else empty)
- `--skip-reviewers` — set `SKIP_REVIEWERS=1`
- `--no-autofix` — set `NO_AUTOFIX=1`

Load configuration from `.claude/pc-config.yaml`:
- `analyze_command` (default `flutter analyze --no-pub`)
- `test_command` (default `flutter test`)
- `gen_l10n_command` (default `flutter gen-l10n`)
- `reviewers` (default the 3-list above)
- `severities_to_fix` (default `[HIGH]`)
- `severities_to_prompt` (default `[CRITICAL]`)

### Step 1 — Gather context

```bash
cd /Users/hilabb/repos/pet-circle && git status --short
cd /Users/hilabb/repos/pet-circle && git diff --stat HEAD
```

Capture: list of changed files. Print one line: `[/pc-phase] N files changed — proceeding`.

Identify what kind of changes are in scope:
- Any `.arb` file? → flag `arb_changed=true`
- Any `lib/models/*.dart`? → flag `model_changed=true`
- Any `functions/src/*.ts`? → flag `functions_changed=true`

### Step 2 — Localization sync (only if `arb_changed`)

```bash
cd /Users/hilabb/repos/pet-circle && flutter gen-l10n 2>&1
```

The "l10n.yaml exists, those options will be used" message is normal — only treat it as a failure if the exit code is non-zero.

If the regeneration produced changes to `lib/l10n/app_localizations*.dart`, those changes are intentional.

### Step 3 — Static checks (sequential, fail-fast)

```bash
cd /Users/hilabb/repos/pet-circle && flutter analyze --no-pub 2>&1 | tee /tmp/pc-analyze.out
```

If `/tmp/pc-analyze.out` contains a line matching `error • ` (note the bullet • U+2022), the gate fails with verdict `❌ BUILD BROKEN`. Print the error lines and STOP — do not run reviewers, do not auto-fix.

If only `warning • ` or `info • ` lines: continue.

Run the test suite with the machine reporter so failures can be parsed structurally — `tail -3` on the human reporter is unreliable because Flutter's test progress writes CR-overwritten lines that confuse grep/tail:

```bash
cd /Users/hilabb/repos/pet-circle && flutter test --machine 2>/dev/null > /tmp/pc-test.json
```

Then extract pass/fail counts and (if any failures) the names + first-line error of each failing test via a tiny Python script:

```bash
python3 <<'PYEOF'
import json
events = []
with open('/tmp/pc-test.json') as f:
    for line in f:
        try:
            obj = json.loads(line)
            if isinstance(obj, dict):
                events.append(obj)
        except json.JSONDecodeError:
            pass

# Build id → {name, path}
tests = {}
for e in events:
    if e.get('type') == 'testStart':
        t = e.get('test', {})
        url = t.get('url') or ''
        tests[t.get('id')] = {
            'name': t.get('name', ''),
            'path': url.replace('file://', '') if url else '<no-url>',
        }

# Find failures
passed = failed = 0
failures = []
for e in events:
    if e.get('type') == 'testDone':
        if e.get('result') == 'success':
            passed += 1
        elif e.get('result') == 'error':
            failed += 1
            failures.append(e.get('testID'))

# First-line error for each failure
errors = {}
for e in events:
    if e.get('type') == 'error' and e.get('testID') in failures:
        msg = (e.get('error') or '').strip().split('\n')[0]
        errors.setdefault(e.get('testID'), []).append(msg[:240])

print(f'Pass: {passed}')
print(f'Fail: {failed}')
for tid in failures:
    t = tests.get(tid, {})
    print(f'  • {t.get("name", "<unknown>")}')
    print(f'    {t.get("path", "<no-path>")}')
    for err in errors.get(tid, []):
        print(f'    → {err}')
PYEOF
```

If `Fail: 0` and `Pass: > 0`: verdict on this step is `✓ green`, proceed.

If `Fail: > 0`: verdict `❌ BUILD BROKEN`. Print the failures block and STOP.

Print: `[/pc-phase] analyze + test: ✓ green ({passed}/{passed+failed})`.

### Step 4 — Branch on `--skip-reviewers`

If `SKIP_REVIEWERS=1`: print `[/pc-phase] --skip-reviewers — gate complete (analyze + test only)` and exit. Final verdict: `✅ STATIC GATE PASSED`.

Otherwise, continue to Step 5.

### Step 5 — Dispatch the 3 reviewers IN PARALLEL

**This is the critical step.** Use the Agent tool with **three separate tool calls in a single response message** so they run truly in parallel. Sequential calls defeat the purpose.

Each agent gets this exact prompt (substitute `{phase}`, `{changed_files}`):

```
You are reviewing files changed in {phase} for the Pet Circle Flutter app.

Changed files:
{changed_files}

Repository: /Users/hilabb/repos/pet-circle
Branch: <current branch>

Project conventions you must respect:
- Models are immutable; mutations via copyWith()
- All user-visible strings go through AppLocalizations (en + he)
- ChangeNotifier stores in lib/stores/
- Services in lib/services/, abstract + concrete + web-stub pattern
- Colors via AppSemanticColors.of(context), never hardcoded hex
- Cloud Functions in functions/src/, Node 20 required

REPORT ONLY HIGH AND CRITICAL severity findings.
Skip LOW, INFO, and MEDIUM unless they cascade into a HIGH.

Output format — STRICT — one Markdown section per finding:

### [HIGH|CRITICAL] {one-line-title}
- File: {path}:{line}
- Description: {what's wrong, 1-3 sentences}
- Suggested fix: {minimal change to resolve, or "see description"}

If nothing of severity HIGH or CRITICAL: respond with exactly:

### Clean review

No HIGH or CRITICAL issues found.

Do not include preamble. Do not summarize. Do not editorialize.
```

The three Agent calls go to:
- `everything-claude-code:flutter-reviewer`
- `everything-claude-code:code-reviewer`
- `everything-claude-code:security-reviewer`

Each in **its own** Agent tool call **within the same response message**.

### Step 6 — Aggregate findings

For each reviewer's reply:
1. Split on `### [HIGH]` / `### [CRITICAL]` / `### Clean review` headers
2. Extract each finding into a structured object: `{severity, title, file, line, description, suggested_fix, reviewer}`
3. Deduplicate across reviewers: two findings are duplicates if `(file, line, severity)` match AND titles are >70% similar. Merge `reviewer` field as a list.

Print a consolidated summary table to the user:

```
[/pc-phase] Review aggregation:

| Severity | File:Line | Title | Reviewers |
|----------|-----------|-------|-----------|
| CRITICAL | ... | ... | ... |
| HIGH     | ... | ... | ... |
```

If all three returned `Clean review`: skip to Step 9 with verdict `✅ PHASE PASSED`.

### Step 7 — CRITICAL handling

If any CRITICAL findings exist:
1. Print the full CRITICAL findings (not just the table — include description + suggested fix)
2. STOP. Do not auto-fix. Do not proceed to Step 8.
3. Ask the user: "Found N CRITICAL issues. Auto-fix is disabled for CRITICAL severity. How should I proceed?"
4. Wait for direction.

### Step 8 — Auto-fix HIGH findings (unless `NO_AUTOFIX=1`)

For each HIGH finding, dispatch the `pc-issue-fixer` agent. Use **a single response message with N Agent tool calls** for true parallelism — do not dispatch them sequentially.

Each pc-issue-fixer call gets this prompt (substitute fields):

```
severity: HIGH
reviewer: {reviewer or "flutter-reviewer + code-reviewer" if multi}
file: {file}
line: {line}
description: {description}
suggested_fix: {suggested_fix}
phase: {phase}
```

After all pc-issue-fixer agents complete:

1. Collect each agent's structured reply
2. Re-run `flutter analyze --no-pub` and `flutter test`
3. If still failing: print which fix(es) likely caused the regression, ask user

If `NO_AUTOFIX=1`: print the HIGH findings in full, do not dispatch fixers. Verdict will be `⚠️ NEEDS REVIEW (manual fix required)`.

### Step 9 — Final verdict

Compute the verdict:

- `✅ PHASE PASSED` — analyze + test green AND no CRITICAL findings AND (HIGH count is 0 OR all HIGH fixes applied successfully)
- `⚠️ NEEDS REVIEW` — CRITICAL findings present OR HIGH fixes failed OR `--no-autofix` and HIGH findings remain
- `❌ BUILD BROKEN` — should have already exited at Step 3, but a re-verify failure here also counts

Print a final block:

```
═══════════════════════════════════════════
 /pc-phase — {verdict}
═══════════════════════════════════════════
Phase:      {phase or "(unnamed)"}
Files:      {N} changed
gen-l10n:   {ran/skipped}
analyze:    ✓ green
test:       {N}/{N} passed
Reviewers:  3 dispatched, {clean}/3 clean
Findings:   {N} HIGH ({M} auto-fixed), {K} CRITICAL
═══════════════════════════════════════════
```

Then offer the next action:
- If PASSED: suggest `git add . && git commit` or `/pc-phase` on the next phase
- If NEEDS REVIEW: list the unresolved findings and ask the user how to proceed

---

## Implementation notes (for the assistant running this skill)

- **Always call the 3 reviewers in ONE response message.** If you make 3 separate response turns, you've broken parallelism — the whole point of this skill.
- **Always call N pc-issue-fixers in ONE response message** for the same reason.
- **Use absolute paths** when shelling out (`cd /Users/hilabb/repos/pet-circle && ...`) so the working directory is unambiguous.
- **Do not invoke `/pc-phase` recursively.** If the user asks for it after a re-fix loop, they'll re-issue it themselves.
- **Honor the `--phase` arg in reviewer prompts** — it gives the reviewers context that improves their precision.
- **If a reviewer fails to respond or returns malformed Markdown:** treat that reviewer as "could not review" — don't crash the whole gate. Note it in the final summary.
- **Do not stage or commit anything automatically.** The skill ends at "ready for commit" — the user runs `git commit` themselves.

## When this skill is NOT a good fit

- **Mid-phase quick checks** — use `--skip-reviewers` instead, or just rely on the existing `flutter analyze` PostToolUse hook.
- **Refactor-only commits** — reviewers may still flag style. Use `--no-autofix` and review the findings yourself.
- **You haven't run the code in the emulator yet** — this skill checks static quality, not runtime behavior. Manual device testing is still needed for notification/Firebase flows.

## Related infrastructure (already exists, do not duplicate)

- `everything-claude-code:flutter-reviewer` — the Dart/Flutter reviewer this skill dispatches.
- `everything-claude-code:code-reviewer` — general code reviewer.
- `everything-claude-code:security-reviewer` — security reviewer.
- `.claude/agents/pc-issue-fixer.md` — the targeted HIGH-finding fixer this skill spawns in parallel.
- `.claude/agents/pc-l10n-syncer.md` — invoked indirectly via the PostToolUse l10n-parity hook; can also be called manually outside this skill.
- `.claude/hooks/pc-l10n-parity.sh` — auto-warns on app_en.arb edits about missing he keys.
- `.claude/hooks/pc-model-edit-reminder.sh` — nudges to update copyWith/Firestore/tests after model edits.
- `.claude/hooks/pc-node-20-pre.sh` — auto-injects Node 20 PATH for Cloud Functions builds.
- `.claude/pc-config.yaml` — configuration knobs.
