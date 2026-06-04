---
room: 03-projects
project: minecraft-netcup
type: runbook
date: 2026-05-31
goal: Move both servers off root onto the mc service account, managed by systemd
---

# Runbook — migrate both servers to the `mc` user + systemd

Decision (2026-05-31): **keep both servers**, each with its own systemd unit, both running as `mc`. Back up server-side first.

## How systemd works (the short version)

`systemd` is Debian's init system — PID 1, the first process the kernel starts, the parent of everything else. Its job is to **start, stop, supervise, and restart long-running services** ("daemons") in a controlled way. A "service" is described by a **unit file** (`*.service`), a plain-text config in `/etc/systemd/system/`.

Why it beats `screen` for a game server:
- **Survives reboots.** `enable` a unit and systemd starts it automatically on boot. A screen session dies on reboot and you have to SSH in to restart it.
- **Auto-restart on crash.** `Restart=on-failure` brings the server back if the JVM dies.
- **Runs as the right user.** `User=mc` means systemd launches the process as `mc`, every time — you can't fat-finger it back to root.
- **Sandboxing.** Directives like `ProtectSystem`, `NoNewPrivileges`, `ProtectHome` lock the process into a restricted view of the filesystem.
- **One control surface + unified logs.** `systemctl start/stop/status`, logs via `journalctl -u <name>`.

Anatomy of a unit file:
```ini
[Unit]                       # metadata + ordering
Description=...
After=network-online.target  # start after the network is up

[Service]                    # how to run it
Type=simple                  # the ExecStart process IS the service (doesn't fork)
User=mc                      # <-- run as mc, not root
WorkingDirectory=/opt/mc/...
ExecStart=/usr/bin/java ...  # the command to launch
ExecStop=...                 # how to stop it gracefully
Restart=on-failure

[Install]                    # what `systemctl enable` hooks into
WantedBy=multi-user.target   # start at normal multi-user boot
```

Everyday commands:
```bash
systemctl daemon-reload                 # re-read unit files after editing
systemctl enable  minecraft-vanilla     # start on boot (creates the symlink)
systemctl start   minecraft-vanilla     # start now
systemctl stop    minecraft-vanilla     # stop now (runs ExecStop)
systemctl restart minecraft-vanilla
systemctl status  minecraft-vanilla     # is it running? recent log lines
journalctl -u minecraft-vanilla -f      # follow the live log
```

**Stopping a Minecraft server gracefully** matters: you want it to run the in-game `stop` command so it saves chunks and writes player data, NOT just `SIGKILL` the JVM (which can corrupt the world). Two ways the units below do this:
- **Vanilla:** RCON — `mcrcon` sends the `stop` command over the admin port. Needs `enable-rcon=true` + a password.
- **Arclight:** no RCON configured, so we send `stop` to its console another way (a named pipe / `screen -X stuff`, or enable RCON later). For now we keep it simple and document the tradeoff.

## Pre-flight facts (verified 2026-05-31)

- `mc` = uid 101, gid 103, home `/opt/mc`, shell `/bin/bash`.
- `mcrcon` installed at `/usr/local/bin/mcrcon`.
- Vanilla: `/opt/mc/server`, port 25565, `server.jar` (Paper), system `java`.
- Arclight: `/opt/mc/Arclight Server`, port 25564, launches via `run.sh` using `java-21-openjdk-arm64`.
- Existing `/etc/systemd/system/minecraft.service` (vanilla, `User=mc`) is dead since 05-21 due to root-owned files. We will repair/replace it.

## Procedure

### 0. Back up (server-side tar)
```bash
mkdir -p /opt/mc/backups
tar czf /opt/mc/backups/vanilla-world-$(date +%F).tar.gz -C /opt/mc/server world
tar czf /opt/mc/backups/arclight-world-$(date +%F).tar.gz -C "/opt/mc/Arclight Server" world
```
(Adjust `world` if `level-name` differs. Vanilla `level-name=world`.)

### 1. Stop both servers gracefully
They're in screen as root:
```bash
screen -S Minecraft     -p 0 -X stuff "stop\n"   # vanilla
screen -S MinecraftDogs -p 0 -X stuff "stop\n"   # arclight
```
Wait for both JVMs to exit (watch `ps -ef | grep [j]ava`).

### 2. Fix ownership
```bash
chown -R mc:mc /opt/mc/server "/opt/mc/Arclight Server"
```

