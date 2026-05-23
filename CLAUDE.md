# CLAUDE.md — Operating procedure for the Learning Roadmap workspace

## GitHub

This workspace is the public-facing learning log at `github.com/<user>/learning-roadmap`. A nightly scheduled-tasks job (6:00 AM local) scans `~/Claude/` for changes from the previous day, writes a narrative to `02-notes/auto/YYYY-MM-DD.md`, on Sundays synthesizes the week into `06-weekly/`, and commits + pushes. Sensitive folders (`Clients/`, `Professional Development/Job-Search/`) are summarized at activity-count level only — never specifics.

## Architecture

This workspace uses a three-layer routing system (see `START_HERE.md`):
- **Layer 1** — `START_HERE.md` routes tasks to rooms.
- **Layer 2** — each room's `README.md` describes what lives there.
- **Layer 3** — individual files inside each room.

Always read `START_HERE.md` first, then the relevant room's `README.md`, then only the specific files the task needs. Do not load the whole vault.

## Token discipline

- Don't `grep -r` or `find` the whole workspace unless absolutely necessary. Use the routing map.
- Don't load files from rooms you're not currently working in.
- When in doubt, ask "which room is this?" before reading.
- Captured chat snippets go into `02-notes/` by default, not into other rooms.

## Where things go

- **`00-foundation/`** — learning goals, the roadmap itself, current focus, skill inventory, "what I'm learning next" lists. The strategic layer.
- **`01-guides/`** — polished how-to guides written for future-Avi (e.g. "Screen for Minecraft Server Management"). Long-lived reference content.
- **`02-notes/`** — raw, dated notes. Captured chat snippets from `/log` land here. Command logs, error traces, "what I tried today."
- **`03-projects/`** — folders for individual hands-on projects (e.g. `minecraft-netcup/`, `terraform-sandbox/`). Each project may have its own internal structure.
- **`04-cheatsheets/`** — concise quick-reference files. One topic per file, scannable at a glance.
- **`05-handoffs/`** — session state for resuming across chats. `active/` for live threads, `archive/` for closed ones. **`active/` is gitignored**; `archive/` ships to GitHub.
- **`06-weekly/`** — Sunday-synthesized weekly digests (`YYYY-WW.md`). Written by the nightly scheduled task, not by hand.
- **`02-notes/auto/`** — machine-written daily logs from the nightly task. One file per day. Don't hand-edit. Human-written same-day notes go at the top level of `02-notes/` with a `-<topic>` suffix.

## Handoff protocol

When wrapping up a session or running low on context:
1. Write a handoff doc to `05-handoffs/active/handoff-YYYY-MM-DD-<topic>.md` using `05-handoffs/_TEMPLATE.md`.
2. Update the "Active threads" section in `START_HERE.md` with a one-line pointer.
3. Emit a copy-paste resume prompt for the next chat (per global instructions).

When a thread is fully closed, move its handoff from `active/` to `archive/`.

## Subagent delegation

For broad searches across the workspace, prefer the Explore agent over `grep -r` to keep this conversation's context clean. For polished writing tasks (guides, syntheses), the work usually happens inline since Avi wants voice control.

## Conventions

- Filenames: keep spaces and normal capitalization (Obsidian-friendly). Date prefix `YYYY-MM-DD-` for dated notes.
- Frontmatter: each room's README specifies its own frontmatter shape; follow it.
- No emojis in file content unless the source already uses them.
