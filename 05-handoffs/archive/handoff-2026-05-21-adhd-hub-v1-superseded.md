---
date: 2026-05-22
topic: adhd-hub-v1
status: active
---

# Handoff — ADHD Life Organization Hub v1

## Where we left off (updated 2026-05-22)

Sidecar repo is fully pushed to GitHub (`AviouslyAvi/obsidian-vault-backup`, private). n8n install hit a Node v25 incompat — install steps documented in WORKFLOW-1-STEPS.md, Avi to run. Notion hub already built last session. Keep everything **visually simple** — emojis fine in moderation, no busy templates. ADHD overwhelm is the failure mode.

## What's been done

- 📄 `Fresh Obsidian/Templates/Daily.md` — minimal daily template (12 lines, no clutter)
- 📥 `Fresh Obsidian/00-Inbox.md` — capture file at vault root
- 🚫 `Fresh Obsidian/.gitignore`
- 📦 `~/obsidian-vault-backup/` — sidecar git repo, 529 files, initial commit `c625d00` (sidecar pattern because git inside Google Drive corrupted on `git add`)
- 🔧 `~/obsidian-vault-backup/scripts/sync-and-push.sh` — rsync + commit + push script
- 🗂️ `LEARNING ROADMAP/03-projects/adhd-hub/README.md` — project hub
- 📋 `LEARNING ROADMAP/03-projects/adhd-hub/n8n-workflows/SETUP.md` — full n8n workflow build instructions
- 📐 Plan: `~/.claude/plans/hey-i-wanted-to-streamed-wind.md` (approved)

## Notion hub (built)

Parent page (cantis workspace → twin's workspace):
- 🏠 **ADHD Hub** — `https://www.notion.so/368346ebc599803487e7d7141fce1e77` (id `368346eb-c599-8034-87e7-d7141fce1e77`)
- 📥 **Inbox** DB — `https://www.notion.so/f74f77d73ae647dd8bdc15f6cb4e56b1` (data source `collection://8408b086-1ac4-41dc-8b5f-7ea6803a7dd8`)
- ✅ **Tasks** DB — `https://www.notion.so/5dfda4552a2544e68b3ea2508dc181db` (data source `collection://a10ed4dd-bdc1-452b-92a8-8acb86d951e9`)
- 📝 **Quick Journal** DB — `https://www.notion.so/6012c1c73ac14ce489d717a404b2e56a` (data source `collection://6e89fd94-d626-4a88-8ba7-c2114098664f`)

## What just got done (2026-05-22 session)

- ✅ Private GitHub repo created: https://github.com/AviouslyAvi/obsidian-vault-backup
- ✅ Initial vault snapshot pushed (rebuilt as 4 small commits — single push kept failing due to LibreSSL bad-record-mac in Apple's bundled git; fixed by installing brew git + `gh auth setup-git` as credential helper)
- ✅ `~/obsidian-vault-backup/scripts/sync-and-push.sh` written + chmod +x (uses /opt/homebrew/bin/git so credential helper resolves correctly)
- ✅ `03-projects/adhd-hub/n8n-workflows/WORKFLOW-1-STEPS.md` written — one-screen guide
- ⚠️ n8n install blocked: system Node is v25, n8n's `isolated-vm` needs ≤ node 22. Solution in WORKFLOW-1-STEPS.md is `brew install node@22` first.

## Immediate next step

1. Run the install block at the top of `WORKFLOW-1-STEPS.md`:
   ```
   brew install node@22
   echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   npm install -g n8n
   N8N_SECURE_COOKIE=false n8n start
   ```
2. Build workflow #1 per the steps in that file (2 nodes — Schedule + Execute Command).
3. Test once → verify a commit lands in the GitHub repo → toggle Active.
4. Then workflows 2/3/4 (Notion → Obsidian sync) per `SETUP.md`.
5. Wire Obsidian Daily Notes plugin → `Templates/Daily.md`, folder `Journal/`, format `YYYY-MM-DD`.
6. Notion: customize Tasks DB views (Today / This Week / Someday) — optional.

## Open decisions / blockers

- 🟢 Resolved: GitHub repo created (private, HTTPS auth via gh credential helper).
- 🟡 Node version: switch to `node@22` for n8n (system stays on v25 for everything else — brew node@22 is keg-only so it only activates via the PATH export).
- 🟡 Notion page integration share: still required before workflows 2/3/4 (Notion → Obsidian). Workflow 1 doesn't need it.

## Visual style guidelines (carry forward to new chat)

- 🚫 No multi-section templates with 6+ headers
- ✅ Emojis OK but used sparingly — one per major item, not decorative noise
- ✅ One screen of content per page
- ✅ "If in doubt, strip a section"
- 🚫 Don't propose v2 rooms (lumora, finance, music, etc.) yet — v1 must run sticky for 14 days first

## Files touched

- `/Users/aviouslyavi/Library/CloudStorage/GoogleDrive-<email-redacted>/My Drive/Documents/Fresh Obsidian/Templates/Daily.md`
- `/Users/aviouslyavi/Library/CloudStorage/GoogleDrive-<email-redacted>/My Drive/Documents/Fresh Obsidian/00-Inbox.md`
- `/Users/aviouslyavi/Library/CloudStorage/GoogleDrive-<email-redacted>/My Drive/Documents/Fresh Obsidian/.gitignore`
- `/Users/aviouslyavi/obsidian-vault-backup/` (entire repo, including `scripts/sync-and-push.sh`)
- `/Users/aviouslyavi/Claude/Professional Development/LEARNING ROADMAP/03-projects/adhd-hub/README.md`
- `/Users/aviouslyavi/Claude/Professional Development/LEARNING ROADMAP/03-projects/adhd-hub/n8n-workflows/SETUP.md`
- `/Users/aviouslyavi/.claude/plans/hey-i-wanted-to-streamed-wind.md`

## Resume prompt

```text
Resume the ADHD Hub v1 build.

Read this handoff FIRST:
/Users/aviouslyavi/Claude/Professional Development/LEARNING ROADMAP/05-handoffs/active/handoff-2026-05-21-adhd-hub.md

Then the workflow guide:
/Users/aviouslyavi/Claude/Professional Development/LEARNING ROADMAP/03-projects/adhd-hub/n8n-workflows/WORKFLOW-1-STEPS.md

Where we left off: GitHub repo is pushed. n8n install needs node 22 (system has node 25). Next step is `brew install node@22`, then `npm install -g n8n`, then build workflow #1 (Schedule Trigger → Execute Command running sync-and-push.sh). Keep it visually SIMPLE — emojis sparingly, one screen per page.
```
