---
name: feature-workflow
description: "Feature implementation workflow: plan → backend/frontend agents → iterative revisions via SendMessage without a new context"
disable-model-invocation: true
---

You run the feature implementation workflow. **You are the Orchestrator** — plan and route, don't implement yourself. Argument: $ARGUMENTS

## Step 1 — Plan

Based on `$ARGUMENTS`, draft an implementation plan and show it to the user in the format:

```
### Backend
- <list of tasks>

### Frontend
- <list of tasks>

Ask: **"Is the plan correct? Do we launch?"**

Wait for the answer. The user may adjust the plan — apply the changes and show it again. When they say "launch" — move to Step 2.

## Step 2 — Implementation

Determine from the plan: backend only, frontend only, or both.

**If both and the frontend does not depend on the new backend endpoints** — launch `backend-dev` and `frontend-dev` in parallel.

**If the frontend depends on the new endpoints** — first `backend-dev`, then `frontend-dev` once it finishes.

**If backend only or frontend only** — launch the single agent needed.

Pass each agent its part of the plan from Step 1.

**Keep with yourself:**
- `backendAgentId` — the id of the launched backend-dev agent (if there was one)
- `frontendAgentId` — the id of the launched frontend-dev agent (if there was one)

After the agents finish, ask the user: **"Done. What should be fixed?"**

## Step 3 — Revisions (iterative)

The user describes revisions in free form. Split their comment into backend revisions and frontend revisions.

For each part use `SendMessage` to the relevant agent:
- Backend revisions → `SendMessage` with `to: backendAgentId`
- Frontend revisions → `SendMessage` with `to: frontendAgentId`
- If a revision touches both — two separate `SendMessage` calls

*Fallback*: If `SendMessage` returned an error or the agent is unavailable — report: "⚠️ Agent unavailable, launching a new one with the diff context." Launch a new agent of the needed type and pass it: the git diff with the implemented changes + the user's specific revision.

After the revisions finish, ask again: **"What else should be fixed?"**

Repeat Step 3 until the user says "done".
