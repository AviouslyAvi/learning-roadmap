---
title: ADHD Hub
status: v2.1
---

# ADHD Life Hub — v2.1

One home for capture, tasks, projects, notes, journaling, learning, practice.
Each tool has one job. Mobile capture is two taps. System has an explicit downgrade path.

Full design rationale: `~/.claude/plans/tidy-coalescing-torvalds.md`

## Tool roles

| Tool | One job |
|---|---|
| Google Calendar | Time-blocked events only |
| Notion | Dashboard, Inbox, Tasks, Projects, Notes |
| Obsidian | Long-form notes + daily journal |
| GitHub | Code repos + vault backup mirror |
| n8n | Backup + evening inbox digest |

## Daily loop

- 🌅 **Morning** — open Notion dashboard, pick one ☀️ Today task
- 📱 **Throughout day** — Lock-screen Capture shortcut → 📥 Inbox
- 🌙 **Evening** — Obsidian daily note (5 fields), sweep Inbox

---

## What's built (auto, 2026-05-22)

### Notion (extended from v1)
- 🏠 **ADHD Hub** dashboard — https://www.notion.so/368346ebc599803487e7d7141fce1e77
  - Rebuilt body: loop, tools, 4 DB embeds, downgrade path, kill criteria
- 📥 **Inbox** DB — extended with `Swept` (checkbox) + `Source` (mobile/web/desktop/email)
  - `https://www.notion.so/f74f77d73ae647dd8bdc15f6cb4e56b1`
  - data source: `collection://8408b086-1ac4-41dc-8b5f-7ea6803a7dd8`
- ✅ **Tasks** DB — Area→multi-select, Status expanded, +Energy, +Context, +Project relation
  - `https://www.notion.so/5dfda4552a2544e68b3ea2508dc181db`
  - data source: `collection://a10ed4dd-bdc1-452b-92a8-8acb86d951e9`
- 🎯 **Projects** DB (new) — Status / Area / GitHub / Due / Next action
  - `https://www.notion.so/283352bcb2be408194448b8d5e6fa9b9`
  - data source: `collection://e97dcf38-3bb8-49d6-8d38-b549d37905e3`
- 📚 **Notes** DB (new) — catch-all: Type (practice/inspiration/resource/tutorial/reference) + Area + URL + Obsidian backlink + Project relation
  - `https://www.notion.so/1e725c742df34336a7627a6237061977`
  - data source: `collection://fa6ebb9a-0344-44ae-a91b-808bde8d8a51`
- 📝 **Quick Journal** DB — preserved at bottom of dashboard, marked Legacy (journaling moves to Obsidian)

**Areas (multi-select, identical across Tasks/Notes/Projects):**
lumora, foxglove, music, learning, personal, health, finance, home, creative

### Obsidian (additive — no existing notes moved)
- `START_HERE.md` at vault root — folder map + AI-routing hint
- `01-Daily/` `02-Projects/` `03-Areas/` `04-Resources/` `05-Archive/` folders created
- `Templates/Daily.md` rewritten — 5 named fields (Win · Focus tomorrow · Energy · Open loop · Captured)

### Already in place from v1
- `~/obsidian-vault-backup/` sidecar git repo → https://github.com/AviouslyAvi/obsidian-vault-backup
- `~/obsidian-vault-backup/scripts/sync-and-push.sh`
- `00-Inbox.md` capture file
- `.gitignore`

---

## What YOU need to do (manual; I couldn't from CLI)

### 1. Wire Obsidian Daily Notes plugin (2 min)

Settings → Core plugins → enable **Daily notes**, then Settings → Daily notes:
- Date format: `YYYY-MM-DD`
- New file location: `01-Daily`
- Template file location: `Templates/Daily`

### 2. Build 3 Notion DB templates (~5 min, in Notion UI)

Database templates aren't creatable via API. In the Notion app:

**Projects DB → New ▾ → "+ New template":**
- Pre-fill: Status = active, prompt for Next action

**Notes DB → New ▾ → "+ New template":**
- Title: `Practice session` — pre-fill Type = practice, today's date
- Body stub: `**Instrument:** \n**Focus:** \n**Duration:** \n**Notes:** \n`

**Hub page → new sub-page `Weekly review YYYY-WW`:**
- 5 prompts: wins / drops / next-week focus / one project to move / one thing to archive

### 3. Mobile capture (Phase 2 — ~45 min, iPhone)

a. **Notion integration token** — notion.so → Settings → Connections → Develop or manage integrations → New internal integration. Copy the secret. Share each of the 4 DBs with the integration (Open DB → ⋯ → Connections → add).

b. **Apple Shortcut "Capture"** — Shortcuts app:
   - Action: "Ask for Input" (text, prompt "What?")
   - Action: "Get Contents of URL" → POST `https://api.notion.com/v1/pages`
     - Headers: `Authorization: Bearer <token>`, `Notion-Version: 2022-06-28`, `Content-Type: application/json`
     - Body:
       ```json
       {
         "parent": {"database_id": "f74f77d73ae647dd8bdc15f6cb4e56b1"},
         "properties": {
           "Text": {"title": [{"text": {"content": "PROVIDED_INPUT"}}]},
           "Source": {"select": {"name": "mobile"}}
         }
       }
       ```
   - Add to Home Screen + Lock Screen widget

c. **Apple Shortcut "New Task"** — same pattern, parent = Tasks DB `5dfda4552a2544e68b3ea2508dc181db`. Add a "Choose from Menu" for due date (Today / Tomorrow / Pick).

d. **Notion iOS app → Lock Screen widget** — pin the Inbox DB widget.

e. **Notion Web Clipper** — install on desktop + iOS Safari. Default target: Notes DB, Type=inspiration.

### 4. n8n (Phase 4 — blocked on node@22 install)

See `n8n-workflows/WORKFLOW-1-STEPS.md`. Install block:

```
brew install node@22
echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
npm install -g n8n
N8N_SECURE_COOKIE=false n8n start
```

Then build:
- **W1 — Vault backup**: Schedule Trigger (every 2h) → Execute Command (`~/obsidian-vault-backup/scripts/sync-and-push.sh`)
- **W2 — Evening Inbox digest** (8pm): Notion node query Inbox where `Swept != true` → format as markdown list → append to `01-Daily/<today>.md` under `## Unswept inbox`

### 5. (Optional) Migrate stale flat-root Obsidian notes

Don't bulk-move. **Only when you touch one**, drop it into `04-Resources/` (tutorials/dev notes) or `03-Areas/` (life-domain stuff). Lazy migration = no startup tax.

---

## Downgrade path

- 🆘 Bad day → just open 📥 Inbox once. That's it.
- 🪫 Worse → Inbox + write the Energy number in the Daily note.
- 💀 Fully off → no catch-up. Resume tomorrow. **Backlog is not debt.**

## 14-day kill criteria

Honest review on 2026-06-05:
- Opening the dashboard daily? If no → kill dashboard, keep only Inbox + Tasks
- Filling Daily note 3+/week? If no → drop daily note
- Inbox shrinking week-over-week? If no → too many capture surfaces
- Practice sessions logged? If no → drop the practice view

System gets smaller every 2 weeks until it stops shrinking.

## Don't add yet

- ❌ Phase 2 automations (W3 GitHub→Project) — wait until W1 + W2 run clean
- ❌ Calendar mirror, weekly email, iOS webhook — explicitly out of scope
- ❌ New Areas, new Notes types — change only after 14-day review
