# 02-notes

## Room purpose

Raw, dated learning notes. Captured chat snippets, command logs, error traces, "what I tried today." This is the scratchpad — content here may later get polished into `01-guides/` but doesn't have to.

## What lives here

Files named `YYYY-MM-DD-<topic>.md`. Examples:
- `2026-05-21-minecraft-server-setup.md`
- `2026-05-22-terraform-state-debug.md`

**Subdir: `auto/`** — machine-written daily activity logs from the nightly `scheduled-tasks` job. One file per day, `auto/YYYY-MM-DD.md`. Don't hand-edit these; if you want to add a human note for the same day, put it at the top level of `02-notes/` with a `-<topic>` suffix.

## Files to load

Just the specific dated note(s) relevant to the current task.

## Files to skip

Everything else by default.

## Skills to invoke

- `/log` — capture current chat snippet into this room (top level, not `auto/`).
- `/week` — summarize the current ISO week's `auto/` notes inline.

## Pipeline

1. Working through something in chat.
2. `/log` saves the snippet here with date + topic.
3. If the content matures, it gets promoted to `01-guides/` as a polished version.

## When to leave this room

- If the content is polished and evergreen → `01-guides/`
- If it's about a specific project → `03-projects/<project>/`

## Frontmatter

```yaml
---
date: YYYY-MM-DD
topic: <short topic>
type: note
---
```
