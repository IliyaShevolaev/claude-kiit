---
name: doc-workflow
description: "Documentation workflow: from a commit hash, find code that has no/outdated docs → split by entity → Haiku doc-writer agents → orchestrator writes SUMMARY"
disable-model-invocation: true
---

You run the documentation workflow. **You are the Orchestrator** — you do NOT read source code to document it and you do NOT write `.md` docs yourself. Your jobs: run git, map paths, group files by entity, and delegate to `doc-writer` + `summary-editor` agents. Argument: `$ARGUMENTS` — a commit hash (a merge commit, or the docs-branch baseline before the merge). If empty → audit mode (Step 1b).

## Step 1 — Detect what needs docs

Run these read-only git commands yourself.

**1a — hash given.** First detect whether the hash is a merge commit:

```bash
git rev-list --parents -n 1 <hash>
```

- If the line has **3+** hashes (commit + 2 parents) → it's a merge. Diff range = `<hash>^1 <hash>` (what the merged feature introduced).
- Otherwise → diff range = `<hash> HEAD`.

Then:

```bash
git diff --name-status <range> -- 'app/**/*.php' 'config/**/*.php'
```

**1b — no hash (audit mode).** List every source file under `app/` and `config/` and treat as `M` (the existence check below sorts them into create/update).

### Map each source file → doc path

The documentation root (`storage/documentation` below) and the SUMMARY/table-of-contents format are configurable — see CLAUDE.md; the defaults below assume honkit/GitBook under `storage/documentation`.

- `app/<Rest>.php` → `storage/documentation/App/<Rest>.md` (**capitalize the first segment**: `app` → `App`).
- `config/<Rest>.php` → `storage/documentation/config/<Rest>.md` (keep lowercase `config`).
- SUMMARY link form for that file: lowercase first segment + **backslashes**, e.g. `app\Services\Entities\EntityService.md`.

### Sort into buckets (check doc existence with `test -f`)

| git status | doc exists? | bucket |
|---|---|---|
| `A` | — | **create** |
| `M` / `R` | no | **create** |
| `M` / `R` | yes | **update** |
| `D` | — | **delete** (you handle it, no agent) |

For renames (`R`), also note old→new doc path — for the `summary-editor` agent.

## Step 2 — Group by entity

Cluster the **create** + **update** files into entities. One entity = the related files that share a domain folder and the same core noun, with layer suffixes stripped:

- `Http/Controllers/Entities/EntityController.php`, `Services/Entities/EntityService.php`, `Http/Requests/Entities/EntityRequest.php`, `Dto/Entities/EntityDto.php`, `Http/Resources/Entities/EntityResource.php`, `Models/Entities/Entity.php`, `Enums/Entities/EntityStatus.php` → **entity `Entity`**.

