# Tidy Plates: Threat Plates – Remastered for Grimfall (3.3.5a)

Threat reactive nameplates for WoW 3.3.5a (WotLK), reworked for the **Grimfall** private server:
the **Conquest of Azeroth (CoA)** realm with its custom classes, and the **classless** realm.

This repository contains **both addons that are needed**:

| Folder | What it is |
| --- | --- |
| `TidyPlates` | The nameplate engine. Required by Threat Plates. |
| `TidyPlates_ThreatPlates` | The Threat Plates theme with the Grimfall changes. |

### Credits

- **Tidy Plates**: Binbwen and Friends, 3.3.5 backport by **Kader**
- **Threat Plates**: original author **Suicidal Katt** ([WoWInterface](https://www.wowinterface.com/portal.php?&id=593)), 3.3.5 backport by **Kader**
- Grimfall & classless edition: **Lidless**

## Requirements

- WoW client 3.3.5a
- Nothing else: Tidy Plates is included in this repository.

## Installation

1. Copy **both** folders, `TidyPlates` and `TidyPlates_ThreatPlates`, into `Interface\AddOns\`.
   If you already have a `TidyPlates` folder, replace it with the one from here.
2. Restart the game (a `/reload` is not enough for new files).
3. Make sure both are **enabled** in the AddOns list.
   Threat Plates is selected as the Tidy Plates theme automatically (no popup).
4. Type `/tptp`, open the **Role** tab and choose **Tank**, **DPS** or **Healer**.

## What is different from the original

### Tidy Plates
- **Threat Plates is the default theme** for both specs (also when you press *Reset* in the Tidy Plates options).
- Aura widget (`widgets/DebuffWidget.lua`): can also show auras of **friendly group members** (only when the theme
  turns it on), crowd control icons get a **glow**, icons are **square** (no stretching) with a thin border, and the broken
  glow texture path was fixed.

Everything else is the original 3.3.5 backport.

### Threat Plates

#### Works with custom classes
The original addon only knew the 10 Blizzard classes and threw Lua errors (e.g. `Core.lua:1182: attempt to
concatenate field '?'`) on CoA custom classes. All class lookups (class colors, class icons) are now safe for
unknown class tokens.

#### Class independent role
On Grimfall almost any class can tank, heal or deal damage, so the role is no longer guessed from class,
talents, stances or shapeshift forms. The player simply chooses:

| Role | Warning on the nameplate |
| --- | --- |
| **Tank** | Mobs **not attacking you** turn red, get bigger and get a glowing frame. Mobs on another known tank are not a warning. |
| **DPS** / **Healer** | Normal while your threat is low; **orange** and slightly bigger when your threat gets high; **red, big and glowing** when the mob attacks you. |

- Every mob that attacks you gets its warning, not only the first or targeted one: the threat glow of all
  visible nameplates is checked during combat (Tidy Plates itself only refreshed it for unit-id mobs).
- The game's threat glow is not always reliable (e.g. a mob that pulled you itself), so the warning also uses the
  threat API for your target / mouseover, and the "who is the mob attacking" data: a mob attacking you always
  counts as "on you".
- Default role is **DPS**; until a role is chosen the addon reminds you in chat (at login and when entering a dungeon / raid).
- The old talent spec detection, stance / shapeshift / presence / aura based tank switching, the Dual Spec Roles menu and the
  LibDualSpec profile switching were removed.

#### "Who is the mob attacking?" line
Below enemy nameplates the mob's current target is shown with a role letter and color, e.g. `> Gorbak [T]`:

- `[T]` Tank – green
- `[D]` DPS – orange
- `[H]` Healer – **red** (the most dangerous case)
- no letter / white – role unknown

Roles of group members come from:
1. group members using this version share their chosen role automatically (addon message prefix `TPTPR`),
2. otherwise the raid **Main Tank** mark or the LFG role.

Limit of the 3.3.5 client: a mob's target is only known for mobs targeted by you or a group member
(or your focus / mouseover). Settings: `/tptp` → Widgets → *Mob Target*.

#### DoTs, crowd control and HoTs on nameplates
- **Enemies** (`/tptp` → Widgets → Debuffs, now on by default): your own DoTs / debuffs with the time left, plus
  **crowd control from anyone** (stun, fear, polymorph...) marked with a glow. Mode can be changed (all debuffs, lists...).
- **Friendly Targets** tab: your **HoTs and short buffs** and **crowd control** on party / raid members' nameplates
  (both off by default; friendly nameplates must be shown, Shift+V or the switch in the tab).

#### Other changes
- **Minimap button** whose icon shows your role (shield = Tank, swords = DPS, heal = Healer): left click opens the Role tab, right click switches the role (Tank > DPS > Healer), drag to move it. Can be hidden in the Role tab.
- New **Help** tab in `/tptp` describing the roles, warnings, commands and where to fine tune.
- No "set your theme to Threat Plates?" popup: the theme is selected automatically.
- **About** tab cleaned up (no donate / Discord links, no translator list).
- All addon texts are English.

## Chat commands

| Command | Action |
| --- | --- |
| `/tptp` | Open the options |
| `/tptprole tank\|dps\|heal` | Set your role (no argument: show current role) |
| `/tptptank`, `/tptpdps`, `/tptpheal` | Set your role |
| `/tptptoggle` | Switch between Tank and DPS |
| `/tptpverbose` | Chat messages of the addon on / off |
| `/tptpol` | Toggle overlapping nameplates |
| `/tptpdebug` | Print the threat data of your target's nameplate (for bug reports) |

## Feedback

Bugs, ideas and questions: please open an **issue** in this repository. There is no e-mail contact.
