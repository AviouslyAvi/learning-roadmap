---
room: 03-projects
project: minecraft-netcup
type: analysis
date: 2026-05-31
---

# Server analysis — 2026-05-31

SSH audit of `root@152.53.208.165` (netcup ARM64 VPS, hostname `v2202605359570460974`).

## Host health

| Resource | Reading | Verdict |
|---|---|---|
| OS / kernel | Debian 13 (trixie), 6.12 ARM64 | fine |
| CPU | 6 cores, load ~0.4 | idle, lots of headroom |
| Disk | 4.1 G / 251 G (2%) | fine |
| RAM | 5.2 G used / 7.7 G, **0 swap** | tight, no safety net ⚠️ |
| Uptime | 10 days | fine |

## Two servers running

Both started **manually in `screen`, as `root`**, on 2026-05-30.

| | Vanilla/Paper | Arclight (modded) |
|---|---|---|
| Dir | `/opt/mc/server` (owned `mc:mc`) | `/opt/mc/Arclight Server` (owned `root:root`) |
| Port | 25565 | 25564 |
| Heap | `-Xmx2G` | `-Xmx4G` (~3.4 G resident, 46% CPU) |
| Screen | `9510.Minecraft` | `96996.MinecraftDogs` |
| Process owner | **root** | **root** |
| Activity | idle since 2026-05-22 | active — Avi logged in 2026-05-31 |

## Findings

1. **Both servers run as `root`.** The `mc` service account (uid 101, home `/opt/mc`, shell `/bin/bash`) exists but has never launched anything (no `S-mc` screen sockets). Running a public game server as root means a process exploit = full root on the box.

2. **The `mc`-user systemd unit already exists but is dead.** `/etc/systemd/system/minecraft.service` is correctly written (`User=mc`, Aikar GC flags, RCON stop, sandboxing) and `enabled`, but **inactive since 2026-05-21**. It died with:
   - `logs/latest.log (Permission denied)`
   - `java.nio.file.AccessDeniedException: ./world/session.lock`
   **Root cause:** root had already created `logs/` and `world/` files owned by root, so the `mc` user couldn't write them. Running as root *caused* the mc-service to fail → fell back to manual root start → made it worse. Chicken-and-egg; the fix is `chown -R mc:mc`.

3. **RCON is off but the unit's stop command needs it.** Vanilla `server.properties` has `enable-rcon=false` and empty `rcon.password`, yet the unit's `ExecStop` calls `mcrcon` → `Error 111: Connection refused`. Graceful shutdown is broken until RCON is enabled with a password.

4. **The existing unit only covers the vanilla server.** The modded Arclight server (the one actually played) has no unit at all.

5. **Ownership split on the vanilla dir.** `/opt/mc/server` files are owned `mc` but written by root → new files land as root inside an mc dir. Latent permission rot.

6. **No swap.** Two JVMs + 0 swap risks a silent OOM-kill under load.

## Recommended actions (→ see runbook)

- Back up both worlds server-side.
- Stop both servers gracefully.
- `chown -R mc:mc` both directories.
- Enable RCON (password) on vanilla; give Arclight its own stop method.
- Two systemd units (`minecraft-vanilla`, `minecraft-arclight`), both `User=mc`.
- Add a 2–4 G swapfile.