Rules:
- One `doc-writer` agent per entity cluster.
- **Batch trivial work:** several unrelated single-file `update`s (or tiny leftovers that don't form a cluster) → group up to ~6 files into one `doc-writer` agent to save agents/tokens.
- An entity that has both `create` and `update` files goes to one agent; pass the per-file mode.

## Step 3 — Show the plan, get confirmation

Show the user a table:

```
Сущность      | Файлы (режим)                                    | Агент
Entity        | EntityController (create), EntityService (update) | doc-writer #1
Прочие правки | FooEnum (update), BarTrait (update)              | doc-writer #2 (batch)
Удаления      | App\Services\Old\OldService.md                   | оркестратор
```

Ask: **"План документации готов. Запускаем?"**

Wait. If the user adjusts (skip an entity, merge groups) — apply and show again. On **"запускай"** → Step 4.

## Step 4 — Launch doc-writer agents in waves

**You never edit `.md` files and never edit `SUMMARY.md` yourself.** You only launch agents and run read-only git.

Launch `doc-writer` agents (`subagent_type: "doc-writer"`) in **waves of 5–6 agents at a time**, in parallel within a wave. Don't fire all clusters at once — wait for a wave to finish before starting the next. Pass each agent:
- Its entity name.
- The per-file list: `mode`, absolute `source` path, absolute `target` doc path (already computed — the agent must not recompute).

**Keep with yourself:**
- The `agentId` of each `doc-writer` (for revisions).
- The `summaryEditorId` (see Step 5).

## Step 5 — SUMMARY via the summary-editor agent (sleep/wake)

SUMMARY maintenance is **delegated** — it keeps the large table-of-contents file out of your (expensive) context.

After **each wave** finishes:

1. Get the real file delta from git (the source of truth — not the agents' text):

```bash
git status --porcelain -- storage/documentation/
```

   `??` = created, ` D`/`D ` = deleted, `R ` = renamed. Convert each doc path to SUMMARY link form (lowercase first segment, backslashes): `storage/documentation/App/Services/Entities/EntityService.md` → `app\Services\Entities\EntityService.md`.

2. Hand that `Created / Deleted / Renamed` delta to the `summary-editor` agent:
   - **First wave:** launch `summary-editor` (`subagent_type: "summary-editor"`), save its `summaryEditorId`.
   - **Later waves:** resume it via `SendMessage` with `to: summaryEditorId` — it already holds SUMMARY structure in context, no re-read. Between waves it is simply idle ("asleep").
   - Also hand it any **deletes/renames** of `.md` files (the orchestrator does the actual `.md` file move/delete on disk; the summary-editor only fixes the SUMMARY lines).

3. When all waves are done, the summary-editor has applied everything. Show the user the totals: created / updated / deleted docs + the summary-editor's confirmation.

## Step 6 — Verify coverage (name-only cross-check)

After all waves finish, prove the docs match the source diff **by path + status, without reading any file content**. Goal: every in-scope source file has a doc change of the matching kind, and no doc change is orphaned.

1. Re-emit the **in-scope** net source diff (the same `<range>` and path filters you used in Step 1, narrowed to the entities the user asked for) as `STATUS PATH` lines → `/tmp/src.txt`.
2. Map each source line to its **expected** doc path+status (same rule as Step 1: `app/X.php` → `storage/documentation/App/X.md`; treat `R` as `A` at the new path) → `/tmp/expected.txt`.
3. Snapshot the **actual** uncommitted doc changes (exclude `SUMMARY.md`), normalizing porcelain codes: `??`→`A`, ` M`→`M`, ` D`→`D`, `R…`→`R` → `/tmp/docs.txt`.
4. Compare both ways and report mismatches:

```bash
# expected docs missing from the actual changes
join -v1 -1 2 -2 2 <(sort -k2 /tmp/expected.txt) <(sort -k2 /tmp/docs.txt)
# changed docs with no matching in-scope source (orphans)
join -v2 -1 2 -2 2 <(sort -k2 /tmp/expected.txt) <(sort -k2 /tmp/docs.txt)
# status mismatches (A/M/D) on paths present in both
join -1 2 -2 2 <(sort -k2 /tmp/expected.txt) <(sort -k2 /tmp/docs.txt) \
 | awk '{s=$2; if(s=="R")s="A"; if(s!=$3) print "MISMATCH:",$1,"(src:"$2" doc:"$3")"}'
```

Show the user a small table — source `A/M/D` counts vs doc `A/M/D` counts — and list any mismatch/orphan. Clean check = all three commands print nothing and the counts line up. If something is off, fix it in Step 7 (relaunch the responsible `doc-writer`, or handle a missed delete/rename yourself) and re-run this step.

## Step 7 — Revisions (iterative)

The user may ask for fixes ("в доке Entity перепиши описание метода store", "добавь ещё файл X").

- Doc-content fixes → `SendMessage` to the relevant `doc-writer` `agentId` from Step 4.
- *Fallback*: if `SendMessage` errors — report: "⚠️ Агент недоступен, запускаю нового с сохранённым контекстом." and launch a fresh `doc-writer` with the file list + target paths + the revision.
- If the fix added/renamed/removed `.md` files, re-run the git delta (Step 5.1) and `SendMessage` it to the `summary-editor` (`summaryEditorId`).

Repeat until the user says "готово".
