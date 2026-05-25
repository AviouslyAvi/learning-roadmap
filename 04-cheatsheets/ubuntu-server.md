---
type: cheatsheet
tool: ubuntu-server
updated: 2026-05-24
---

# Ubuntu server — admin cheatsheet

For day-to-day remote admin of an Ubuntu LTS box (currently Minecraft, later n8n). Assumes you're SSH'd in as a sudo user. Destructive commands marked ⚠️.

## 0. The Windows SCP/SFTP question

You asked about WinSCP/Cyberduck equivalents. Short answer: **stick with WinSCP**. It's still the best Windows SFTP/SCP client in 2026 — actively maintained, free, has a built-in editor, syncs folders, scripts well. FileZilla works but has a noisier UI and a sketchy installer history (bundled adware in past releases — the official site is clean now but the reputation lingers). If you want one tool that does SSH terminal + SFTP + tunnels in a single pane, **MobaXterm** (free for personal use) is the upgrade. **Termius** is the cross-platform pick if you want the same UI on Windows/macOS/iOS/Android with synced keys, but the good features are paid.

Verdict: **WinSCP for file transfer, add MobaXterm if you want a one-stop terminal+SFTP, skip FileZilla.**

## 1. Navigation & filesystem

```bash
pwd                          # where am I
ls -lah                      # long, all (incl. dotfiles), human sizes
ls -lahS                     # sort by size
cd -                         # jump back to previous dir
tree -L 2                    # 2 levels deep (apt install tree)
find /etc -name "*.conf"     # find by name
find . -type f -mtime -1     # files modified in last 24h
find . -size +100M           # files over 100MB
stat file.txt                # full metadata (perms, atime/mtime/ctime, inode)
du -sh *                     # size of each thing in current dir
du -sh * | sort -h           # sorted, human-readable
df -h                        # disk free per mounted filesystem
df -i                        # inode usage (run if df says space free but writes fail)
ncdu /                       # interactive disk usage (apt install ncdu) — best tool
```

## 2. File ops & permissions

```bash
cp -a src dst                # archive mode — preserves perms, symlinks, timestamps
cp -r dir1 dir2              # recursive copy
mv old new                   # rename or move
rm file                      # delete
rm -rf dir                   # ⚠️ recursive force delete — no undo, no trash
ln -s /opt/minecraft ~/mc    # symlink (target, then linkname)

chmod 644 file               # rw-r--r-- (config files)
chmod 755 script.sh          # rwxr-xr-x (executables, dirs)
chmod 600 ~/.ssh/id_ed25519  # rw------- (private keys MUST be this)
chmod +x script.sh           # add execute for everyone
chmod -R u+w dir/            # recursive, user gets write
chown -R minecraft:minecraft /opt/minecraft   # change ownership recursively
umask 022                    # default new-file perms = 644, new-dir = 755

# Permission digits cheat: read=4, write=2, exec=1. Owner / group / other.
# 777 = ⚠️ everyone can do everything. Never do this on a server.
```

## 3. Viewing, searching, editing text

```bash
cat file                     # dump (small files only)
less file                    # pager — / to search, q to quit, G end, gg top
head -n 50 file              # first 50 lines
tail -n 100 file             # last 100 lines
tail -f /var/log/syslog      # follow new lines (logs) — Ctrl-C to stop
tail -F                      # like -f but survives log rotation

grep "ERROR" server.log              # find lines
grep -i "error"                       # case-insensitive
grep -rn "minecraft" /etc             # recursive, with line numbers
grep -v "INFO" log                    # invert — lines NOT matching
grep -E "WARN|ERROR" log              # extended regex / alternation

sed -i 's/old/new/g' file.conf        # in-place replace ALL occurrences ⚠️ no undo
awk '{print $1, $9}' access.log       # print columns 1 and 9
awk '$9 == 500' access.log            # rows where column 9 == 500

nano file                    # beginner-friendly editor. Ctrl-O save, Ctrl-X quit
vim file                     # i = insert, Esc = normal, :wq = save+quit, :q! = quit no save
```

## 4. Users, groups, sudo

```bash
whoami                       # current user
id                           # uid, gid, all groups
groups <user>                # what groups they're in
who                          # who's logged in right now
w                            # who + what they're doing
last                         # login history

sudo adduser avi             # interactive: creates user, home, prompts password
sudo usermod -aG sudo avi    # add to sudo group (note -a = append, critical)
sudo usermod -aG docker avi  # let avi run docker without sudo (when you set up n8n)
sudo passwd avi              # set/reset their password
sudo deluser avi             # remove user (add --remove-home to also nuke /home/avi)
sudo visudo                  # safely edit /etc/sudoers — never edit it directly ⚠️
```

