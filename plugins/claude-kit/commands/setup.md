---
description: "First-run project setup: detect the Laravel + Vue stack, ask a few questions, generate .claude/CLAUDE.md, and specialize the backend/frontend agents + CRUD knowledge skills for this project."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

You are running the **claude-kit first-run setup** for the current project. Your job:
1. Detect the stack.
2. Capture project-specific conventions from the user.
3. Generate a tuned `.claude/CLAUDE.md`.
4. **Specialize four files for this project** — the `backend-dev` and `frontend-dev` agents and the `backend-crud-flow-knowledge` / `frontend-crud-flow-knowledge` skills — by filling them with what you learned.

Work in the project root (`$CLAUDE_PROJECT_DIR`).

## Checklist / resume

State lives in `.claude/.kit-setup.md`. It is your working memory only — after setup, nothing reads it.

1. If `.claude/.kit-setup.md` exists, read it and resume from the first unchecked step. Otherwise create it with this skeleton:

```markdown
# claude-kit setup
- [ ] Stack detected
- [ ] Questions answered
- [ ] CLAUDE.md generated
- [ ] Agents & knowledge specialized

## Detected stack
(filled during setup)

## User answers
(filled during setup)
```

Update the checkboxes and the sections as you complete each step.

## Step 1 — Detect the stack (do not ask what you can detect)

- `composer.json` → Laravel version (`laravel/framework`), PHP constraint, auth package (e.g. any `*/jwt-auth`, `laravel/sanctum`, `laravel/passport`), datatable package (e.g. `yajra/laravel-datatables`), static analyzer (`larastan`/`phpstan`), formatter (`laravel/pint`, `squizlabs/php_codesniffer`).
- `package.json` → frontend framework (Vue vs React), UI framework (Vuetify / PrimeVue / Element / Tailwind / etc.), state store (Vuex / Pinia / Redux), build tool (Vite / webpack), i18n lib, eslint/prettier presence.
- `.env` (fallback `.env.example`) → `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `APP_NAME`, `APP_LOCALE`/`APP_FALLBACK_LOCALE`.
- **Scan the codebase** (Glob/Grep) to discover the actual building blocks the specialized files will reference:
  - Backend: base controller, a base list/datatable service (a class other services `extends` for tables), how services receive input (a DTO class in `app/Dto|Data|DTO`, or `$request->validated()`), custom global helpers, shared traits, the API Resource pattern, namespace layout under `app/`.
  - Frontend: the shared API/CRUD helper (something like a `crudApi`/`useXxxApi` factory), the form-submit helper (an `uploadForm`-style util), the datatable/list component, the top-filters component, router + menu registration, the i18n locale files layout.
  - Record concrete names/paths — these are what you bake into the four files in Step 4.

Record findings in "Detected stack". Check off step 1.

## Step 2 — Ask the user (only what you can't detect)

Use **AskUserQuestion** with 2–4 questions. Skip anything detection already answered. Cover the gaps needed for CLAUDE.md **and** for specializing the four files:
- **Agent language** — the language agents should reply to the user in (e.g. Russian, English).
- **DTO layer** — confirm: does the backend use a DTO layer (Request → DTO → Service), or do services take validated arrays / the Request directly? (This decides whether DTO steps stay or are removed in Step 4.)
- **Backend conventions** — confirm the base list/datatable service class name (or "none"), and any custom helpers/traits/base classes agents must respect.
- **Frontend conventions** — confirm the shared API/CRUD helper, the form helper, and the list/table + filters components the frontend agent should reuse (or "none / free-form").

Record answers in "User answers". Check off step 2.

## Step 3 — Generate CLAUDE.md

- Read `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.tpl`.
- Replace every `{{PLACEHOLDER}}` with detected/answered values. For `POSTGRES_MCP_NOTE`: if `DB_CONNECTION=pgsql`, note the `postgres` MCP is available for direct DB inspection; otherwise state no DB MCP is configured for this driver.
- Replace each `<!-- SETUP:ASK ... -->` block with the user's answers (remove the comment markers).
- If `.claude/CLAUDE.md` already exists, show a diff and ask before overwriting.
- Write to `.claude/CLAUDE.md`. Check off step 3.

## Step 4 — Specialize agents & knowledge for this project

Take the four generic files from the plugin and write **project-specific** versions into the project's `.claude/`. These project-local copies live where the project's own agents live and take precedence over the plugin's generic versions.

Sources → targets:
- `${CLAUDE_PLUGIN_ROOT}/agents/backend-dev.md` → `.claude/agents/backend-dev.md`
- `${CLAUDE_PLUGIN_ROOT}/agents/frontend-dev.md` → `.claude/agents/frontend-dev.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/backend-crud-flow-knowledge/SKILL.md` → `.claude/skills/backend-crud-flow-knowledge/SKILL.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/frontend-crud-flow-knowledge/SKILL.md` → `.claude/skills/frontend-crud-flow-knowledge/SKILL.md`

For each file, read it and rewrite the project-specific parts using Step 1–2 findings:
- Replace every "the project's base … (see CLAUDE.md)" reference with the **actual** class / package / component name you discovered (base datatable service, datatable package, auth package, UI framework, state store, API helper, form helper, list/filters components).
- **DTO layer:**
  - If the project **uses DTOs** — keep the Request → DTO → Service steps and name the actual DTO base/pattern.
  - If it **does not** — remove the DTO steps and the "if the project uses a DTO layer…" conditionals entirely; state services take `$request->validated()` / arrays. Do not leave "see CLAUDE.md" dangling.
- Replace neutral example nouns (`Entity`, `SomeModel`, `example`) with a realistic example from this project's domain if one is obvious; otherwise leave them neutral.
- Preserve the YAML frontmatter exactly (`name`, `model`, `effort`, `color`, `disallowedTools`, `skills`). Keep structure and headings; only concretize wording and code examples.
- Keep the frontmatter `name` values identical to the plugin's (`backend-dev`, `frontend-dev`) so the project versions cleanly shadow the generic ones.

If a target already exists, show a diff and ask before overwriting. Check off step 4.

> The other agents (reviewers, testers, doc agents) and the remaining skills stay generic and read project specifics from `.claude/CLAUDE.md` — do not copy or edit them.

## Step 5 — Hand off

Tell the user setup is done and recommend running next:
- `/claude-kit:mcp` — verify required MCP servers and generate `.mcp.json`.
- `/claude-kit:lint` — install/verify linters so the auto-fix hooks are effective.

Keep output concise. Respond to the user in the language chosen in Step 2.
