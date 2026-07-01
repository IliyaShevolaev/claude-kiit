---
name: deep-review
description: "Deep review of a large feature/module: fans out backend security / performance / architecture lenses plus feature integration by default. Use --backend for backend-only review. Report-only — fixes are run separately."
disable-model-invocation: true
---

You run the deep review workflow. **You are the Orchestrator** — don't review yourself, delegate to the lens agents. Argument: $ARGUMENTS

`$ARGUMENTS` is the review scope — either a diff / list of commits, or a description of a feature/module to review.

Default mode is **full feature deep review**: three backend lenses plus one integration lens that checks whether the frontend matches the backend contract and the task.

If `$ARGUMENTS` contains `--backend`, run **backend-only mode**: remove `--backend` from the scope and launch only the three backend lenses.

This workflow only produces a report — it does not apply fixes (fixes are run separately afterwards).

## Step 1 — Fan out the lenses (parallel)

Determine the mode:
- **Default mode**: launch four Agent tool calls in parallel — `subagent_type: "security-reviewer"`, `"performance-reviewer"`, `"architecture-reviewer"`, `"feature-integration-reviewer"`.
- **`--backend` mode**: launch only three Agent tool calls in parallel — `subagent_type: "security-reviewer"`, `"performance-reviewer"`, `"architecture-reviewer"`.

Pass each launched agent:
- The review scope `$ARGUMENTS` after removing the optional `--backend` flag.
- A requirement to return its report in its own format (Critical / Remarks / Verdict with `file:line`).

For `feature-integration-reviewer`, additionally pass:
- "Review only task conformance and backend/frontend integration. Do not review layout polish or generic frontend style."

**Keep with yourself (in the orchestrator):**
- The launched `agentId`s (for clarifications).
- All launched reports.
- The selected mode: `default` or `backend-only`.

## Step 2 — Merge and present

Combine the launched reports into one:
- **Dedupe** overlapping findings (e.g. mass assignment flagged by both security and architecture → one entry, note both lenses).
- Group by severity (**Critical**, then **Remarks**); within each, tag the lens(es): `[security]`, `[performance]`, `[architecture]`, `[integration]` when that lens was launched.
- Keep `file:line` for every item.

Show the merged report.

Then ask: **"Deep review done. Want to clarify or drop any items, or is the report final?"**

Wait:
- "final" / "all good" — output the final merged report and finish.
- clarifications / edits — go to Step 3.

## Step 3 — Clarify / refine (no fixes)

- "Clarify item N" → `SendMessage` to the relevant lens `agentId`, ask, show the answer.
- "Drop item N — {reason}" → remove it from the report, note it was dismissed and why.
- "Lower priority of item N" → move critical → remarks.

*Fallback for SendMessage*: if the agent is unavailable — report: "⚠️ Lens unavailable, answering from the report context." and answer from the saved report.

After each change, show the updated report. When the user says "final" — output the final merged report and finish.

The deliverable is the report. Do not launch fixers — the user runs fixes separately.
