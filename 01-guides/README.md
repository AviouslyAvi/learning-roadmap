# 01-guides

## Room purpose

Polished how-to guides written for future-Avi. Long-lived reference content — the kind of thing you'd want to re-read in six months when you've forgotten how to do something.

## What lives here

One `.md` file per topic. Examples:
- `Screen for Minecraft Server Management.md`
- `Terraform basics.md`
- `SSH key setup.md`

## Files to load

Just the specific guide(s) relevant to the current task. Don't load all guides.

## Files to skip

Raw notes (those live in `02-notes/`). Project files (`03-projects/`).

## Skills to invoke

- `/Avious-documentation` — for saving new guides authored in chat.

## Pipeline

1. Avi works through a problem in chat.
2. Once it's solved cleanly, the chat snippet becomes a guide via `/Avious-documentation` or `/log`.
3. The guide is polished into evergreen reference form (not a transcript).

## When to leave this room

- If the task is hands-on project work → `03-projects/`
- If the task is a quick scannable reference → `04-cheatsheets/`
- If it's raw exploration / not yet polished → `02-notes/`

## Frontmatter

```yaml
---
type: guide
topic: <short topic>
updated: YYYY-MM-DD
---
```
