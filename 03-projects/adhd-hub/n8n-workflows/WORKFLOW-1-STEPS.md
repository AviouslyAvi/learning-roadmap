# Workflow 1 — Nightly Obsidian Backup

The first n8n workflow you'll build. No Notion dependency, so this is the cleanest place to learn n8n's mental model: **trigger → action**. Two nodes, ten minutes, free off-site backup forever.

---

## 0. Sanity check first (do this BEFORE n8n)

n8n is just a scheduler — the actual work happens in the bash script. So validate the script standalone first. If it works in your shell, it'll work in n8n. If it doesn't work in your shell, n8n won't magically fix it.

```bash
bash ~/obsidian-vault-backup/scripts/sync-and-push.sh
```

What should happen:
1. `rsync` mirrors the vault into `~/obsidian-vault-backup/` (silent if nothing changed)
2. `git add -A` stages whatever changed
3. If there are changes → commit with message `auto: 2026-05-22T...` and push to GitHub
4. If nothing changed → prints `no changes` and exits clean

After it runs, check https://github.com/AviouslyAvi/obsidian-vault-backup/commits — you should see an `auto: ...` commit, OR the page still shows the four `chunk N:` commits from setup if nothing in the vault has changed yet.

**If this step fails, stop and fix the script before touching n8n.** Common script failures:

| What you see | Why | Fix |
|---|---|---|
| `Permission denied` on the script itself | Not executable | `chmod +x ~/obsidian-vault-backup/scripts/sync-and-push.sh` |
| `rsync: ...: No such file or directory` on vault files | Google Drive files are stub placeholders, not real bytes | Finder → right-click `Fresh Obsidian` folder → "Make available offline" |
| `fatal: could not read Username for 'https://github.com'` | Credential helper not wired | `gh auth setup-git` (one time) |
| `Permission denied (publickey)` | You configured SSH but the key isn't on GitHub | Either add the key (`gh ssh-key add ~/.ssh/id_ed25519.pub` after refreshing scope) or switch remote to HTTPS: `git remote set-url origin https://github.com/AviouslyAvi/obsidian-vault-backup.git` |

Once you've seen the script work cleanly twice — once with changes, once with nothing to commit — move on.

---

## 1. Install n8n (one time, ~3 minutes)

Your system Node is v25.8.1. n8n bundles a native module (`isolated-vm`) that doesn't compile against Node 25 yet. Install Node 22 alongside (keg-only, won't touch your system Node):

```bash
brew install node@22
echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
node --version    # confirm v22.x
npm install -g n8n
n8n --version     # confirm install
```

**Why keg-only matters:** brew won't symlink node@22 into `/opt/homebrew/bin` by default — that line you added to `.zshrc` is the only thing making it the active version in your shell. If you ever open a fresh terminal and `node --version` shows v25 again, your shell didn't pick up the .zshrc change — restart the terminal or `source ~/.zshrc` again.

If you ever want to remove node@22 cleanly: `brew uninstall node@22` and delete the PATH line.

---

## 2. Start n8n

```bash
N8N_SECURE_COOKIE=false n8n start
```

You'll see a wall of startup logs ending with something like:

```
Editor is now accessible via:
http://localhost:5678/
```

Open that in a browser. First run only, n8n asks for:
- Owner email + password — pick anything, this is local-only
- Optional onboarding survey — skip it

You land on the **Workflows** screen, empty.

**Leave that terminal running** — n8n stops if you close it. (Later, you can run it as a launchd service so it survives reboot. Not now — get one workflow working first.)

---

## 3. Build the workflow

### 3a. Create the workflow

- Top right → **Add workflow** (or `+ New`).
- Name it `obsidian-nightly-backup` (top-left of the canvas, click the placeholder name).

You're now on the empty canvas with one big `+` button in the middle.

### 3b. Add the Schedule Trigger

- Click the `+` in the middle of the canvas.
- A right-side panel opens: "What triggers this workflow?"
- Search box → type `schedule`.
- Pick **Schedule Trigger**.

The trigger node lands on the canvas. A config panel opens on the right:

- **Trigger Rules**: leave the default single rule.
- Click it to expand → set:
  - **Trigger Interval**: `Days`
  - **Days Between Triggers**: `1`
  - **Trigger at Hour**: `2am`
  - **Trigger at Minute**: `0`
