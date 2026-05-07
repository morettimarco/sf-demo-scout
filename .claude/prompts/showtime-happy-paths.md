# Showtime Happy-Path Shortlist

Pre-vetted scenarios Scout has run end-to-end on real demo orgs without surprise rollback. Loaded by `sparring-showtime.md` Step S4. Maintained by hand via /project-sparring sessions — not auto-updated.

## How to Read This File

Each pattern is a template, not a copy-paste scenario. The SE's transcript and the org's audit determine the specific objects, fields, and customer language. The pattern guarantees: "Scout knows how to deploy this shape cleanly."

**Tier 1** = LOW complexity, no SE pre-staging required beyond the audit.
**Tier 2** = MEDIUM complexity, requires SE pre-staging steps before the customer arrives.

Add to this file only after a pattern has deployed cleanly on ≥3 real orgs. Removing a pattern requires a /project-sparring session — patterns earn their place; demoting them is a deliberate decision.

---

## Tier 1 — Showtime-Ready

### T1.1 — Single Record-Triggered Flow + Custom Labels (Email Draft)
- **Proves:** Post-event automation generates a draft action in the activity timeline (rep edits + sends in seconds vs. composing manually)
- **Audit signals required:** target object exists (Visit / Case / Opportunity / custom event object), EmailMessage insertable, activity timeline component on layout
- **Build footprint:** 1 record-triggered flow + 1–2 Custom Labels (templated copy, often German/English) + permset
- **Est. deploy time:** 4–6 minutes
- **Source orgs:** Simon/Sartorius
- **Last validated:** 2026-04 (Sartorius, clean deploy)

### T1.2 — Account Hierarchy + Custom Lookup Fields + Layout
- **Proves:** Org structure + KOL/influencer relationships visible on a single Account record (optionally with ARC visualization in Health Cloud)
- **Audit signals required:** Account hierarchy active (Parent field used or addable), Contacts-to-Multiple-Accounts enabled, target Account layout exists
- **Build footprint:** 3–5 Account custom fields (Lookup to Contact) + layout edits + seed data + permset. No Apex, no flows.
- **Est. deploy time:** 5–8 minutes
- **Source orgs:** Simon/Ottobock
- **Last validated:** 2026-04 (Ottobock, clean deploy; CCR seeding skipped — B2B contact constraint, not blocker)
- **SE note:** German hospital names / departments need customization in seed data before demo.

### T1.3 — Cross-Cloud Activity Timeline (Trigger + Service Class)
- **Proves:** Service Cloud and Industry Cloud activities rendered together on one Account/Contact timeline — platform coherence story
- **Audit signals required:** custom activity object exists OR can be added, target object (Account/Contact) with active layout, existing flows on target object tolerated
- **Build footprint:** 1 Apex trigger + 1 service class + 1 picklist value + permset (with FLS)
- **Est. deploy time:** 7–10 minutes
- **Source orgs:** Fabian/Bionorica v1.3
- **Last validated:** 2026-04 (Bionorica, clean Apex deploy, 5 test methods 100% pass; Activity Timeline enablement is manual UI step — see SE pre-stage)
- **SE note:** Confirm Activity Timeline component is on the target layout BEFORE the customer call.

---

## Tier 2 — Showtime-Eligible with Pre-Staging

### T2.1 — Single Agentforce Agent (no Data Cloud dependency)
- **Proves:** Autonomous task assistance with explicit handoff path to a human rep
- **Audit signals required:** Agentforce permsets present in org (`AgentforceEmployeeAgentUser` / `AgentforceServiceAgentUser` / `AgentforceUser`), no conflicting active agent on the same scope
- **Build footprint:** 1 agent (.agent file) + 1–2 backing autolaunched flows + Companion permset + standard Agentforce runtime permset (auto-assigned by Phase 3)
- **Est. deploy time:** 12–18 minutes (Agentforce deploys last; ADLC skills are large)
- **Source orgs:** Fabian/QIAGEN (pattern, not full scenario)
- **Last validated:** 2026-04 (QIAGEN, clean deploy with knowledge stub workaround)
- **SE pre-stage required:**
  - Channel assignment for the agent (Messaging / Experience Cloud / Embedded)
  - Knowledge article published if scenario references knowledge lookup
  - Agent user renamed for credibility ("Aria" / "Marcus" — not "Einstein Agent User")
- **HARD CONSTRAINT — Showtime cannot use:**
  - Data Cloud / Data Library / Knowledge grounding (provisioning is out of Scout's scope)
  - Multi-agent orchestration
  - Production-scale test suite (single smoke test only in Showtime)

---

## Disqualified — Never Proposed in Showtime

- **Multi-flow + multi-agent + Prompt Template scenarios** — too many moving parts for a 90-min live build (e.g. Bionorica v1.2 was an iterative arc, not a single-shot scenario).
- **Matching Rules + Duplicate Rules via Metadata API** — platform limitation: no programmatic enum for fuzzy matching methods. These must be UI-only, breaking Scout's end-to-end deploy guarantee.
- **Agentforce + Data Cloud vector indexing + Data Library setup** — requires tenant provisioning Scout cannot execute.
- **Anything requiring Setup-UI navigation as load-bearing demo step** — Showtime sells "Scout deployed it"; if the demo moment depends on a step Scout couldn't deploy, the format breaks.

---

## Refinement Triggers

Add a pattern when:
- Same scenario shape deployed cleanly on ≥3 real orgs across ≥2 SEs
- Failure modes are known and the SE pre-stage list is complete
- A /project-sparring session reviews and approves the addition

Remove a pattern when:
- A platform change breaks the deploy reliability (e.g., Salesforce releases a new restriction)
- A new failure mode surfaces in field use that the pre-stage list can't reliably prevent
