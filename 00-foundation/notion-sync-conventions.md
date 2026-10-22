---
type: foundation
updated: 2026-05-25
---

# Notion sync conventions

How notes flow from this Obsidian vault into the public-facing Notion documentation database.

## Stack

- **Plugin:** [Share to NotionNext](https://github.com/jxpeng98/obsidian-to-NotionNext) (jxpeng98/obsidian-to-NotionNext), Obsidian community plugin.
- **Destination DB:** `Avi's Workspace → Documentation` — Notion DB ID `36ad9bfad53a8000af1ce237992b3cef`.
- **Direction:** one-way (Obsidian → Notion). Obsidian is the source of truth. Edits made in Notion will be overwritten on the next sync.
- **Trigger:** manual (run "Share to NotionNext" from the command palette per note). Auto-sync is available but disabled by default to keep "publish" a deliberate gesture.

## Opt-in model

A note only syncs if it carries `autosync-database: [docs]` in its frontmatter. No frontmatter → no sync. This is the safe default — sensitive content (client work, job search, raw daily logs) cannot leak unless explicitly flagged.

## Frontmatter shape

**Important:** the Share to NotionNext plugin matches frontmatter keys to Notion property names by **exact name** (case-sensitive on Tag/Date — Category seems case-insensitive but capitalize anyway for safety). Frontmatter key MUST equal Notion column name.

```yaml
---
type: cheatsheet                 # room-specific, not synced
updated: 2026-06-01              # not synced
autosync-database: [docs]        # tells the plugin to sync this note
Category: Technology             # → Notion Select  "Category"  (life domain)
Tag: [Guide/Reference]           # → Notion Multi-select  "Tag"  (note type)
Date: 2026-05-23                 # → Notion Date    "Date"  (when the note was created)
---
```

After the first sync the plugin auto-injects `NotionID-docs: <page-id>`. Leave it alone — that's how the plugin updates the existing row instead of creating duplicates.

### Why no `Project` field

The Notion `Projects` column is a **Relation** (linked to a separate Projects database), not a Select. Relations require a Notion page UUID, which Share to NotionNext can't write from frontmatter. **Workflow:** sync the note from Obsidian, then in Notion open the row and link the Project relation manually. (1 click per note.)

## Controlled vocabulary

**Stick to these exact values.** Anything else creates a duplicate Select option in Notion. Match is case- and spelling-sensitive.

### Category (one per note — life domain)

`Finance` | `Games` | `Health` | `Music` | `Research` | `Self-Development` | `Spiritual` | `Technology` | `Work`

### Tag (one or more per note — note type)

`Guide/Reference` | `Comparison` | `Research` | `Project`

### Picking the right values

| If the note is… | Category | Tag |
|---|---|---|
| A how-to or cheatsheet for a tech tool | Technology | Guide/Reference |
| Comparing options before a purchase / decision | (domain) | Comparison |
| Deep notes from learning a new topic | (domain) | Research |
| Running log / artifacts for a specific hands-on project | (domain) | Project |
| A note that's both a guide AND tied to a project | (domain) | [Guide/Reference, Project] |

## Plugin property mapping (Share to NotionNext settings)

In Obsidian → Settings → Share to NotionNext → `Docs` database → properties section, confirm these mappings exist:

| Property # | Notion property name | Notion type |
|---|---|---|
| Title | `Name` | Title |
| Property 1 | `Category` | Select |
| Property 2 | `Tag` | Multi-Select |
| Property 3 | `Date` | Date |

**Do NOT add a Property 4 for `Projects`.** It's a Relation in Notion and the plugin can't write to it. Link it manually in Notion when needed.

### Adding new vocabulary

If you genuinely need a new Category or Tag, **add it in Notion first** (click the column header → Select an option or create one → add it with the color you want), THEN start using it in Obsidian frontmatter. Don't let Obsidian auto-create options — they get assigned random colors and look like junk.

## What syncs vs what doesn't

| Folder | Syncs? | Reason |
|---|---|---|
| `00-foundation/` | Selectively | Add the frontmatter flag only to docs you want public |
| `01-guides/` | ✅ Yes by default | The public-wiki content |
| `02-notes/` | ❌ No | Raw notes, daily logs, error traces — not wiki-grade |
| `02-notes/auto/` | ❌ No | Machine-generated daily logs |
| `03-projects/` | Selectively | Project READMEs and polished writeups, not WIP |
| `04-cheatsheets/` | ✅ Yes by default | Quick references — perfect for the wiki |
| `05-handoffs/` | ❌ No | Session state, not reference material |
| `06-weekly/` | ❌ No | Auto-generated weekly digests |
| `TERRAFORM/` | Decide per file | Add the flag if a file is wiki-ready |

## Gotchas (learned from plugin docs)

- 5 MB attachment limit per file.
- Auto-sync (if you ever enable it) skips notes that contain embedded attachments — use manual sync for those.
- Wikilinks (`[[note]]`) get rendered as plain text in Notion unless the target note is also synced.
- Notion API rate limit is ~3 req/sec; bulk-syncing 100+ notes at once will throttle. Sync in batches of ~20.
- One-way means deletions don't propagate. If a note is deleted in Obsidian, manually delete the matching Notion row.

## Publishing layer

The synced DB becomes a public wiki via **Notion Sites**.

- A `.notion.site` subdomain is free on any Notion plan.
- A custom domain requires Notion Plus (or higher) **and** the Custom Domain add-on (~$8–10/mo). If you don't want to pay, the `.notion.site` URL is free forever and you can put Cloudflare in front of it later if you change your mind.