### 3. Enable RCON on vanilla (for clean systemd stop)
Edit `/opt/mc/server/server.properties`:
```
enable-rcon=true
rcon.port=25575
rcon.password=<generate-a-strong-one>
```
RCON binds to all interfaces by default — keep it private (firewall 25575, or it's only reached locally by mcrcon over 127.0.0.1).

### 4. Write two systemd units
`/etc/systemd/system/minecraft-vanilla.service` — repair of the existing unit (already `User=mc`, Aikar flags, mcrcon stop). Confirm `WorkingDirectory=/opt/mc/server`.

`/etc/systemd/system/minecraft-arclight.service`:
```ini
[Unit]
Description=Minecraft Arclight (modded) Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=mc
Group=mc
WorkingDirectory=/opt/mc/Arclight Server
ExecStart=/opt/mc/Arclight Server/run.sh
# Graceful stop: send "stop" to the server console (see note above)
Restart=on-failure
RestartSec=10
SuccessExitStatus=0 143
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
ReadWritePaths=/opt/mc

[Install]
WantedBy=multi-user.target
```

### 5. Enable + start as mc
```bash
systemctl daemon-reload
systemctl disable minecraft.service           # retire old name if replacing
systemctl enable --now minecraft-vanilla.service
systemctl enable --now minecraft-arclight.service
```

### 6. Verify
```bash
systemctl status minecraft-vanilla minecraft-arclight --no-pager
ps -eo pid,user,args | grep '[j]ava'          # both should show user 'mc'
ss -tlnp | grep -E '25564|25565'              # both ports listening
journalctl -u minecraft-arclight -n 30 --no-pager  # world loaded, no perm errors
```

### 7. (Optional, recommended) Add swap
```bash
fallocate -l 2G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## As-built (executed 2026-05-31)

Done together over SSH. What actually happened vs. the plan:
- Backups: `/opt/mc/backups/vanilla-world-2026-05-31.tar.gz` (172 M), `arclight-world-2026-05-31.tar.gz` (303 M).
- Both servers stopped cleanly (3 s, "All dimensions are saved"); leftover empty `screen` sessions quit.
- `chown -R mc:mc` on both dirs — this fixed the exact files (`logs/latest.log`, `world/session.lock`) that caused the May 21 crash.
- RCON enabled on **both**: vanilla `:25575`, Arclight `:25576`. Passwords are random `openssl rand -hex 16`, stored only in each `server.properties` (mode `640`, owner `mc`). Retrieve with `grep ^rcon.password <file>`. **Not** in this repo. ufw default-deny means these ports are unreachable from the internet; `mcrcon` reaches them over loopback.
- Vanilla heap set to `-Xms1G -Xmx2G` (not 3 G) so vanilla 2 G + Arclight 4 G fits 7.7 G RAM.
- Old `minecraft.service` retired (disabled + removed); replaced by `minecraft-vanilla.service` + `minecraft-arclight.service`.

### Gotcha worth remembering: spaces in `ExecStart` paths
`/opt/mc/Arclight Server` has a space. systemd splits `ExecStart=` on whitespace, so `ExecStart=/opt/mc/Arclight Server/run.sh` tried to exec `/opt/mc/Arclight` (status 203/EXEC, restart-looping). **Fix:** wrap the path in double quotes — `ExecStart="/opt/mc/Arclight Server/run.sh"`. (Single-path directives like `WorkingDirectory=` take the whole value and don't need quoting.) Long-term, renaming the dir to `Arclight-Server` would avoid the whole class of problem.

### Verified
Both `systemctl is-active` = active, `is-enabled` = enabled; both java procs owned by `mc`; ports 25564/25565 listening; RCON `list` works on both; Arclight "Done (10.141s)!"; memory 4.1 G used / 3.7 G free.

### Still optional / not done
- ~~Swapfile (step 7)~~ — **done 2026-05-31.** 2 G `/swapfile`, mode 600, `swapon`, added to `/etc/fstab` (`/swapfile none swap sw 0 0`) so it persists across reboots.
- Vanilla `online-mode=false` — unchanged by choice; fine for private use, but anyone can join under any name.

## Glossary — the three concepts in the units

**Aikar's GC flags** — the wall of `-XX:...` options on the `java` ExecStart. Java's garbage collector (GC) periodically frees unused memory, and when it runs it can briefly pause the whole program ("stop-the-world") → an in-game lag spike. Aikar (a Paper dev) published a tuned set of G1-collector flags for Minecraft's memory pattern; `-XX:MaxGCPauseMillis=200` etc. trade rare-but-huge pauses for frequent-but-tiny ones → smoother TPS. `-Xms`/`-Xmx` set start/max heap; don't oversize `Xmx` (bigger heap = longer pauses). Here vanilla is capped at 2 G, Arclight 4 G, to fit 7.7 G RAM.

**RCON graceful-stop** — RCON (Remote CONsole) is a built-in MC protocol: send console commands (`stop`, `list`, `say`) over a port, authenticated by a password (`enable-rcon`/`rcon.port`/`rcon.password`). The unit's `ExecStop` uses `mcrcon` to send `stop`, so `systemctl stop` makes the server **save all chunks and exit cleanly** rather than getting hard-killed mid-write (which corrupts worlds). RCON ports (25575/25576) are deliberately NOT opened in ufw — `mcrcon` reaches them over loopback only; the internet can't.

**Sandboxing** — systemd directives that limit what the process can do, so an exploited mod/JVM can't own the whole box: `User=mc` (unprivileged, not root — the point of this migration), `NoNewPrivileges=true` (can't escalate), `ProtectSystem=full` (`/usr`,`/boot`,`/etc` read-only), `ProtectHome=true` (can't read home dirs), `PrivateTmp=true` (isolated `/tmp`), `ReadWritePaths=/opt/mc` (the one writable carve-out, for the worlds). Defense-in-depth layered on top of running as `mc`.

## Rollback
If a server won't start as `mc`, the worlds are in `/opt/mc/backups/`. Restore with `tar xzf`, and you can always relaunch manually in screen as a stopgap. Don't delete backups until both servers have run cleanly as `mc` for a few days.
