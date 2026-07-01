---
name: handoff
description: "Handing off the context of an implemented feature to another chat: gathers the context and outputs a ready block to copy-paste into /tests-workflow or /review-workflow"
disable-model-invocation: true
---

You produce a **handoff context** — a snapshot of what was implemented in this chat — and output it as a ready block right into the chat, so the user can copy it and paste it as an argument into a new chat (`/tests-workflow <block>` or `/review-workflow <block>`) without re-describing the task.

## Step 1 — Gathering context

Collect from the current chat and the repository:

1. **List of changes** — run `git status --short` and `git diff --stat` to get the exact list of changed/new files.

2. **Detailed context from the agents** (if this chat has active `backendAgentId` / `frontendAgentId` from feature-workflow):
   - Via `SendMessage`, ask each agent to return structured context for its part. For the backend agent request the format (if you don't already know it from their reports):
     ```
     Routes: <method, URL, middleware>
     Validation (FormRequest): <fields and rules>
     Authorization policies: <who can do what>
     JSON response structure (Resource): <fields>
     Factories: <created / existing>
     Notes: <softDelete, statuses, events, etc.>
     ```
   - *Fallback*: if the agents are unavailable — gather these details yourself from the git diff and the chat history.

3. If there are no active agents (handoff was invoked outside of feature-workflow) — gather everything from `git diff` and the chat context.

## Step 2 — Output the block into the chat

Output **one code block** into the chat (so the user can conveniently copy it whole). Format:

```
=== HANDOFF ===
Branch: <git branch> | HEAD: <short hash>

## What was implemented
<2-4 sentences: the essence of the feature and what was done>

## Changed files
### Backend
- path/to/file — what was changed
### Frontend
- path/to/file — what was changed

## Dependent files
<files that use the changed code and may be affected>

## Contract
Routes: <method, URL, middleware>
Validation (FormRequest): <fields and rules>
Authorization policies: <who can do what>
JSON response structure (Resource): <fields>
Factories: <created / existing>
Notes: <softDelete, statuses, events, etc.>
=== /HANDOFF ===
```

Fill in only the sections you have data for. Omit empty sections (for example "Frontend", if there was no frontend).

## Step 3 — Hint to the user

After the block, add one line:
```
Copy the block above and paste it into a new chat: /tests-workflow <block>  or  /review-workflow <block>
```
