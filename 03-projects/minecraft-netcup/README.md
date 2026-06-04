---
room: 03-projects
project: minecraft-netcup
status: active
updated: 2026-05-31
---

# Minecraft — netcup server

Hands-on project: running and hardening Minecraft servers on a netcup ARM64 VPS.

## Connection

| | |
|---|---|
| Host | `152.53.208.165` |
| User | `root` (admin) / `mc` (service account, uid 101) |
| Auth | SSH key `~/.ssh/id_ed25519` on Avi's Mac (key-based, no password) |
| Connect | `ssh root@152.53.208.165` |
| File transfer | Cyberduck (SFTP) — same host/key |

## What's on the box

Debian 13 (trixie), kernel 6.12 **ARM64**, 6 vCPU, 7.7 GB RAM, **no swap**, 251 GB disk (2% used).

Two Minecraft servers run here:

| | Vanilla/Paper | Arclight (modded) |
|---|---|---|
| Dir | `/opt/mc/server` | `/opt/mc/Arclight Server` |
| Port | `25565` | `25564` |
| Jar | `server.jar` (Paper) | Forge 1.20.1-47.4.18 via `run.sh` |
| Mods | none | DoggyTalents + Simple Voice Chat |
| Status | idle since 2026-05-22 | **active — the world Avi plays** |
| Java | system `java` (OpenJDK 25) | `java-21-openjdk-arm64` |

## Files in this folder

- `server-analysis-2026-05-31.md` — full health/audit snapshot.
- `runbook-migrate-to-mc-user.md` — the procedure for moving both servers off `root` onto the `mc` service account with systemd.
- `troubleshooting.md` — dated fixes (e.g. EssentialsX shadowing `/give` for modded items).

## Key learnings captured

- See `04-cheatsheets/screen.md` for the screen/detach basics.
- Running a game server as `root` is the thing we're fixing — see the runbook.
