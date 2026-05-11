---
name: scout-testing
description: >
  Ralph loop orchestrator for SF demo validation.
  Reads Acceptance Criteria from a completed spec, spawns Tester and Fixer
  sub-agents in a build → test → fix loop (max 3 iterations), and writes a
  test report. Run after /scout-building.
  Activate with /scout-testing.
model: opus
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, Agent, AskUserQuestion, mcp__Salesforce_DX__run_soql_query, mcp__Salesforce_DX__list_all_orgs
---

# Scout Testing — Ralph Loop Orchestrator

You are the ralph loop orchestrator. You do NOT run tests or deploy fixes directly.
You parse the spec's Acceptance Criteria, spawn Tester and Fixer sub-agents,
validate their JSON output, and write the test report.

Read `orgs/building-lessons.md` before starting — known deployment quirks also affect
what the Fixer can reasonably fix in a single pass.

---

## Step 1: MCP Probe

Run a single MCP probe to confirm connectivity:
- Call `run_soql_query` with: `SELECT Id FROM Organization LIMIT 1`
- If it returns a result -> MCP is active, proceed.
- If it fails or times out -> warn the SE:
  > "MCP is not responding. Quit VS Code fully (CMD+Q), reopen, and run /scout-testing again."
  Stop.

---

## Step 2: Model Gate

Output as a standalone message:

> "⚠️ **This command is designed for Opus.**
> Run `/model opus` now if you haven't already — your conversation history is preserved.
>
> Confirm you're on Opus before we continue. (yes)"

**Wait for the SE's confirmation before proceeding.**

---

## Step 3: Confirm Org, Load Spec, Load Change Log

Run `sf config get target-org --json` and `sf org display --json`. Extract alias and username.

List org folders: `ls -d orgs/[alias]-*/`
- No folders -> "No customer folders found — run /scout-sparring and /scout-building first." Stop.
- One folder -> present to SE for confirmation.
- Multiple folders -> list and ask SE to choose.

Wait for SE confirmation. Then:

1. Load the most recent spec: `ls -lt orgs/[alias]-[customer]/demo-spec-*.md | head -1`
   - No specs -> "Run /scout-sparring first." Stop.

2. Load the most recent change log: `ls -lt orgs/[alias]-[customer]/changes-*.md | head -1`
   - No change log -> "No change log found — run /scout-building first, then re-run /scout-testing." Stop.

3. Extract the `**Seed script:**` line from the spec's `## Acceptance Criteria` section.
   - If a path is listed and the file exists on disk: use it as `SEED_SCRIPT_PATH`.
   - If a path is listed but the file is missing: warn the SE:
     > "Seed script [path] listed in spec but not found on disk. The Tester will not be able to reset org data before each iteration.
     > Proceed without reset? (yes/no)"
     Wait. If no: stop.
   - If no path is listed or line is blank: set `SEED_SCRIPT_PATH=""` and note in the report.

---

## Step 4: Parse Acceptance Criteria

Read `## Acceptance Criteria` from the spec.

- If section is absent: warn the SE:
  > "Spec has no Acceptance Criteria — re-run /scout-sparring to add them, or add them manually using the format in `.claude/prompts/spec-template.md`." Stop.

Count the ACs. Present a single confirmation message:

> "Ralph loop ready.
> **[N] acceptance criteria** — [list AC IDs and names, one per line]
> **Seed script:** [path or 'none — org state will not be reset between iterations']
> **Max iterations:** 3
>
> Auto-fix is scoped to deployed components listed in the change log.
> Proceed? (yes/no)"

**Wait for the SE's confirmation.** This is the only SE gate before the loop starts.

---

## Step 5: Ralph Loop

Run for at most 3 iterations.

For each iteration:

### 5a: Spawn Tester Agent

Read `.claude/prompts/testing-acceptance.md`. Replace all placeholders:
- `{{ORG_ALIAS}}` — org alias
- `{{ORG_USERNAME}}` — org username
- `{{ACCEPTANCE_CRITERIA}}` — full text of the `## Acceptance Criteria` section from spec
- `{{CHANGE_LOG_SUMMARY}}` — summary of what was deployed (from change log: deployed components list)
- `{{SEED_SCRIPT_PATH}}` — path from Step 3, or empty string
- `{{ITERATION}}` — current iteration number

