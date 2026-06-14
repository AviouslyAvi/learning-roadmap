# START HERE — Learning Roadmap

This workspace tracks Avi's technical skill development: Linux/server admin, Terraform/IaC, networking, game server ops, and anything else worth learning. It uses a three-layer routing system to keep context tight.

## The three layers

1. **START_HERE.md** (this file) — Layer 1 router. Tells Claude which room to enter for a given task. Always loaded first.
2. **`<room>/README.md`** — Layer 2 context. Once you've routed to a room, load only that room's README to learn what lives there and how to work in it.
3. **`<room>/*.md`** — Layer 3 content. The actual notes, guides, logs, and project files. Load only what the current task needs.

This keeps token usage low — never load the whole vault when one room will do.

## Loading protocol

When a new task arrives:
1. Read this file to pick the room.
2. Read that room's `README.md`.
3. Load only the specific files that task needs.
4. If the task spans rooms, route to the most relevant one and pull cross-room files explicitly.

## Task → room map

| If the task is… | Go to… |
|---|---|
| Goals, current focus, learning priorities, the roadmap itself | `00-foundation/` |
| Writing or reading a how-to guide (e.g. "set up X", "configure Y") | `01-guides/` |
| Raw learning notes, command logs, captured chat snippets | `02-notes/` (machine-written daily logs in `02-notes/auto/`) |
| Hands-on project work (Minecraft server, Terraform infra, etc.) | `03-projects/` |
| Quick-reference cards, command cheatsheets | `04-cheatsheets/` |
| Resuming a prior chat / saving session state | `05-handoffs/` |
| Weekly digests (Sunday synthesis of the week's auto-notes) | `06-weekly/` |

## Slash-style triggers

- `/log` → capture current snippet into the right room (usually `02-notes/`)
- `/handoff` → save session state to `05-handoffs/active/`
- `/resume` → load a handoff and continue
- `/scaffold` → re-bootstrap (only if structure breaks)
- `/week` → summarize the current ISO week from `02-notes/auto/` inline (no file writes)

## Automation

A scheduled Claude Code task runs daily at 6:00 AM local time. It scans `~/Claude/` for the previous day's changes, writes a narrative summary to `02-notes/auto/YYYY-MM-DD.md`, and on Sundays synthesizes the week into `06-weekly/YYYY-WW.md` + updates the root `README.md` Weekly log. Then it commits and pushes.

## Active threads

- 🏠 **ADHD Hub v2.1** — 4-DB Notion + additive Obsidian PARA built. User-side: Daily Notes plugin, Apple Shortcuts, n8n install, 3 Notion DB templates. See `05-handoffs/active/handoff-2026-05-22-adhd-hub-v2.md`.
- 📚 **Notion sync** — One-way Obsidian → Notion via Share to NotionNext plugin. Conventions doc written; `screen.md` flagged as test note. User-side: create Notion integration, install plugin, configure, run first sync. See `00-foundation/notion-sync-conventions.md`.

## Last updated

2026-05-25
