---
description: "Install/verify linters and formatters (pint/phpcbf, prettier, eslint) so the claude-kit auto-fix hooks are effective."
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion
---

You are setting up **linters and formatters** for the current project. Work in the project root (`$CLAUDE_PROJECT_DIR`).

Context: claude-kit ships always-on `PostToolUse` hooks that auto-fix edited files. They are no-ops unless the tooling exists:
- **PHP** — `php -l` (always), then `vendor/bin/pint` if present, else `vendor/bin/phpcbf`.
- **Frontend** — `node_modules/prettier` (required to run), then `node_modules/eslint` `--fix`.

Your job is to make sure that tooling is installed and configured. **Any command that installs packages or writes a config file modifies the user's project — confirm before running/writing.**

## Step 1 — Detect current state

- PHP formatter: check `vendor/bin/pint` and `vendor/bin/phpcbf`; check `composer.json` dev deps for `laravel/pint` / `squizlabs/php_codesniffer`.
- Frontend: check `node_modules/prettier`, `node_modules/eslint`; check `package.json` dev deps.
- Existing configs: `pint.json`, `.php-cs-fixer*`, `phpcs.xml*`, `.prettierrc*`/`prettier` key in package.json, `eslint.config.*`/`.eslintrc.*`.

Report a short table: tool → installed? config present?

## Step 2 — Install missing tooling (with confirmation)

Offer to install what's missing. Suggest, and only run after the user agrees:
- PHP formatter (prefer Pint for Laravel): `composer require laravel/pint --dev`
- Frontend: `npm i -D prettier eslint eslint-plugin-vue @eslint/js` (adjust for the detected package manager: npm / yarn / pnpm).

If the user declines an install, note the corresponding hook will stay a no-op.

## Step 3 — Configs (keep vs overwrite)

For each config file:
- **If it already exists**, use **AskUserQuestion** to ask whether to keep the project's own config or overwrite it with the claude-kit base. Never overwrite silently — the user may have important rules there.
- **If it is missing**, write the base config from the plugin templates:
  - `${CLAUDE_PLUGIN_ROOT}/templates/linters/pint.json` → `pint.json`
  - `${CLAUDE_PLUGIN_ROOT}/templates/linters/.prettierrc.json` → `.prettierrc.json`
  - `${CLAUDE_PLUGIN_ROOT}/templates/linters/eslint.config.js` → `eslint.config.js` (only if the project has no eslint config; adapt to the project's module type)

## Step 4 — Report

Summarize what was installed and which configs were written/kept. Confirm the auto-fix hooks will now run for PHP and/or frontend files. Keep output concise.
