---
date: 2026-05-21
topic: minecraft netcup server setup
type: note
---

# Minecraft Netcup server setup

Raw notes from the session where Avi set up a Minecraft server on a Netcup Ubuntu VPS, accessed from a Mac. Covers admin commands, screen sessions, world migration, RCON, and process management.

## Context

- Server: Netcup Ubuntu VPS, no web/control panel
- Server path: `/opt/mc/server`
- `level-name=world`, `enforce-whitelist=true`, `online-mode=false`, `max-players=5`
- Connecting from a Mac via SSH
- Goal: get the server running persistently, manage it remotely, migrate an existing world

## Admin commands — there is no panel

Without a panel, server commands are issued one of three ways:

1. **In the live console** — attach to the running Minecraft process (via `screen`/`tmux`) and type commands without the leading slash (`op YourName`, `stop`, `whitelist add YourName`).
2. **Edit `ops.json` / `whitelist.json` directly** while the server is stopped.
3. **In-game** after you're op'd — `/gamemode creative`, etc.

## Screen — full setup

- Install: `sudo apt install screen -y`
- Start named session: `screen -S mc`
- Inside the session, start the server:
  ```bash
  cd /opt/mc/server
  java -Xmx4G -Xms2G -jar server.jar nogui
  ```
- `nogui` = no graphical window. Not related to "background" — it just means headless.
- Detach: `Ctrl+A` then `D` (`[detached from <PID>.mc]`)
- List sessions: `screen -ls`
- Reattach: `screen -r mc`
- Force-take an "already attached" session: `screen -d -r mc`
- Kill stale session: `screen -X -S <name> quit`
- Confirm you're inside one: `echo $STY` → prints `<PID>.<name>` if inside

**Gotcha lived through:** screen sessions look identical to normal shells, so re-running `screen -S mc` when you think "nothing happened" silently creates duplicate sessions. Ended up with 6 of them before checking `screen -ls`.

## Why "Closing SSH kills the server" happens

- Cause: the `java` process is attached to the SSH session's controlling terminal. SSH closes → `SIGHUP` → java dies.
- Fix: run java *inside* screen/tmux. Detach with `Ctrl+A D` before closing SSH.
- `nogui` does NOT prevent SSH-disconnect death. It's about windowing, not backgrounding.

## Checking if Minecraft is running

```bash
ps aux | grep -i "[j]ava"
ss -tlnp | grep 25565
screen -ls
```

## Stopping the server

Cleanest → dirtiest:

```bash
# 1. From inside screen — type in console:
stop

# 2. From outside screen, one-liner:
screen -S mc -X stuff "stop$(printf '\r')"

# 3. Via RCON:
mcrcon -H localhost -P 25575 -p <password> "stop"

# 4. Last resort:
ps aux | grep "[j]ava"
kill <PID>
kill -9 <PID>   # only if frozen — risks world corruption
```

## "Server already running" error

Caused by `world/session.lock`. Means another `java` process still has the world locked.

```bash
ps aux | grep "[j]ava"     # find the PID
screen -ls                  # find which screen owns it
screen -r mc                # attach + 'stop'
# or:
kill <PID>
# only if no java process exists:
rm /opt/mc/server/world/session.lock
```

## RCON — the better way

Built-in remote console protocol. Set in `server.properties`:

```properties
enable-rcon=true
rcon.port=25575
rcon.password=<strong password>
broadcast-rcon-to-ops=false
```

Firewall:
```bash
sudo ufw allow 25565/tcp     # players
sudo ufw deny 25575/tcp      # RCON private
sudo ufw enable
```

Client:
```bash
sudo apt install mcrcon -y
mcrcon -H localhost -P 25575 -p <password> -t        # interactive
mcrcon -H localhost -P 25575 -p <password> "stop"    # one-shot
```

From Mac, via SSH tunnel:
```bash
ssh -L 25575:localhost:25575 root@<ip>
brew install mcrcon
mcrcon -H localhost -P 25575 -p <password> -t
```

## systemd service (recommended long-term)

`/etc/systemd/system/minecraft.service`:

```ini
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/mc/server
ExecStart=/usr/bin/java -Xmx4G -Xms2G -jar server.jar nogui
ExecStop=/usr/bin/mcrcon -H localhost -P 25575 -p <password> stop
Restart=on-failure
RestartSec=10
StandardInput=null

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft
sudo systemctl status minecraft
journalctl -u minecraft -f
```

Lets you ditch screen entirely. Auto-restart on crash, auto-start on boot.

## World migration

1. Stop the server.
2. Back up the existing world: `mv world world_old_backup`.
3. Upload local world via `scp -r "/path/to/local/WorldName" root@<ip>:/opt/mc/server/world` (destination must match `level-name=`).
4. Fix ownership: `chown -R root:root world && chmod -R u+rw world`.
5. Start server, watch logs.

**Common "world looks wrong" causes:**
- `level-name` in `server.properties` doesn't match the folder name → server generates a fresh `world/`.
- Uploaded the *saves* parent folder; world dir nested one level too deep.
- Single-player Nether/End structure (`DIM-1/`, `DIM1/`) vs. server-side (`world_nether/`, `world_the_end/`).
- Version mismatch: server older than the world → silent regeneration.
- File permissions blocked java from reading → silent fallback.

Fast diagnostic:
```bash
ls /opt/mc/server/
ls /opt/mc/server/world/
grep -E "level-name|level-type" /opt/mc/server/server.properties
```

## On Mac vs server

- `screen` runs on the **server**, not on the Mac. From the Mac you just `ssh root@<ip>` and use screen there.
- macOS has `screen` preinstalled if you ever need it locally, but there's almost no reason to for this workflow.
- For RCON from Mac: `brew install mcrcon` + SSH tunnel keeps port 25575 private.

## Open items / next steps

- Decide whether to switch from screen to systemd + RCON (recommended).
- Set a strong RCON password and enable RCON in `server.properties`.
- Set up a `mc` wrapper script (`/usr/local/bin/mc`) for one-word RCON commands.
- Whitelist self (`whitelist add YourName`) — `enforce-whitelist=true` is set.
- Resolve the world-import issue (server world doesn't match what was uploaded — likely a `level-name` or folder-nesting issue).
- Consider migrating `TERRAFORM/` folder under `03-projects/` for consistency with the new workspace structure.

## Related

- Polished version of the screen section saved as: `Fresh Obsidian Vault/Screen for Minecraft Server Management.md`