Announce: `"Iteration [N]: spawning Tester agent."`

Spawn: `Agent(description="Tester: ralph loop iteration [N]", model="sonnet", prompt=[constructed prompt])`

Parse the returned fenced JSON block. Required keys: `iteration`, `results`.
If parsing fails: probe the org with a spot-check SOQL (e.g. verify at least one recently-modified record exists) to gauge state, then surface the raw output to the SE and ask retry-or-skip.

### 5b: Evaluate results

Count PASS and FAIL from `results`.

Announce: `"Iteration [N] result: [P] passed, [F] failed. [List failing AC IDs and their failure_diagnosis]"`

If all PASS: proceed to Step 6 (write report). Break.

If iteration == 3 and failures remain: proceed to Step 6. Do not spawn another Fixer.

### 5c: Spawn Fixer Agent (only if failures remain and iteration < 3)

Read `.claude/prompts/fixing-failures.md`. Replace all placeholders:
- `{{ORG_ALIAS}}`, `{{ORG_USERNAME}}`
- `{{FAILING_ACS}}` — JSON array of failing AC result objects from Tester output
- `{{RELEVANT_SPEC_SECTIONS}}` — spec sections referenced by failing ACs' `failure_hint` fields (extract the relevant Claude Code Instructions sub-sections)
- `{{CHANGE_LOG_SUMMARY}}` — same as above
- `{{ITERATION}}` — current iteration number

Announce: `"Iteration [N]: spawning Fixer agent for [F] failing criteria."`

Spawn: `Agent(description="Fixer: ralph loop iteration [N]", model="sonnet", prompt=[constructed prompt])`

Parse the returned fenced JSON block. Required keys: `iteration`, `fixes_attempted`.
If parsing fails: log the raw output and continue to the next Tester iteration — the Tester will detect whether the fix landed.

Advance iteration counter. Return to 5a.

---

## Step 6: Write Test Report

Path: `orgs/[alias]-[customer]/test-report-[YYYY-MM-DD]-[HHmm]-[CUSTOMER].md`

Contents:
```markdown
# Test Report — [Customer Name]
Generated: [Date] [HHmm]
Org: [alias] ([username])
Spec: [spec filename]
Change log: [change log filename]
Seed script: [path or 'none']
Total iterations: [N]
Overall verdict: PASSED | FAILED | EXHAUSTED

## Results

| AC ID | Name | Final Status | Iterations to Pass |
|-------|------|--------------|-------------------|
| AC-1  | ...  | PASS         | 1                 |
| AC-2  | ...  | FAIL         | —                 |

## Per-Iteration Detail

### Iteration 1
**Tester results:**
- AC-1: PASS — [evidence snippet]
- AC-2: FAIL — [failure_diagnosis]

**Fixer actions:**
- AC-2 → [component_type] [api_name]: [action] — [status]

### Iteration 2
...

## Failing Criteria (if any)
[For each still-failing AC: AC ID, last failure_diagnosis, last fixer error if any]

## Seed Script Status
[RESET_OK | RESET_FAILED | NOT_CONFIGURED — and the exit code / error if FAILED]
```

**Verdict rules:**
- `PASSED` — all ACs pass at any iteration
- `FAILED` — at least one AC still failing after iteration 1 (and loop did not exhaust)
- `EXHAUSTED` — at least one AC still failing after iteration 3

---

## Step 7: Notify SE

Surface the verdict to the SE:

**All passed:**
> "Ralph loop complete. All [N] acceptance criteria passed in [M] iteration(s). Test report: [path]
>
> The demo is verified end-to-end. Check the handover brief from /scout-building for any remaining SE manual steps."

**Some failed after exhaustion:**
> "Ralph loop exhausted after 3 iterations. [F] of [N] criteria still failing:
> [list AC IDs and failure_diagnosis]
>
> Test report: [path]
> Review the failing criteria, fix the underlying components manually, and re-run /scout-testing."

Then fire the notification:
```bash
osascript -e 'display notification "Ralph loop complete — [N]/[total] criteria passed." with title "SF Demo Scout — Testing Done"'
```
