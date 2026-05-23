# 03-projects

## Room purpose

Hands-on project work. Each project gets its own subfolder with whatever internal structure makes sense for it.

## What lives here

Subfolders, one per project. Examples:
- `minecraft-netcup/` — Minecraft server on a Netcup VPS
- `terraform-sandbox/` — Terraform learning project (note: existing `TERRAFORM/` folder at workspace root should be migrated here eventually)
- `homelab/` — local infrastructure experiments

Each project folder typically has its own `README.md`, config snippets, command logs, and notes.

## Files to load

Only the relevant project's folder. Within it, only the files the current task needs.

## Files to skip

Other projects entirely. General-purpose guides (those live in `01-guides/`).

## Skills to invoke

Project-specific — depends on what the project involves (Terraform, SSH, Docker, etc.).

## Pipeline

1. New project → create `03-projects/<project-name>/` with its own `README.md`.
2. Day-to-day work happens inside the project folder.
3. Reusable patterns get extracted to `01-guides/` or `04-cheatsheets/`.

## When to leave this room

- If you want a reusable how-to → `01-guides/`
- If the project is "done" → consider archiving its folder or moving artifacts to guides.

## Frontmatter for project READMEs

```yaml
---
type: project
status: active | paused | done
started: YYYY-MM-DD
---
```