## 5. Processes & resources

```bash
ps aux                       # every process, BSD format
ps aux | grep java           # find your Minecraft JVM
pgrep -af java               # PIDs + cmdline matching "java"
top                          # live process view, q to quit
htop                         # prettier top (apt install htop) — F9 kill, F6 sort
free -h                      # RAM + swap, human-readable
uptime                       # load average (1m, 5m, 15m)
lsof -i :25565               # what's listening on Minecraft port
lsof -p <pid>                # every file/socket a process has open

kill <pid>                   # polite SIGTERM
kill -9 <pid>                # ⚠️ SIGKILL — no cleanup, last resort
kill -HUP <pid>              # reload config (many daemons honor this)
killall java                 # ⚠️ kills ALL java processes — careful with shared boxes

nice -n 10 ./heavy.sh        # start at lower priority (positive = nicer)
renice -n 5 -p <pid>         # change priority of running process
```

## 6. systemd (services)

This is how you'd run Minecraft "properly" instead of via screen, and how n8n will run later.

```bash
systemctl status nginx                 # is it running? recent logs
sudo systemctl start <svc>             # start now
sudo systemctl stop <svc>              # stop now
sudo systemctl restart <svc>           # stop + start
sudo systemctl reload <svc>            # re-read config without dropping connections
sudo systemctl enable <svc>            # start on boot
sudo systemctl disable <svc>
sudo systemctl daemon-reload           # after editing a unit file
systemctl list-units --type=service    # what's running
systemctl list-unit-files              # what's installed
systemctl --failed                     # what's broken

journalctl -u nginx                    # logs for one service
journalctl -u nginx -f                 # follow live
journalctl -u nginx --since "1 hour ago"
journalctl -u nginx -p err             # priority: err and worse
journalctl -b                          # logs since this boot
journalctl --disk-usage                # how much disk journals are eating
```

Minimal unit file (`/etc/systemd/system/minecraft.service`):

```ini
[Unit]
Description=Minecraft server
After=network.target

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/java -Xmx4G -Xms2G -jar server.jar nogui
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Then: `sudo systemctl daemon-reload && sudo systemctl enable --now minecraft`.

## 7. Networking

```bash
ip a                         # all interfaces + addresses (replaces ifconfig)
ip r                         # routing table
ss -tulnp                    # listening TCP/UDP sockets with process (replaces netstat)
ss -tn state established     # current TCP connections

ping -c 4 8.8.8.8            # 4 packets, then stop
traceroute example.com       # hop-by-hop path (apt install traceroute)
mtr example.com              # ping + traceroute combined, live (apt install mtr)
dig example.com              # DNS lookup
dig +short example.com       # just the answer
dig @1.1.1.1 example.com     # ask a specific resolver
host example.com             # simpler dig
curl -I https://example.com  # response headers only
curl -v https://example.com  # verbose (TLS handshake, headers)
curl -O https://x/file.zip   # download keeping filename
wget https://x/file.zip      # same idea, different tool
nmap -p 1-1000 <host>        # port scan first 1000 ports — only scan boxes you own
```

## 8. SSH & key management

On your laptop:

```bash
ssh-keygen -t ed25519 -C "avi@laptop"   # modern keypair (no -b needed for ed25519)
ssh-copy-id avi@server                  # installs your pubkey into ~/.ssh/authorized_keys
ssh avi@server                          # log in
ssh -p 2222 avi@server                  # non-default port
ssh -i ~/.ssh/specific_key avi@server   # specific key
ssh -L 8080:localhost:80 avi@server     # local tunnel: laptop:8080 -> server's localhost:80
ssh -N -f -L 5678:localhost:5678 avi@server   # background tunnel (great for n8n UI)
```

`~/.ssh/config` on your laptop — best quality-of-life upgrade you can make:

```sshconfig
Host mc
    HostName 1.2.3.4
    User avi
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

Then just `ssh mc`. SCP, SFTP, rsync, and WinSCP all read this file too.

### Hardening `/etc/ssh/sshd_config` (then `sudo systemctl restart ssh`)

```
PermitRootLogin no
PasswordAuthentication no       # keys only — make SURE your key works first ⚠️
PubkeyAuthentication yes
Port 22                         # changing this is security-theater, but cuts log noise
```

