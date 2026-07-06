# Project: {{PROJECT_NAME}}

## General information
{{PROJECT_DESCRIPTION}}

## Tech stack

### Backend
- **Framework:** Laravel {{LARAVEL_VERSION}}
- **PHP:** {{PHP_VERSION}} (`declare(strict_types=1)`)
- **Database:** {{DB_DRIVER}}
- **Auth:** {{AUTH_PACKAGE}}

### Frontend
- **Framework:** {{FRONTEND_FRAMEWORK}}
- **Build Tool:** {{BUILD_TOOL}}
- **State:** {{STATE_STORE}}
- **UI Framework:** {{UI_FRAMEWORK}}
- **Styling:** {{STYLING}}
- **i18n locales:** {{LOCALES}}

## Code Principles
- Don't write comments in code unless explicitly asked

## Conventions

Project-specific backend/frontend concretes — tech stack, base classes, helpers, traits, global components, the DTO layer, the base datatable service, golden CRUD examples — are the source of truth in the two always-loaded knowledge skills, filled by `/claude-kit:setup`:

- **`backend-utilities-knowledge`** (`SKILL.md` + `references/crud-examples.md`)
- **`frontend-utilities-knowledge`** (`SKILL.md` + `references/crud-examples.md`)

The generic canon lives in `backend-/frontend-conventions-knowledge` and `backend-/frontend-crud-flow-knowledge` (portable, project-agnostic). Do not duplicate those specifics here — update the utilities skills instead.

## MCP servers
- **serena** — always use for reading and editing code (symbol-level), not the plain Read/Edit tools. At the start of any coding task call `initial_instructions`.
{{POSTGRES_MCP_NOTE}}

## Agents (from claude-kit)
- Backend tasks (controllers, services, models, migrations, API) — delegate via the Agent tool with `subagent_type: "backend-dev"`.
- Frontend tasks (components, composables, pages, API services) — delegate via `subagent_type: "frontend-dev"`.
- If a task touches both — launch both; backend first if the frontend depends on the API contract.
- Reviews: `code-reviewer`, `security-reviewer`, `performance-reviewer`, `architecture-reviewer`, `feature-integration-reviewer`.
- Tests: `feature-tester`, `tests-fixer`. Docs: `doc-writer`, `summary-editor`.

## Documentation
- Domain docs live in `.claude/docs/domains/` (per-project, created via the `module-doc` skill). Read the relevant one before working on a domain.
- Generated reference docs default to `storage/documentation/` (honkit/GitBook `SUMMARY.md`). Change here if this project uses a different path/format: {{DOC_PATH}}

## Tests
**NEVER run the project's tests yourself, ask the user to do it.**

## Communication Rules
- **Internal reasoning & tool use:** always in English.
- **User output:** always respond to the user in {{AGENT_LANGUAGE}}.
- **Tone:** professional, concise, direct.
