---
description: "Vendor claude-kit into the project's .claude/ so the whole team can edit agents, skills, commands and hooks directly in the repo (no plugin needed)."
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion
---

You are **vendoring claude-kit into the current project** so its files live under `.claude/` and become normal, editable, committed project files. After this, the plugin is no longer needed for this project (and should be removed to avoid duplicate agents/commands/hooks).

Work in the project root (`$CLAUDE_PROJECT_DIR`). The plugin source is `${CLAUDE_PLUGIN_ROOT}`.

## Step 0 — Confirm

Explain to the user what will happen and get confirmation before writing:
- Files will be copied into `.claude/` (agents, skills, commands, hooks, templates).
- Hooks will be wired into `.claude/settings.json`.
- They should then uninstall the plugin for this project so nothing loads twice.

If `.claude/` already contains claude-kit files (e.g. from a previous vendor or from `setup`), warn that you will diff and ask before overwriting each conflicting file.

## Step 1 — Copy the files

Copy these directories from `${CLAUDE_PLUGIN_ROOT}` into `.claude/`:
- `agents/`   → `.claude/agents/`
- `skills/`   → `.claude/skills/`
- `commands/` → `.claude/commands/`
- `hooks/`    → `.claude/hooks/`
- `templates/` → `.claude/templates/`

Rules:
- Create target directories as needed.
- For every file that already exists at the target, show a short diff and ask (AskUserQuestion or inline) whether to overwrite or keep the project's version. Never clobber silently.
- Do NOT copy `commands/vendor.md` — vendoring a second time from an already-vendored copy is meaningless. Skip it.

## Step 2 — Rewrite plugin-only paths

The vendored command files still point at `${CLAUDE_PLUGIN_ROOT}`, which only resolves while the plugin is installed. In every file under `.claude/commands/`, replace `${CLAUDE_PLUGIN_ROOT}/` with `.claude/` so they read templates/hooks from the vendored copies (e.g. `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.tpl` → `.claude/templates/CLAUDE.md.tpl`). Check `.claude/skills/**/SKILL.md` too and apply the same replacement where it appears.

## Step 3 — Wire the hooks into settings.json

The plugin's `hooks.json` does not apply to vendored files, so add the hooks to `.claude/settings.json` using project-relative paths. Read the existing `.claude/settings.json` (create `{}` if missing) and **merge** this into it (do not drop existing keys/permissions):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Update|mcp__serena__replace_symbol_body|mcp__serena__insert_after_symbol|mcp__serena__insert_before_symbol|mcp__serena__replace_content|mcp__serena__rename_symbol",
        "hooks": [
          { "type": "command", "command": "php \"$CLAUDE_PROJECT_DIR/.claude/hooks/php-autofix.php\"", "shell": "bash", "timeout": 30, "statusMessage": "PHP autofix (php -l + pint/phpcbf)" },
          { "type": "command", "command": "node \"$CLAUDE_PROJECT_DIR/.claude/hooks/front-autofix.cjs\"", "shell": "bash", "timeout": 30, "statusMessage": "Frontend autofix (prettier + eslint --fix)" }
        ]
      }
    ]
  }
}
```

If a `PostToolUse` array already exists, append this matcher block instead of replacing the array. If an identical claude-kit hook block is already present, leave it.

Also, if `.claude/settings.json` has no `permissions` block, offer to seed it from `.claude/templates/settings.json.tpl` (the git read-only denylist) — ask first.

## Step 4 — Finish

Tell the user:
- What was copied and what was merged into `settings.json`.
- To remove the plugin so files don't load twice:
  ```
  claude plugin uninstall claude-kit
  ```
- That everything under `.claude/` is now theirs to edit and commit; teammates who clone the repo get it automatically.
- Next: run `/claude-kit:setup` to fill the two project-truth skills (`backend-utilities-knowledge` + `frontend-utilities-knowledge`) via two Explore agents and generate `.claude/CLAUDE.md` (setup reads/writes the vendored copies under `.claude/`).

Keep output concise.