Keep your old SSH session open while testing the new config in a second window. If you lock yourself out, the old session can fix it.

## 9. File transfer: scp vs sftp vs rsync

```bash
# scp — quick, one-shot. Syntax mirrors cp.
scp file.txt avi@mc:/tmp/                       # upload
scp avi@mc:/var/log/syslog ./                   # download
scp -r ./worldbackup avi@mc:/opt/minecraft/     # recursive

# sftp — interactive session, good for browsing. ls/cd/get/put/bye
sftp avi@mc

# rsync — what you actually want for anything non-trivial.
# Only copies differences, resumable, preserves perms, can delete on target.
rsync -avh source/ avi@mc:/dest/                # trailing / on source = "contents of"
rsync -avh --progress source/ avi@mc:/dest/     # show per-file progress
rsync -avhn --delete source/ avi@mc:/dest/      # DRY RUN (-n) of mirror with delete
rsync -avh --delete source/ avi@mc:/dest/       # ⚠️ real mirror — files on remote NOT in source get deleted
rsync -avh -e "ssh -p 2222" source/ avi@mc:/dest/   # non-default SSH port
```

Rule of thumb: **scp for single files, rsync for everything else, sftp when you want to poke around.**

## 10. apt (packages)

```bash
sudo apt update                       # refresh package index — does NOT install anything
sudo apt upgrade                      # install pending upgrades for what's installed
sudo apt full-upgrade                 # like upgrade but allows removing packages if needed
sudo apt install htop ncdu mtr tree   # install
sudo apt remove htop                  # uninstall (keeps config)
sudo apt purge htop                   # uninstall + nuke config
sudo apt autoremove                   # remove packages nothing depends on
apt search "minecraft"                # search index
apt show nginx                        # package details
apt list --installed | grep nginx     # is it installed
dpkg -l                               # everything installed (lower-level)
dpkg -L nginx                         # what files did this package install
dpkg -S /etc/nginx/nginx.conf         # what package owns this file
```

## 11. Firewall (ufw) — full reference

```bash
sudo ufw status                       # active rules
sudo ufw status verbose               # + default policies, logging level
sudo ufw status numbered              # rules with [1], [2]… for delete/insert by index

# Defaults — set once on a new box
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed          # if this box ever forwards traffic

# Allow / deny — basic
sudo ufw allow 22/tcp                 # ⚠️ SSH — do this BEFORE enabling
sudo ufw allow 25565/tcp              # Minecraft
sudo ufw allow 5678/tcp               # n8n (later)
sudo ufw allow http                   # by service name from /etc/services
sudo ufw allow 'OpenSSH'              # by app profile (see app list below)
sudo ufw deny 23/tcp                  # explicit block (rare — default is deny)

# Scope: who, from where, to where
sudo ufw allow from 1.2.3.4                                  # any port, from this IP
sudo ufw allow from 1.2.3.4 to any port 22                   # whitelist your home IP for SSH
sudo ufw allow from 192.168.1.0/24 to any port 25565         # whole subnet
sudo ufw allow in on eth0 to any port 80                     # only on a specific interface
sudo ufw allow from 1.2.3.4 to any port 22 proto tcp         # restrict to TCP

# Comments — add at rule creation
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow from 1.2.3.4 to any port 22 proto tcp comment 'home IP'

# Enable / disable / reload
sudo ufw enable                       # ⚠️ drops non-allowed connections immediately
sudo ufw disable
sudo ufw reload                       # re-read rules without disabling
sudo ufw reset                        # ⚠️ nuke all rules, disable, back up old rules to /etc/ufw/*.bak
```

### Listing, deleting, and reordering

`ufw` evaluates rules **in order, first match wins.** That's why insert position matters.

```bash
sudo ufw status numbered              # see rule numbers
sudo ufw delete 3                     # delete rule #3
sudo ufw delete allow 25565/tcp       # delete by matching the original spec
sudo ufw insert 1 allow from 1.2.3.4  # insert at position 1 (top of list)
```

When you delete by number, remaining rules renumber. If deleting several, **delete highest-numbered first**, or each delete shifts the indices below it.

### Editing an existing rule (incl. adding a comment)

ufw has **no in-place edit** — not for the rule itself, not for its comment. The workflow:

```bash
sudo ufw status numbered              # find the rule number, e.g. [4]
sudo ufw delete 4
sudo ufw allow 22/tcp comment 'SSH from anywhere'    # re-add with the new comment
```

