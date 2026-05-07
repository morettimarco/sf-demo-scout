# Showtime — Live Customer Conversation Sparring

Loaded on demand by `scout-sparring.md` when the SE selects the Showtime path at Stage 2. Returns to the main command for spec generation.

## When This Runs

The SE is in (or just after) a live customer conversation. The audit was run BEFORE the customer call (SE enablement — see World Tour briefing). The SE has a transcript ready to paste. Time budget: from transcript paste to spec ≤ 5 minutes of Scout work.

## Premise

- The transcript replaces the 6-question discovery round.
- The happy-path shortlist (`.claude/prompts/showtime-happy-paths.md`) constrains what Scout can propose. Scout cannot invent novel scenarios in Showtime — only patterns Scout has run end-to-end ≥3× cleanly.
- The value spine survives, but is auto-drafted silently and emitted inline with each scenario card. No SE-acknowledgement round, no gaps-as-questions.
- One iteration round only. After SE picks/sharpens, Scout writes the spec — no further loops.

## Step S1 — Confirm Audit State

The audit must already exist in `orgs/[alias]-[customer]/`. Check for `audit-*.md`.

**If audit exists and is ≤24 hours old:** read it, extract star-flagged items, proceed to S2.

**If audit is missing or stale:** emit:

> "Showtime expects the audit to be done before the customer call — that's the SE prep step. I can run the audit now if the customer is on a break (~5–10 min), or you can switch to `/scout-sparring` → New scenario for a full flow with embedded audit. Which?"

Wait for SE reply. If "run audit now" — read `.claude/prompts/sparring-audit-orchestration.md` and execute. If switch to New — return to main command Stage 3 with intent=new.

## Step S2 — Transcript Paste

Emit:

> "Paste the customer transcript. Multiple chunks fine — say `go` when done.
>
> Tip: if you don't have a transcript, paste your own notes from the conversation. Scout works on whatever signal you give it."

Wait. Concatenate chunks until SE says `go` (or equivalent: "done", "that's it", "ready"). Do not start extraction until the SE signals end.

## Step S3 — Auto-Extract (silent)

From the transcript, extract — do NOT emit yet:

- **Pain (KP1):** the customer's most-loaded statement, ideally a direct quote
- **Cost of Inaction (KP2):** what staying with the status quo costs them — only if the transcript contains it; otherwise leave empty (gap)
- **Future State (KP3):** the concrete outcome the customer named, with visible contrast to KP1
- **Audience:** which stakeholder's reaction matters most — usually the one who spoke most or whose decision unblocks the others
- **Residual Message:** one sentence the room remembers

Read `.claude/prompts/sparring-value-story.md` Drafting Rules for the spine constraints (one sentence per slot, contrast in KP3 must be visible, no vendor language, audience drives altitude). Do NOT execute its Output Format — Showtime emits the spine inline with scenarios in S4, not as a standalone message.

## Step S4 — Constrained Scenario Proposal

Read `.claude/prompts/showtime-happy-paths.md`. Match transcript signal + audit star items against the shortlist:

- **Tier 1 patterns** (LOW complexity, deploys cleanly) are the default proposal pool.
- **Tier 2 patterns** (MEDIUM, pre-staging required) are eligible only if the SE briefing confirmed pre-staging is done.
- Disqualified patterns are never proposed in Showtime.

Pick exactly **2 scenarios** from the shortlist that best match the transcript's pain + the org's audit star surface. If only 1 clean match exists, propose 1 + a "this is the one I'd back" framing — do not pad with weak second options.

Emit a single message:

> **Showtime — 2 scenarios for [Customer], grounded in your conversation.**
>
> **Spine** (drafted from your transcript):
> - **Residual Message:** [...]
> - **Audience:** [...]
> - **KP1 — Pain:** [direct quote if available]
> - **KP2 — Cost of Inaction:** [or "gap — not in transcript"]
> - **KP3 — Future State:** [contrast visible]
>
> ---
>
> **Scenario A — [Pattern name from shortlist]**
> Proves: KP[n], KP[n]
> Build: [one-line metadata footprint]
> Audit fit: [which star-flagged items it builds onto]
> Est. deploy time: [from shortlist]
>
> **Scenario B — [Pattern name from shortlist]**
> [same shape]
>
> ---
>
> **Out of Showtime scope but worth a follow-up session:** [optional — name 1 thing the transcript surfaced that doesn't fit the shortlist]
>
> Which one — A, B, or sharpen one of them in a single message?

## Step S5 — One Iteration Round

Wait for SE reply. Three valid replies:
- **A** or **B** (with no other input): proceed to S6 with that scenario.
- **A/B + edits** ("A but use Account instead of Lead"): apply edits to the chosen scenario. If the edit pushes the scenario outside the happy-path shortlist, refuse: "That edit takes us off the Tier 1/2 shortlist — for Showtime, I can either keep the scenario on-list, or you switch to `/scout-sparring` → New for a full sparring flow." Then proceed to S6.
- **Neither — propose something else**: politely refuse: "Showtime only proposes from the happy-path shortlist. The two above are the closest matches. If neither fits, switch to `/scout-sparring` → New scenario."

Do NOT loop further. One iteration, then spec.

## Step S6 — Data Shape Validation (conditional)

If the chosen scenario includes Apex, Flow, or Agentforce that queries or writes objects: read `.claude/prompts/sparring-data-shape.md` and execute. If pure config (fields, layouts, custom labels, seed only): skip.

## Step S7 — Spec Generation

Read `.claude/prompts/spec-template.md` and write the spec to `orgs/[alias]-[customer]/demo-spec-[YYYY-MM-DD]-[HHmm]-[CUSTOMER].md`.

Mark the spec header with `Sparring mode: Showtime` so /scout-building knows the provenance — useful for retros.

Skip the "Propose Lessons" step in main command Stage 7 — Showtime is too compressed for reliable lesson extraction. Lessons accumulate from regular sparring sessions.

## Step S8 — Done

Emit:

> "Spec saved. **Open a fresh Claude Code window** and run `/scout-building` — Showtime specs deploy the same way as any other spec.
>
> When the deploy lands, the SE in the room narrates Scout's progress to the customer. The org URL is the deliverable."

Return to main command (which exits cleanly since spec is on disk).

## What Showtime Does NOT Do

- Does NOT propose scenarios outside the happy-path shortlist.
- Does NOT run a value-spine acknowledgement gate (auto-drafted, emitted inline).
- Does NOT run the cut gate from Stage 6 (scope is already minimal by construction).
- Does NOT support iteration intent within Showtime (single-shot session).
- Does NOT do Slack lookup, broad doc research, or platform pre-flight beyond what the audit already captured.
- Does NOT pad. If only 1 scenario fits, propose 1.
