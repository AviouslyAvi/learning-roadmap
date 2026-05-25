# 04-cheatsheets

## Room purpose

Concise quick-reference cards. One topic per file, scannable at a glance. The opposite of `01-guides/` — guides explain *why*, cheatsheets just list *what*.

## What lives here

One short `.md` per topic.

Current cheatsheets:
- [screen.md](screen.md) — GNU `screen` session/window/split quick ref
- [ubuntu-server.md](ubuntu-server.md) — Ubuntu server admin: files, perms, systemd, networking, ssh, scp/rsync, apt, ufw, security

Planned:
- `git.md` — git command quick ref
- `terraform.md` — terraform CLI quick ref

## Files to load

Just the specific cheatsheet relevant to the task.

## Files to skip

Everything else.

## Skills to invoke

None specific.

## Pipeline

Cheatsheets are usually distilled from `01-guides/` or `02-notes/` after Avi has used a tool enough to know what the actually-useful commands are.

## When to leave this room

- If the task needs explanation, not just commands → `01-guides/`

## Frontmatter

```yaml
---
type: cheatsheet
tool: <tool name>
updated: YYYY-MM-DD
---
```
