# Learning Roadmap

A running record of what I'm teaching myself — Linux/server admin, Terraform/IaC, networking, game-server ops, AI tooling, anything technical worth learning.

This repo doubles as a notebook and a public log. The strategic layer (`00-foundation/`), polished how-tos (`01-guides/`), raw dated notes (`02-notes/`), hands-on projects (`03-projects/`), and quick-reference cards (`04-cheatsheets/`) all live here. A nightly job scans my work across other directories and writes a daily summary into `02-notes/auto/`; on Sundays it synthesizes a weekly digest into `06-weekly/` and updates the "Weekly log" section below.

If you're me coming back to this in a new chat, start at [START_HERE.md](START_HERE.md). It routes to the right room.

## Currently learning

- Linux `screen` — see [04-cheatsheets/screen.md](04-cheatsheets/screen.md)
- Minecraft server ops on Netcup — see [02-notes/2026-05-21-minecraft-netcup-server-setup.md](02-notes/2026-05-21-minecraft-netcup-server-setup.md)
- Terraform basics — see `TERRAFORM/terraform-localstack-s3-lab/`
- ADHD Hub (Notion + Obsidian PARA) — see [05-handoffs/archive/](05-handoffs/archive/)

For the full picture, see [00-foundation/](00-foundation/).

## Rooms

| Room | What's in it |
|---|---|
| [00-foundation/](00-foundation/) | Roadmap, current focus, skill inventory — the strategic layer |
| [01-guides/](01-guides/) | Polished how-to guides |
| [02-notes/](02-notes/) | Raw dated learning notes (incl. `auto/` written by the nightly job) |
| [03-projects/](03-projects/) | Hands-on project work |
| [04-cheatsheets/](04-cheatsheets/) | Quick-reference cards, one per tool |
| [05-handoffs/](05-handoffs/) | Chat session state for resuming work |
| [06-weekly/](06-weekly/) | Weekly digests synthesizing what I learned each week |

## Weekly log

<!-- WEEKLY_LOG_START -->
- **Week 2026-32** — a split week: three days of remote-recording DAW playback work (Option 1 stamped stems + Option 2 aligned playback, PRs #63–#67), then a hard pivot to running the resume kit end-to-end on the job-search pipeline. → [full digest](06-weekly/2026-32.md)
- **Week 2026-30** — a single-project week: remote-recording went M1 clock_sync → M2 download pipeline → M3 mesh-talkback with a green libwebrtc go-live build (#39, #40), then hit a wall when live mesh audio broke and the pump fix had to be reverted. → [full digest](06-weekly/2026-30.md)
- **Week 2026-29** — remote-recording arced from hardening to go-live (`api.imavious.org`) to first Windows compile to shipping live presence (#33), while music tooling pivoted from the fretboard-tutor MIDI drill to cloning the iPlug2 plugin framework. → [full digest](06-weekly/2026-29.md)
- **Week 2026-28** — remoter-recording carried the whole week: first interactive plugin testing → real libwebrtc/Opus media engine (#26) → full UI reskin (#29) → M2 go-live prep, closing with restoring the engine build a reskin merge had dropped. → [full digest](06-weekly/2026-28.md)
<!-- WEEKLY_LOG_END -->

For older weeks, see [06-weekly/](06-weekly/).

## How the nightly job works

A scheduled Claude Code task (`scheduled-tasks` MCP, runs daily at 6:00 AM local) walks `~/Claude/` looking for files changed in the previous ~26 hours, plus `git log` across every project repo. It groups changes by workspace, writes a short narrative to `02-notes/auto/YYYY-MM-DD.md`, then commits and pushes. Sensitive folders (`Clients/`, `Job-Search/`) are summarized at the activity-count level only — never specifics.

On Sundays, the same job synthesizes the week's seven auto-notes into a weekly digest in `06-weekly/YYYY-WW.md` and rewrites the "Weekly log" section above with the latest four weeks.