- Close the right panel (X top-right, or click outside).

### 3c. Add the Execute Command node

- Hover over the right edge of the Schedule Trigger node — a small `+` appears.
- Click it → search panel reopens.
- Search `execute command` → pick **Execute Command**.

Config panel for Execute Command:

- **Command**: `/Users/aviouslyavi/obsidian-vault-backup/scripts/sync-and-push.sh`
  - Use the full path. n8n's working directory isn't your home dir, so `~` won't expand reliably.
- **Working Directory**: leave blank (the script `cd`s to the repo itself).
- Close the panel.

Your canvas now shows two connected nodes:

```
[Schedule Trigger]  ──►  [Execute Command]
```

That's the whole workflow.

### 3d. Test it manually

- Bottom of the screen, click **Execute Workflow** (or the play button on the Execute Command node).
- Each node gets a green checkmark when it runs successfully.
- Click the Execute Command node to see its output panel — you should see the script's stdout (`auto: ...` commit hash, or `no changes`).

### 3e. Verify on GitHub

Open https://github.com/AviouslyAvi/obsidian-vault-backup/commits/main. If the script saw changes, the top commit is fresh (`auto: 2026-05-22T...`). If not, the top is still `chunk 4: remaining vault contents`. Both are fine — both mean the workflow works end-to-end.

### 3f. Activate it

- Top right of the workflow → toggle the **Active** switch on.
- This is what enables the schedule. **Without this, the cron never fires** — manual `Execute Workflow` runs work either way, but the nightly run won't happen until Active is toggled on.

Done.

---

## 4. What's actually happening at 2am

When the schedule fires:
1. n8n's internal scheduler kicks the workflow.
2. Execute Command runs your bash script as your user (since n8n is running in your shell session).
3. The script rsyncs the vault → stages diffs → commits with a timestamped message → pushes via HTTPS using the `gh` credential helper.
4. n8n logs the execution under **Executions** in the left sidebar — you can review history there.

The whole thing takes ~5–30 seconds depending on diff size.

---

## 5. Troubleshooting (real failures)

| Symptom | Diagnosis | Fix |
|---|---|---|
| Workflow shows red `❌` on Execute Command, error is `Command failed: ...` | Script exits non-zero | Click the node, open the error panel, scroll the stderr — it's almost always one of the script-level failures from §0 |
| Test passes but nightly never fires | Active toggle is off, OR n8n process died overnight | Check Active toggle. Check `n8n start` terminal is still running — if you closed it, the schedule stops |
| Test passes but no commit appears | The vault genuinely had no changes since the last commit | This is correct behavior — the script only commits on diff. Edit a file in the vault, re-test |
| `n8n: command not found` after a reboot | New shell didn't pick up node@22 PATH | `source ~/.zshrc`, or open a fresh terminal |
| n8n UI loads but workflow won't activate | Sometimes n8n needs a credential reset for the Schedule node | Open node, hit Save again, then re-toggle Active |

---

## 6. After this works

Workflows 2, 3, 4 (Notion → Obsidian sync) are in [`SETUP.md`](SETUP.md). They depend on:
- Notion integration token added to n8n's credentials
- Notion parent page shared with the integration (still pending from last session)
- The three Notion DBs already exist — IDs in the [handoff doc](../../../05-handoffs/active/handoff-2026-05-21-adhd-hub.md)

Do **not** build all four at once. Let workflow 1 run for 3–5 nights and prove itself first. If the backup is reliable, you have a safety net for everything else.

---

## 7. Making n8n survive a reboot (optional, later)

Right now `n8n start` dies if you close the terminal or restart the Mac. Two options when you're ready:

- **Quick:** `brew services` doesn't ship an n8n formula. Use `pm2` instead:
  ```bash
  npm install -g pm2
  pm2 start n8n -- start
  pm2 save
  pm2 startup    # follow its instructions to install launchd hook
  ```
- **Cleaner:** write a launchd plist at `~/Library/LaunchAgents/com.avi.n8n.plist`. Notes for that can live in this folder later.

Skip this section until workflow 1 has run successfully for at least a week. ADHD trap: don't yak-shave the daemon before the workflow has earned its keep.
