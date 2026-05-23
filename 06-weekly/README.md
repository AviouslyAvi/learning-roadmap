# 06-weekly

## Room purpose

Weekly digests synthesizing what was learned and shipped each week across all of `~/Claude/`. Written by the nightly scheduled-tasks job on Sundays from that week's `02-notes/auto/*.md` daily entries.

The README at the repo root carries the latest four weeks inline; older weeks live here permanently as the archive.

## What lives here

One file per ISO week: `YYYY-WW.md` (e.g. `2026-21.md` for week 21 of 2026).

Each digest covers:
- Themes — what threads ran through the week
- Key learnings — concrete things added to the toolkit
- Projects touched — short list grouped by workspace
- Things shipped / committed
- Blockers and open threads

## Files to load

Just the specific week you're looking at. Don't load the whole folder.

## Files to skip

Everything else by default.

## Skills to invoke

- `/week` — on-demand summary of the *current* (in-progress) week, reads from `02-notes/auto/`.

## Pipeline

1. The nightly job appends to `02-notes/auto/YYYY-MM-DD.md` daily.
2. On Sundays it synthesizes the week's auto-notes into `06-weekly/YYYY-WW.md`.
3. The same Sunday run updates the "Weekly log" section in the root `README.md`.

## When to leave this room

- For the current in-progress week → `02-notes/auto/`
- For full daily detail of a specific past day → `02-notes/auto/YYYY-MM-DD.md`

## Frontmatter

```yaml
---
type: weekly-digest
week: YYYY-WW
generated: YYYY-MM-DD
---
```
