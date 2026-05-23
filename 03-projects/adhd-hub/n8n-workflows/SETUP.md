# n8n setup — ADHD hub v1

## Prerequisites

- Docker Desktop running on the Mac
- Private GitHub repo `obsidian-vault-backup` created, SSH key from this Mac added to GitHub
- Notion integration token (https://www.notion.so/my-integrations)
- Notion DBs created and shared with the integration:
  - **Inbox** — properties: `Text` (title), `Created` (created time)
  - **Tasks** — properties: `Title` (title), `Status` (select: todo/doing/done), `Due` (date), `Area` (select), `Notes` (rich text)
  - **Quick Journal** — properties: `Entry` (title), `Created` (created time), `Body` (rich text)

## Start n8n

```bash
docker run -d --name n8n -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  -v "/Users/aviouslyavi/Library/CloudStorage/GoogleDrive-<email-redacted>/My Drive/Documents/Fresh Obsidian:/vault" \
  -v "/Users/aviouslyavi/obsidian-vault-backup:/backup" \
  -v ~/.ssh:/home/node/.ssh:ro \
  docker.n8n.io/n8nio/n8n
```

Open http://localhost:5678 and create your owner account.

## Workflows (import in this order)

### 1. `obsidian-nightly-backup.json` — START HERE

Build it first because it doesn't depend on Notion:

1. **Schedule Trigger** — daily at 02:00
2. **Execute Command** — `bash /backup/scripts/sync-and-push.sh`
3. Test by running it manually. Verify a commit appears in GitHub.

The script (create at `~/obsidian-vault-backup/scripts/sync-and-push.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail
VAULT="/Users/aviouslyavi/Library/CloudStorage/GoogleDrive-<email-redacted>/My Drive/Documents/Fresh Obsidian/"
REPO="/Users/aviouslyavi/obsidian-vault-backup/"
cd "$REPO"
rsync -a --delete \
  --exclude='.git' \
  --exclude='.obsidian/workspace*' \
  --exclude='.obsidian/cache' \
  --exclude='.DS_Store' \
  --exclude='.trash' \
  "$VAULT" "$REPO"
git add -A
if ! git diff --cached --quiet; then
  git commit -m "auto: $(date -Iseconds)"
  git push origin main
fi
```

Make it executable: `chmod +x ~/obsidian-vault-backup/scripts/sync-and-push.sh`

**Note:** This runs from your Mac, not from inside the n8n container — easier auth (your existing SSH key just works). If n8n is in Docker, use Execute Command with `ssh aviouslyavi@host.docker.internal '/path/to/script.sh'` OR run n8n natively via `npx n8n` instead.

### 2. `notion-inbox-to-obsidian.json`

1. **Notion Trigger** — Page added in Inbox DB
2. **Function** — format as markdown line: `- ${text}  <!-- ${created_at} -->`
3. **Read Binary File** — `/vault/00-Inbox.md`
4. **Function** — append new line under `## Today`
5. **Write Binary File** — back to `/vault/00-Inbox.md`

### 3. `notion-tasks-to-obsidian.json`

1. **Notion Trigger** — Page added/updated in Tasks DB
2. **Function** — slugify title, build Obsidian Tasks syntax:
   ```
   - [ ] {{title}} 📅 {{due}} #area/{{area}}
   {{notes}}
   ```
3. **Write Binary File** — `/vault/Tasks/{{slug}}.md` with frontmatter

### 4. `notion-journal-to-obsidian.json`

1. **Notion Trigger** — Page added in Quick Journal DB
2. **Function** — compute today's date, build path `/vault/Journal/YYYY-MM-DD.md`
3. **Read Binary File** — try to read existing journal (if 404, create from `Templates/Daily.md`)
4. **Function** — append entry body under `## 📥 Notes / Inbox sweeps`
5. **Write Binary File** — back to dated journal file

## Verification checklist

- [ ] Workflow 1 runs nightly, produces a GitHub commit, no errors in execution log
- [ ] Add a row in Notion Inbox → appears in `00-Inbox.md` within 5 min
- [ ] Add a task in Notion Tasks → file appears in `Tasks/`
- [ ] Add a Quick Journal entry → today's `Journal/YYYY-MM-DD.md` updated

## Troubleshooting

- **Drive file is a stub** — n8n's Read File errors with "short read" or "no such file". Open the file in Finder once to materialize it, or use Drive UI → "Make available offline" on the whole vault folder.
- **Git push fails from cron** — SSH agent isn't running. Use a deploy key on the Mac instead, or run n8n natively (not in Docker) so it inherits your shell's ssh-agent.
- **Notion webhook missing events** — switch to a 5-min poll trigger if you're on the free Notion plan.