If you want it back in the same position:

```bash
sudo ufw insert 4 allow 22/tcp comment 'SSH from anywhere'
```

For bulk rewrites it's faster to edit `/etc/ufw/user.rules` (IPv4) and `/etc/ufw/user6.rules` (IPv6) directly, then `sudo ufw reload`. ⚠️ Back them up first — syntax mistakes can lock you out:

```bash
sudo cp /etc/ufw/user.rules /etc/ufw/user.rules.bak
sudo nano /etc/ufw/user.rules
sudo ufw reload
```

### App profiles

Packages can ship ufw profiles into `/etc/ufw/applications.d/`. Saves you memorizing ports.

```bash
sudo ufw app list                     # what profiles exist on this box
sudo ufw app info 'OpenSSH'           # what ports/protos this profile covers
sudo ufw allow 'Nginx Full'           # http + https in one rule
```

### Blocking individual IPs

For a one-off bad actor — a scanner, a known-abusive host — a manual `deny` rule is fine:

```bash
sudo ufw deny from 45.128.232.206 comment 'Blocked malicious scanner'
sudo ufw deny from 45.128.232.0/24 comment 'Whole /24 abuse'   # whole subnet
sudo ufw status numbered | grep 45.128.232.206                 # verify
```

**Position:** `deny from <ip>` should sit above any broad `allow` that would match the same traffic. ufw auto-orders by specificity in most cases, so a specific-IP deny lands above `allow 22/tcp`. Confirm with `status numbered` — if not, delete and re-insert at the top:

```bash
sudo ufw delete <n>
sudo ufw insert 1 deny from 45.128.232.206 comment 'Blocked malicious scanner'
```

**When NOT to do this:** if you're adding more than a handful of these, you're playing whack-a-mole. Manual deny rules accumulate forever, slow rule evaluation, and the attacker just rotates IPs. Switch tools:

- **`sudo ufw limit 22/tcp`** — rate-limits at the firewall (6 connections / 30s per source). Stops the dumb brute force without listing IPs.
- **`fail2ban`** — auto-bans IPs after N failed auth attempts, with a TTL so the ban list expires itself. Uses its own iptables chain (not ufw rules), so your ufw status stays clean.
- **GeoIP / country blocks** — `ipset` + a country list if traffic from a region is 100% noise. Beyond ufw's native scope.

Rule of thumb: **ufw for structural rules (which services are open to whom). fail2ban for reactive bans (this IP just failed SSH 5 times).** Don't blur the two.

### Rate limiting (anti-brute-force)

```bash
sudo ufw limit 22/tcp comment 'SSH rate limit'
```

Blocks an IP that makes 6+ connections in 30 seconds. Layered defense alongside fail2ban — doesn't replace it.

### IPv6

`ufw` manages IPv6 too if `IPV6=yes` is set in `/etc/default/ufw` (default on modern Ubuntu). Same commands apply; check with `sudo ufw status` — IPv6 rules appear with `(v6)` suffix.

### Logging

```bash
sudo ufw logging on                   # default: low
sudo ufw logging medium               # logs allowed + blocked + invalid
sudo ufw logging off
sudo tail -f /var/log/ufw.log         # watch in real time
sudo grep 'UFW BLOCK' /var/log/ufw.log | tail
```

Heavy logging on a noisy box will fill `/var/log` fast. Low is usually right.

### Common footguns

- **`ufw enable` over SSH without allowing 22 first → locked out.** Always: `sudo ufw allow 22/tcp` first, then enable.
- **Rule order matters.** `deny from 1.2.3.4` AFTER `allow 22/tcp` does nothing for port 22 from that IP — first match wins. Use `insert` to put deny rules above the matching allow.
- **Deleting by spec must match exactly.** `sudo ufw delete allow 22` won't delete `allow 22/tcp` — the protocols differ.
- **`ufw reset` doesn't disable**, it disables and clears. Re-enabling re-applies defaults only — your old rules are gone (but backed up to `/etc/ufw/*.bak`).
- **Docker bypasses ufw.** When you run n8n in Docker and publish a port, Docker writes iptables rules that sidestep ufw entirely. Bind containers to `127.0.0.1:5678:5678` and reverse-proxy through nginx, or look up the `ufw-docker` script. This will bite you — flag it now.

## 12. Logs & troubleshooting

