---
room: 03-projects
project: minecraft-netcup
type: troubleshooting
updated: 2026-06-01
---

# Arclight troubleshooting log

## 2026-06-01 — `/give` broken for modded items (EssentialsX command shadowing)

**Symptom:** On the Arclight (Forge + Bukkit hybrid) server, `/give` didn't work — especially for modded DoggyTalents items. Felt like "dog commands fail."

**Cause:** EssentialsX is a Bukkit *plugin*; it registers its own `/give` backed by `items.json` (~46k vanilla items, **no modded items**). On the hybrid server Essentials' `/give` wins the command name over Forge's native `/give`, so modded item IDs never resolve. DoggyTalents Next itself registers almost no slash commands — its features are right-click/GUI + items (Treat Bag, training treats, radar), so not being able to `/give` those items looked like "dog commands don't work."

**Instant workaround (no restart):** use the namespaced command — `/minecraft:give <player> doggytalents:<item> <count>`. The `minecraft:` prefix always routes to Forge/vanilla.

**Permanent fix applied:** in `/opt/mc/Arclight Server/plugins/Essentials/config.yml`, added `give` to `disabled-commands:` so Essentials stops registering it and Forge's native `/give` takes over. Requires a **full restart** (command registration is startup-only; `/ess reload` won't release it). Config backed up first to `config.yml.bak-2026-06-01`.

```yaml
disabled-commands:
  - give
  #- nick
  #- clear
```

**Verified via RCON (port 25576, loopback):**
```
give @a minecraft:diamond 1       -> Gave 1 [Diamond] to Avious      (vanilla selector works)
give @a doggytalents:treat_bag 1  -> Gave 1 [Treat Bag] to Avious    (modded item works)
```
Both confirm Forge `/give` is now in control and resolves modded items.

**Note on other shadowed commands:** Essentials also defines its own versions of some vanilla commands (e.g. `enchant`, `kill`, `time`, `weather`). Only `give` was reported/fixed. If others misbehave for modded content, add them to `disabled-commands` the same way, or use the `/minecraft:` prefix.

**Still open:** if right-clicking a dog directly (menu/pet/order) fails, that's a separate Bukkit interact-event conflict — diagnose by tailing `logs/latest.log` live while reproducing in-game.

## Background noise seen in logs (not bugs)

- `Channels [doggytalents:channel,...] rejected vanilla connections` — DTN refusing a no-mods client. Harmless.
- `Mixin config yacl.mixins.json does not specify "minVersion"` — cosmetic warning from yet_another_config_lib. Harmless.
- `Can't keep up! Running Nms behind` + `(vehicle of X) moved wrongly` — real **TPS lag spikes**; when riding a dog, the lag causes rubber-banding. Watch if it worsens.
