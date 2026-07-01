---
name: review-workflow
description: "Code review workflow: agent reviews → orchestrator edits the report with the user → fixers apply the approved items"
disable-model-invocation: true
---

You run the code review workflow. **You are the Orchestrator** — don't read skills or the internal implementation. Your job is to delegate to agents. Argument: $ARGUMENTS

## Step 1 — Code review

Launch the Agent tool with subagent_type: "code-reviewer". Pass the agent:
- A description of the changes for review: `$ARGUMENTS`
- A requirement to return, after the review report, structured context in the format:

```
=== REVIEW DONE ===
{full report in the format defined by the code-reviewer agent}

=== CONTEXT FOR FIXES ===
Changed files: <list with brief descriptions>
Dependent files: <files that use the changed code>
Backend / Frontend: <what belongs to the backend, what to the frontend>
```

**Keep with yourself (in the orchestrator):**
- The `agentId` returned by the agent (for later re-invocation)
- The entire `=== CONTEXT FOR FIXES ===` block
- The list of issues from the report with their numbers — maintain three buckets: **to fix**, **rejected**, **needs clarification**

Show the user the full review report.

Then ask: **"Review done. Which items do we reject or do you want to clarify with the reviewer?"**

Wait for the answer:
- If "launch" / "all good" — show the final plan and go to Step 3
- If they ask for clarifications or report edits — go to Step 2

## Step 2 — Editing the report

The orchestrator maintains a live list of issues. The user manages the buckets:
- "Don't fix item N — {reason}" → move to **rejected**, save the reason
- "Clarify item N" → use `SendMessage` with `to: agentId` (from Step 1), ask the reviewer a clarifying question, show the answer to the user
- "Lower the priority of item N" → move it from critical to remarks

*Fallback for SendMessage*: If the agent is unavailable — report: "⚠️ Reviewer unavailable, answering from the report context." and answer yourself based on the saved report.

After each change, show the current list: what's in **to fix**, what's in **rejected** (with reasons).

When the user says "launch":
- Show the final approved fix plan (the **to fix** bucket only)
- Wait for confirmation — go to Step 3

## Step 3 — Fixes

Determine from the final plan: are there backend fixes, frontend fixes, or both.

**If backend only** — launch one Agent tool with subagent_type: "backend-dev".

**If frontend only** — launch one Agent tool with subagent_type: "frontend-dev".

**If both and the frontend does not depend on the backend** — launch both agents in parallel in one message.

**If the frontend depends on the backend** (new endpoint, API contract change) — first backend-dev, then frontend-dev once it finishes.

Pass each agent:
- The saved `=== CONTEXT FOR FIXES ===` from Step 1 — so it doesn't re-read application code irrelevant to the task
- Only its part of the final fix plan: each item with the reviewer's original description. Don't pass rejected items at all.
