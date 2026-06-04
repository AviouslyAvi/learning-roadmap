---
type: cheatsheet
tool: cyberduck / openssh
updated: 2026-05-31
---

# SFTP from Mac → Windows (Cyberduck)

Sending files Mac → Windows over the home LAN. Cyberduck is the **client** (Mac). Windows needs the **OpenSSH Server** running to receive. One-time setup, then it just works.

## Windows side — one-time setup

Run in **PowerShell as Administrator** (right-click Start → Terminal (Admin)):

```powershell
# 1. Install the SSH server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 2. Start it + auto-run on boot
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# 3. Open the firewall
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# 4. Confirm — want "Running"
Get-Service sshd
```

Get the connection info:

```powershell
ipconfig   # grab the IPv4 Address, e.g. 192.168.1.42
whoami     # username is the part after the \
```

The server stays on across reboots (Automatic), so this setup is one-and-done.

## Mac side — connect in Cyberduck

1. **Open Connection** (top-left)
2. Protocol dropdown → **SFTP (SSH File Transfer Protocol)** — *not* FTP
3. Fill in:
   - **Server:** the IPv4 address (e.g. `192.168.1.42`)
   - **Port:** `22`
   - **Username:** Windows username (from `whoami`)
   - **Password:** Windows **account password** (NOT the PIN)
4. **Connect** → accept the host-key fingerprint the first time
5. Lands in `C:\Users\you\` → **drag files in** to send

💡 Save it: ⌘B (or the bookmark button) so you don't retype the IP every time.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Connection refused / times out | `sshd` not running → rerun `Get-Service sshd`, must say Running |
| Login failed / wrong password | Use the real account password, not the Windows PIN |
| Can't find each other | Both machines must be on the **same Wi-Fi/network** |
| Wrong IP | Read the IPv4 of the *active* adapter (Wi-Fi vs Ethernet) |

## Alternatives (no server setup needed)

- **LocalSend** (app) or **PairDrop** (pairdrop.net, no install) — AirDrop-style one-time sends, no SSH server required.
- **rsync over the same SSH** for large/resumable transfers: `rsync -avhP file user@192.168.1.42:/path/`
