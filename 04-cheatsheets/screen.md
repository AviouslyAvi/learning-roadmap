---
type: cheatsheet
tool: screen
updated: 2026-05-23
---

# screen — quick reference

GNU `screen` keeps shell sessions alive on a remote host so processes don't die when SSH drops. The escape key is `Ctrl-a` (written `C-a` below). Send a literal `Ctrl-a` with `C-a a`.

Source clipping: `~/Library/CloudStorage/.../Fresh Obsidian/Clippings/Screen Cheatsheet.md` (originally from jctosta's gist).

## What I actually use

The five commands I reach for daily on the Minecraft / Netcup boxes:

| | |
|---|---|
| Start a named session | `screen -S <name>` |
| List running sessions | `screen -ls` |
| Reattach to a session | `screen -r <name>` |
| Detach (leave it running) | `C-a d` |
| Force-attach (kicks other clients) | `screen -r -d <name>` |

That's enough to run a Minecraft server in the background, log off, and come back to it.

## Sessions

| | |
|---|---|
| New named session | `screen -S <name>` |
| List sessions | `screen -ls` |
| Attach by name | `screen -r <name>` |
| Attach (whatever's running) | `screen -x` |
| Detach a session (from outside) | `screen -d <name>` |
| Kill a session by id | `screen -S <id> -X quit` |

## Inside a session (escape `C-a`)

| | |
|---|---|
| Detach, leave it running | `C-a d` |
| Detach + logout | `C-a D D` |
| Show key bindings | `C-a ?` |
| Enter screen command line | `C-a :` |
| Lock the display | `C-a x` |

## Windows

A session can hold many windows (think tabs).

| | |
|---|---|
| New window | `C-a c` |
| Next / previous window | `C-a n` / `C-a p` |
| Flip to last window | `C-a C-a` |
| Jump to window N | `C-a <N>` (0–9) |
| Pick from list | `C-a "` |
| Rename current window | `C-a A` |
| Show window bar | `C-a w` |

## Split panes

| | |
|---|---|
| Split horizontally | `C-a S` |
| Split vertically | `C-a \|` |
| Move between regions | `C-a <Tab>` |
| Drop current region | `C-a X` |
| Keep only this region | `C-a Q` |

After splitting, the new region is empty — `C-a <Tab>` into it, then `C-a c` to start a window there.

## Scrollback / copy mode

| | |
|---|---|
| Enter copy mode | `C-a [` |
| Scroll | `C-u` up / `C-d` down |
| Exit copy mode | `<Esc> <Esc>` |
| Paste | `C-a ]` |

## Gotchas

- Two `screen`s nested? The inner one needs `C-a a` as its escape — same logic as nested tmux.
- `C-a k` kills a window. Easy to hit by accident. Avoid.
- `screen -ls` shows session ids as `<pid>.<name>` — use the full string when killing.
