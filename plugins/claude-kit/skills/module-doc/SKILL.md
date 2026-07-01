---
name: module-doc
description: "Creating and updating a module's domain documentation for AI agents. Argument: module name + free-form description. Example: 'posts Posts are added to the system, they have documents and comments...'"
---

You create and update compact documentation on the project's domains for use by AI agents.

## Language

Write documentation in the project's documentation language (see CLAUDE.md; default: the language existing domain docs are written in). This includes all section content, business rules, notes, and any descriptive text. Only code identifiers (class names, enum values, file paths) remain in their original form.

## Core principle

**Document only what isn't in the code.**

An agent can read the model, service, routes, policy — and see the fields, methods, relationships there. Writing that in a doc means creating a duplicate that will go stale.

A doc should only contain what **can't be pulled** from the code:
- the status flow (transitions between statuses, not the enum values themselves)
- business rules and constraints (who can do what, under which conditions)
- non-obvious side effects (what happens on a status change, on deleting a record)
- domain context (why this exists at all)

If a section comes out empty — **don't write it**.

## Do-not-document list: do NOT write this

- The list of a model's fields — the agent reads the model
- The list of a service's methods — the agent reads the service
- Route URLs — the agent reads routes/api.php
- Relationship types (hasMany, belongsTo) — the agent reads the model
- Tech stack, architecture patterns — that's in the agents

## Documentation is a snapshot of the current state, not a changelog

The documentation describes the system **as it works now** and is the single source of truth. Versioning, change history, and comparisons with past behavior don't belong in it.

Phrasings like "now … instead of …", "no longer …", "it used to be …", "the former … was removed", "X became Y", "X, not Y" are forbidden. Even when updating an existing file for a new feature — don't describe the difference from the old version, but **rewrite the section as if the current behavior had always been the case**.

## File location

`.claude/docs/domains/{module-name}.md` (kebab-case)

## Modes

**New document** (the file doesn't exist):
1. Find the domain's key classes (models, enums, services) — only to confirm the exact names
2. If the user's description lacks the business rules needed for important sections — ask clarifying questions before writing
3. Write the file

**Update** (the file exists):
1. Read the existing file
2. Integrate the new information into the relevant sections — not at the end of the file
3. Remove the obsolete content if the user explicitly indicated it
4. Rewrite the sections for the current state — without "was/now became" (see "Documentation is a snapshot of the current state")
5. Rewrite the file

## Template

A ready-to-copy template lives at `${CLAUDE_PLUGIN_ROOT}/templates/doc-templates/`. The default shape:

```md
# {Module}

## Overview
{1-2 sentences: what it is and why it exists in the system}

## Statuses *(skip if none)*
`status1 → status2 → status3`
Enum: `App\Enums\...\...Enum`
{Only if there are non-obvious transition conditions — state them}

## Business rules
- {rule}
- {rule}

## Notes *(skip if nothing to write)*
- {non-obvious side effect, constraint, historical decision}

## Entry points
Backend: `app/Http/Controllers/{...}/{...}Controller.php`
Frontend: `resources/js/pages/{...}/index.vue`
```

Before saving, go through each line: **"would an agent not find this in the code at first glance?"** If it would — delete it. The size is determined by the domain's complexity, not by a quota.

## Entry points — a mandatory section

At the end of each document, list the entry points into the module — the files an agent will start its traversal from and find everything else through imports:
- **Backend:** the controller (`app/Http/Controllers/...`) — find it via Grep by the module name
- **Frontend:** the index page (`resources/js/pages/.../index.vue`) — find it via Grep by the module name

If the module has several controllers or several pages — list them all. If there's no frontend or backend yet — skip the corresponding line.

## After creating the file

Check whether there's a link to the file in `CLAUDE.md` in the domain documentation section. If not — add the line:
`- [Module](docs/domains/{module-name}.md)`

If the project maintains a documentation index (e.g. a honkit/GitBook `SUMMARY.md`, configurable via CLAUDE.md), also add the entry there.
