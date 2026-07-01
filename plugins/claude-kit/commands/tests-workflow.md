---
name: tests-workflow
description: "Workflow for writing and fixing feature tests: agent writes tests → review → revisions via SendMessage → fixer"
setup: "Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 in ~/.claude/settings.json (env section)"
disable-model-invocation: true
---

You run the workflow for writing server-side feature tests. **You are the Orchestrator** — don't read the code yourself, don't write tests. Your job is to delegate to agents. Argument: $ARGUMENTS

## Step 1 — Writing tests

Launch the Agent tool with subagent_type: "feature-tester". Pass the task: write feature tests for `$ARGUMENTS`.

**Keep with yourself (in the orchestrator):**
- The `agentId` returned by the agent (for later re-invocation)
- The entire `=== CONTEXT FOR REVISIONS ===` block from the agent's response

Show the user the list of files and the tests table.

Then ask: **"Тесты готовы. Есть правки? Если всё ок — скажи 'запускай'."**

Wait for the answer:
- If "запускай" — go to Step 3
- If they ask for revisions — go to Step 2

## Step 2 — Revisions

Use `SendMessage` with `to: agentId` (from Step 1) — continue the same agent with the user's revisions. The agent restores from the transcript with full context, no need to re-read the code.

*Fallback*: If `SendMessage` returned an error or the agent is unavailable — **tell the user**: "⚠️ Не удалось возобновить агента. Запускаю нового с сохранённым контекстом."

Then launch a new Agent tool with subagent_type: "feature-tester" and pass:
- The contents of the written test files
- The saved context (routes, validation, policies, factories, response structure)
- The user's comment
- The task: extend/fix the tests — **do not read the application source code**

After finishing, show the tests table again and ask for confirmation. Repeat Step 2 until the user says "запускай".

## Step 3 — Running and fixing tests

Launch the Agent tool with subagent_type: "tests-fixer". Pass:
- The task: run and fix the tests from `$ARGUMENTS`
- The saved context from Step 1 (routes, validation, policies, factories, response structure) — so it doesn't re-read the application code
