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
- **Week 2026-27** — remoter-recording went from scaffold to live production (VPS1 coturn/TURN + VPS2 API/Postgres both online, PRs #1–#17), alongside an Ableton SDK REAPER port and a from-scratch browser music-theory learning suite. → [full digest](06-weekly/2026-27.md)
- **Week 2026-26** — Two audio-tooling threads in parallel: remoter-recording born and taken from initial commit through full design docs to a VPS2 API skeleton, plus a serious Articulation Roll editor interaction-design pass. → [full digest](06-weekly/2026-26.md)
- **Week 2026-25** — Six-day Day/Productivity App arc bending from "build the planner" (Mon–Fri: first slice → Tasks UX → planner buildout → 28px lined-paper grid) to "ship the planner" (Sat: Tasks ADHD redesign + Electron mac/Windows packaging + icon + CI + runtime-crash fix, 4 PRs), with a Thu Watch-Party interlude (Firefox/Zen + crash hotfix). → [full digest](06-weekly/2026-25.md)
- **Week 2026-24** — Two parallel ship-it arcs: RiffVault (Grab-Telegram-Bot) from initial commit to HTTPS-live on Netcup, and Ableton SDK's Articulation Roll from passthrough fix to a six-wave UX polish sprint. → [full digest](06-weekly/2026-24.md)
<!-- WEEKLY_LOG_END -->

For older weeks, see [06-weekly/](06-weekly/).

## How the nightly job works

A scheduled Claude Code task (`scheduled-tasks` MCP, runs daily at 6:00 AM local) walks `~/Claude/` looking for files changed in the previous ~26 hours, plus `git log` across every project repo. It groups changes by workspace, writes a short narrative to `02-notes/auto/YYYY-MM-DD.md`, then commits and pushes. Sensitive folders (`Clients/`, `Job-Search/`) are summarized at the activity-count level only — never specifics.

On Sundays, the same job synthesizes the week's seven auto-notes into a weekly digest in `06-weekly/YYYY-WW.md` and rewrites the "Weekly log" section above with the latest four weeks.
