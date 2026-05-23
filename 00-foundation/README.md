# 00-foundation

## Room purpose

The strategic layer. Holds the learning roadmap itself, current focus areas, skill inventory, and "what's next." This is the room to enter when the task is about *direction* rather than *doing*.

## What lives here

- `roadmap.md` — the master learning roadmap (skills, milestones, priorities)
- `current-focus.md` — what Avi is actively learning this week/month
- `skill-inventory.md` — what's been learned, what's in-progress, what's queued
- Long-term goals, "why am I learning this" rationale docs

## Files to load

Default: just this README + `current-focus.md` if it exists.

## Files to skip

Project-specific files (those live in `03-projects/`). How-to guides (those live in `01-guides/`).

## Skills to invoke

None specific — this room is mostly human-facing planning content.

## Pipeline

Updates here are usually triggered by:
- A new learning goal being added
- A skill being marked complete
- A weekly/monthly review

## When to leave this room

- If the task is "how do I do X" → `01-guides/`
- If the task is "I'm working on project X" → `03-projects/`
- If the task is "quick reference for X" → `04-cheatsheets/`

## Frontmatter

```yaml
---
type: foundation
updated: YYYY-MM-DD
---
```
