---
description: "First-run project setup: explore the Laravel + Vue codebase with two Explore agents, then write the two project-truth skills (backend-utilities-knowledge + frontend-utilities-knowledge, each SKILL.md + references/crud-examples.md) and a tuned .claude/CLAUDE.md."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task
---

You are running the **claude-kit first-run setup** for the current project.

The kit's agents and skills are portable 1:1 — the `*-conventions-knowledge` and `*-crud-flow-knowledge` skills and every agent stay generic and are **never edited by setup**. All project-specific truth lives in exactly **two skill folders**, and your whole job is to fill them:

- `.claude/skills/backend-utilities-knowledge/` — `SKILL.md` + `references/crud-examples.md`
- `.claude/skills/frontend-utilities-knowledge/` — `SKILL.md` + `references/crud-examples.md`

You **explore** the codebase with two Explore agents, then **write these four files yourself**. You also generate `.claude/CLAUDE.md`. You do not touch any other agent or skill.

Work in the project root (`$CLAUDE_PROJECT_DIR`). The plugin's template versions live at `${CLAUDE_PLUGIN_ROOT}/skills/{backend,frontend}-utilities-knowledge/` — read them first; they define the exact section layout and, via `> FILL:` notes, what to discover for each section.

## Checklist / resume

State lives in `.claude/.kit-setup.md` (your working memory only — nothing reads it after setup).

1. If `.claude/.kit-setup.md` exists, read it and resume from the first unchecked step. Otherwise create it:

```markdown
# claude-kit setup
- [ ] Codebase explored (backend + frontend)
- [ ] Gaps answered
- [ ] Utilities skills written (backend + frontend)
- [ ] CLAUDE.md generated

## Backend findings
(filled during setup)

## Frontend findings
(filled during setup)

## User answers
(filled during setup)
```

Update the checkboxes and sections as you complete each step.

## Step 1 — Explore the codebase (two Explore agents, in parallel)

Read the two plugin templates first so you know exactly what each `*-utilities-knowledge` section needs. Then launch **two Explore agents in one message** (they run concurrently). Give each the matching template section list and ask for concrete names/paths.

**Backend Explore agent** — discover and report, with exact class names, namespaces and file paths:
- Stack from `composer.json` / `.env`: Laravel version, PHP constraint, DB driver, auth package, and key packages (DTO package if any, RBAC/permissions, media/files, datatable package, static analyzer + its configured level).
- **DTO layer**: does the backend wrap validated input in a DTO (`app/Dto|Data|DTO`, a Spatie-Data-style base), or do services take `$request->validated()` / arrays? Name the base class/trait if present.
- Base controller `authorize()` signature (is the second policy argument wrapped in an array?).
- Soft deletes: used? the exact `exists` / uniqueness rule forms.
- Attribute-translation policy in FormRequests.
- Role-restricted Resource resolver (e.g. a static `resolveClass()` + the current-user helper).
- The base datatable/list service: class name, what you implement (resource-class hook), what you override (query scope), the query/filter classes/interfaces.
- Helpers (`app/Helpers/`) — especially the current-user/auth resolver — service traits, and the DTO optional-fields trait. One line each.
- Namespacing layout under `app/`.
- One real domain entity (a simple CRUD model) to use as the example in `references/crud-examples.md`.

**Frontend Explore agent** — discover and report, with exact names, import paths and props/methods:
- Stack from `package.json`: Vue version, state store (Vuex/Pinia), UI framework + version, styling, HTTP client, i18n lib + supported locales, other notable libs (toasts, date, VueUse).
- Base CRUD API client (path, the CRUD verbs it exposes, how it builds URLs, the custom-URL registrar and URL accessor).
- Upload-form wrapper (path, instantiation, `fill`/`errors.get`/`post`/`put` API, FormData behavior).
- Global components: filters shell, data table, table-settings, dialog, shared form/table controls — names + key props/slots/emits + the table's reload method.
- Composables/utils: table-headers composable, response/error handler, header repository location, and other shared composables/utils.
- Store permission getter + permission naming scheme; role helpers.
- Header object shape; table-name uniqueness rule.
- Routing modules aggregator path; menu item shape; i18n file layout (per-entity modules + root locale files).
- `resources/js` folder layout; one real domain entity to use as the example.

Record both reports verbatim under "Backend findings" / "Frontend findings". Check off step 1.

## Step 2 — Ask the user only what exploration left ambiguous

Use **AskUserQuestion** with 2–4 questions. Skip anything the Explore agents answered clearly. Typically:
- **Agent language** — the language agents reply to the user in (e.g. Russian, English).
- **DTO layer** — only if exploration was inconclusive: confirm Request → DTO → Service vs services taking validated arrays.
- Confirm any base class / component / helper the explorers flagged as uncertain or missing.

Record answers under "User answers". Check off step 2.

## Step 3 — Write the two utilities skills (you write them, from the findings)

For **backend** and **frontend**, write into the project:
- `.claude/skills/backend-utilities-knowledge/SKILL.md` and `.../references/crud-examples.md`
- `.claude/skills/frontend-utilities-knowledge/SKILL.md` and `.../references/crud-examples.md`

Method for each file:
- Start from the plugin template (`${CLAUDE_PLUGIN_ROOT}/skills/.../`) — keep its structure, headings and YAML frontmatter (`name`, `disable-model-invocation: true`) **exactly**, so the project-local copy cleanly shadows the plugin's generic template.
- Replace every `> FILL:` note and neutral placeholder with the **concrete** classes / helpers / packages / components / paths from Step 1–2.
- **Remove the template's `<!-- TEMPLATE ... -->` comment block** and every `> FILL:` instruction — the written file is real project truth, not a template.
- Drop any section that genuinely doesn't apply (state it explicitly, e.g. "No DTO layer — services take `$request->validated()`") rather than leaving a placeholder.
- In `references/crud-examples.md`, rewrite the golden slice with the project's real base classes, namespaces, DTO base/trait (or the no-DTO variant) and the real domain example entity. If there is no DTO layer, delete the DTO section and pass `$request->validated()` to the service.

These project-local copies live where the project's own skills live and take precedence over the plugin's templates. If a target already exists, show a diff and ask before overwriting. Check off step 3.

> Do **not** edit the `*-conventions-knowledge` / `*-crud-flow-knowledge` skills or any agent — they are portable and read project specifics from the two utilities skills.

## Step 4 — Generate CLAUDE.md

- Read `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.tpl`.
- Replace every `{{PLACEHOLDER}}` with detected/answered values. For `POSTGRES_MCP_NOTE`: if `DB_CONNECTION=pgsql`, note the `postgres` MCP is available for direct DB inspection; otherwise state no DB MCP is configured for this driver.
- Replace each `<!-- SETUP:ASK ... -->` block with the user's answers (remove the comment markers).
- If `.claude/CLAUDE.md` already exists, show a diff and ask before overwriting.
- Write to `.claude/CLAUDE.md`. Check off step 4.

## Step 5 — Hand off

Tell the user setup is done and recommend running next:
- `/claude-kit:mcp` — verify required MCP servers and generate `.mcp.json`.
- `/claude-kit:lint` — install/verify linters so the auto-fix hooks are effective.

Keep output concise. Respond to the user in the language chosen in Step 2.
