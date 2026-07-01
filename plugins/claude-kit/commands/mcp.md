---
description: "Check that the MCP servers claude-kit relies on are available, and generate .mcp.json for the project database."
allowed-tools: Read, Write, Edit, Glob, Bash
---

You are verifying **MCP availability** for claude-kit and wiring up the project's database MCP. Work in the project root (`$CLAUDE_PROJECT_DIR`).

## Required MCP servers

- **serena** — required always (code intelligence). It is an external plugin, not shipped by claude-kit.
- **postgres** — required only if the project database driver is PostgreSQL.

## Step 1 — Check what's installed

Run `claude mcp list` (via Bash) and inspect the output.
- If **serena** is not present, tell the user to install it themselves — claude-kit does not install external MCP servers:
  ```
  claude plugin install serena
  ```
  Do not attempt to install it for them.

## Step 2 — Database MCP

- Read `.env` (fallback `.env.example`) and get `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.
- **If `DB_CONNECTION=pgsql`:**
  - Read the template `${CLAUDE_PLUGIN_ROOT}/templates/mcp.json.tpl`.
  - Merge its `postgres` server entry into the project root `.mcp.json` (create the file if missing; preserve any existing servers).
  - Keep the connection string using `${DB_USERNAME}`/`${DB_PASSWORD}`/`${DB_HOST}`/`${DB_PORT}`/`${DB_DATABASE}` **env-expansion form — never hardcode the password** into the committed file.
- **If the driver is not pgsql** (mysql, sqlite, etc.): do NOT add the postgres MCP. Tell the user which driver was detected and that no matching DB MCP is configured; if they want DB access via MCP they should add a server for that driver manually.

## Step 3 — Report

Summarize: which required MCP servers are present / missing (with the install hint for missing ones), and what was written to `.mcp.json`. Remind the user that `.mcp.json` changes take effect after reloading/restarting the session, and that `${DB_*}` values are read from their environment/`.env`.

Keep output concise.