```bash
journalctl -xe                        # recent + explanations (start here when something breaks)
journalctl -k                         # kernel messages (replaces dmesg for most things)
dmesg -T | tail                       # kernel ring buffer, human-readable timestamps
ls /var/log/                          # what logs exist
tail -f /var/log/auth.log             # SSH attempts, sudo, login activity
tail -f /var/log/syslog               # general system messages
last                                  # who logged in when
lastb                                 # failed login attempts (sudo)
```

When a service won't start, the loop is: `systemctl status <svc>` → `journalctl -u <svc> -n 50` → check the config file → `systemctl daemon-reload` if you edited the unit → `systemctl restart <svc>`.

## 13. Disk & storage

```bash
lsblk                                 # block devices, partitions, mountpoints
lsblk -f                              # + filesystem types and UUIDs
mount                                 # what's mounted
df -h                                 # space per filesystem
sudo fdisk -l                         # partition tables (MBR/GPT)
sudo parted -l                        # nicer partition info
sudo mount /dev/sdb1 /mnt             # mount manually
sudo umount /mnt                      # unmount
cat /etc/fstab                        # persistent mounts at boot — edit carefully ⚠️
```

When editing `/etc/fstab`, test with `sudo mount -a` BEFORE rebooting. A bad fstab can fail boot.

## 14. Cron & systemd timers

```bash
crontab -e                            # edit YOUR user's cron
crontab -l                            # list
sudo crontab -e                       # root's cron
# format: m h dom mon dow  command
# 0 4 * * *  /opt/backup.sh           # every day at 04:00
# */15 * * * * /opt/check.sh          # every 15 minutes
```

systemd timers are the modern replacement — better logging, can run after boot if missed, integrate with `journalctl`. Worth learning when you add scheduled backups.

## 15. tmux (the screen upgrade)

You already use `screen`. `tmux` is the modern equivalent — same idea, better defaults, scriptable, status bar. Worth switching when you're ready, but no rush.

```bash
tmux new -s mc                        # new named session
tmux ls                               # list
tmux attach -t mc                     # reattach
# Prefix is Ctrl-b (instead of screen's Ctrl-a)
# Ctrl-b d   detach
# Ctrl-b c   new window
# Ctrl-b n / p   next / prev window
# Ctrl-b %   split vertical
# Ctrl-b "   split horizontal
```

For Minecraft, though — switching to a systemd service (section 6) is the actual upgrade. Screen/tmux is for when you want to SEE the console output.

## 16. Security hygiene checklist

Do these once on any new server:

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades   # auto security patches

sudo apt install fail2ban                                   # bans IPs after failed SSH attempts
sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd                            # who's currently banned

# In /etc/ssh/sshd_config:
#   PermitRootLogin no
#   PasswordAuthentication no
# Then: sudo systemctl restart ssh

# ufw rules from section 11

# Optional: change SSH port to reduce log noise (not real security)
```

Don't bother with non-standard SSH ports as a security measure — it just stops the dumbest bots. Real protection: keys-only, fail2ban, ufw, patched OS.

## Practice path for today

Build on what you already know — you have `screen` and SCP/SFTP down. Do these in order:

1. **Recon your own box.** `whoami`, `id`, `uptime`, `free -h`, `df -h`, `lsblk`, `ip a`, `ss -tulnp`. Just look around.
2. **Find your Minecraft process.** `ps aux | grep java`, then `lsof -p <pid> | head`, then `lsof -i :25565`. Now you know what's listening and where its files live.
3. **Set up `~/.ssh/config`** on your laptop with a `Host mc` entry. Confirm `ssh mc` works. WinSCP and Cyberduck will pick it up too.
4. **Practice rsync** with a dry run first: `rsync -avhn ./somefolder/ avi@mc:/tmp/test/`. Then drop the `-n` and run it for real.
5. **Read a log with journalctl.** `journalctl -xe`, then `journalctl --since "10 minutes ago"`. Filter by a unit you have: `journalctl -u ssh`.
6. **Try ufw in dry-run mindset.** `sudo ufw status verbose`. Don't enable it yet — first make sure rules for 22 and 25565 exist. Then enable.
7. **Stretch goal: convert Minecraft from screen to a systemd service** (section 6 unit file). Stop the screen session, `systemctl enable --now minecraft`, then `journalctl -u minecraft -f` to watch it boot. This is the single biggest "I run a real server now" upgrade.
8. **fail2ban + unattended-upgrades.** Five-minute install, large security win.

Save the n8n-specific stuff (Docker, reverse proxy, TLS via Let's Encrypt) for when you actually start that project — it deserves its own cheatsheet.
