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
  turns it on), crowd control icons get a **glow** (and can **blink** when the theme asks), icons are **square** (no stretching) with a thin border, and the broken
  glow texture path was fixed.

- Only **Tidy Plates: Threat Plates** is listed in Interface → AddOns: the *Tidy Plates* panel (theme choice, own
  minimap icon) and the *Hub: Damage / Tank* panels are no longer listed. Their two useful settings moved into `/tptp`:
  *Castbars on other enemies too* (Nameplate Settings → Castbar) and the combat automation of enemy / friendly
  nameplates (Nameplate Settings → General Settings / Friendly). `/tidyplates` opens `/tptp`; `/hubdamage` and
  `/hubtank` are gone.

Everything else is the original 3.3.5 backport.

### Threat Plates

#### Works with custom classes
The original addon only knew the 10 Blizzard classes and threw Lua errors (e.g. `Core.lua:1182: attempt to
concatenate field '?'`) on CoA custom classes. All class lookups are now safe for unknown class tokens, and the class
based extras (friendly and enemy class colors, class icon widget) were removed; enemies use one enemy color: with 21 classes and the classless realm they
do not help.

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
- **Nameplate Settings → Friendly**: your **HoTs and short buffs** and **crowd control** on party / raid members' nameplates
  (both off by default; friendly nameplates must be shown, Shift+V or the switch in the tab).

#### Execute line, cast highlight, dispellable buffs
- **Execute line** (`/tptp` → Nameplate Settings → Enemy Nameplates, off by default): vertical mark on enemy health bars
  at the set health %.
- **Cast highlight** (same place, off by default): the castbar blinks with a red border when an enemy casts a spell
  from your list. Spells interrupted by you or your group are **learned automatically**.
- **Enemy healers** (same place, on by default): a big heal icon above enemy healers. The client has no role info for
  enemies, so a unit is marked after it healed others 3 times (self heals and procs like Vampiric Embrace do not count).
  Enemy players: only in battlegrounds and arenas; healer NPCs: everywhere (can be turned off). Cleared on zone change.
- **Quest mobs** (same place, on by default): a big yellow **!** with your progress (e.g. 3/10) above the nameplate of
  mobs you still need for a quest; gone when the objective is complete. Kill objectives come from the quest log; mobs
  that drop quest items are learned when their tooltip names one of your open objectives / quests, or when you loot a
  quest item from them (remembered across sessions, a *Forget* button clears the list). Only your own quests.
- **Dispellable buff arrow** (Widgets → Debuffs): a blinking up arrow left of the debuff icons when an enemy has a
  magic / enrage buff. Exact on target / focus / mouseover; on other mobs for buffs already seen (learned list).
- **Nameplate Settings → Friendly**: tick the dispel types you can remove (magic, curse, poison, disease) and those crowd control
  icons on group members **blink**.
- **Nameplate Settings → Friendly**: friendly players with a light blue health bar or **name only** (the bar
  appears while damaged), their color; friendly NPCs name only. All friendly settings are in this one place.

#### Threat %
`/tptp` → Widgets → *Threat %* (on by default; replaces the old, hard to read *Threat Line* widget): your threat as a
number above the health bar (on a dark background, readable on any ground), in combat. The game gives threat numbers only for your target, mouseover and focus.
- DPS / Healer: how close you are to pulling aggro (100% = you pull); white, orange from 70%, red from 90% or with aggro.
- Tank: your own threat. White 100% = the mob is on you; below 100% someone else has it: orange from 90% (you take
  it back soon), yellow from 70%, red below.
- The number **blinks twice** when its color changes, and a **sound** plays for your target when it gets dangerous
  (DPS / Healer: reaching 90% or pulling aggro; Tank: losing the mob). The aggro pull is silent when the game's own
  *Play Aggro Sounds* is on, so it never sounds twice. Both can be turned off.

#### Other changes
- **Friendly players** have a **light blue** health bar, friendly NPCs stay green, so players stand out in cities
  (color: `/tptp` → Nameplate Settings → Friendly). Friendly class colors were removed: with custom
  classes and the classless realm they would not mean anything.
- **Friends & Guild Icon** widget (formerly *Social Widget*): clearer texts, the Battle.net part removed (no Battle.net on
  Grimfall).
- **Minimap button** whose icon shows your role (shield = Tank, swords = DPS, heal = Healer): left click opens the Role tab, right click switches the role (Tank > DPS > Healer), drag to move it. Can be hidden in the Role tab.
- Short **help texts** at the top of the option groups and next to settings whose purpose is not obvious (e.g. the
  Threat System settings only override the Nameplate Settings in combat).
- New **Help** tab in `/tptp` describing the roles, warnings, commands and where to fine tune.
- No "set your theme to Threat Plates?" popup: the theme is selected automatically.
- Options cleaned up: duplicated settings merged, a switch that did nothing (friendly *Click Through*) removed.
  All friendly settings (which friendly nameplates are shown, players, NPCs, group effects) are in one place (**Nameplate Settings → Friendly**),
  *Totem Nameplates* moved under Nameplate Settings, *Custom Nameplates* removed (WotLK pet / raid add presets; pets
  and guardians can be hidden there or the Blizzard interface options), the *Profiles* tab was replaced by a **Reset all settings** button
  in the Help tab.
- **About** tab cleaned up (no donate / Discord links, no translator list).
- Threat colors that are fully transparent ("keep the normal color") now keep *your* health bar colors (custom
  colors, friendly player color, HP gradient) instead of falling back to the plain game color.
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
