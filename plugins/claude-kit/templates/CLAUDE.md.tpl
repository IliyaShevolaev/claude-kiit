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
<!-- SETUP:ASK Fill this section from the user's answers. Everything here is read by every agent, so it is the single source of truth for project-specific patterns. -->

- **Architecture style:** {{ARCH_STYLE}}
- **Backend layering:** {{BACKEND_LAYERING}}
- **DTO layer:** {{DTO_LAYER}} <!-- e.g. "used: Request -> DTO -> Service" OR "not used: services receive validated arrays/Request" -->
- **Base list/datatable service:** {{BASE_DATATABLE_SERVICE}} <!-- class name, or "none" -->
- **Datatable package:** {{DATATABLE_PACKAGE}} <!-- e.g. yajra/laravel-datatables, or "none" -->
- **Custom helpers / traits / base classes agents should know about:** {{CUSTOM_UTILITIES}}
- **Other project conventions:** {{OTHER_CONVENTIONS}}

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
