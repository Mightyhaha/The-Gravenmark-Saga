# The Gravenmark Saga

An RPG gamemode for Garry's Mod set during the Trifecta rebellion. It is built on Underdone, originally made by Polkm and refactored for GMod 13 by Zeni, TwentySix and Q2F2.

## Installing

Copy or clone this repository into `garrysmod/gamemodes/gravenmark/`. The folder name must match `gravenmark.txt`; the Lua loader works out its own paths from the folder name.

Maps whose names start with `ud_` load the gamemode automatically. `ud_rebellland_beta_02b` is included under `content/maps/`.

Saves, auctions and map layouts are stored in `garrysmod/data/underdone/` (set by `GM.DataFolder` in `gamemode/shared.lua`).

## Building content

| What | Where |
| --- | --- |
| Quests | `gamemode/core/sharedfiles/database/quests/` |
| NPC types (enemies, quest givers, shopkeepers) | `gamemode/core/sharedfiles/database/npcs/` |
| Items, including quest items | `gamemode/core/sharedfiles/database/items/` |
| Shops | `gamemode/core/sharedfiles/database/shops/` |

`sh_quest_trifecta.lua`, `sh_npcs_trifecta.lua` and `sh_items_trifecta.lua` are a small working example chain (Ulric of Dunmarrow).

A quest giver offers the quests listed in its `NPC.Quest = {...}`. Quest fields:

| Field | Meaning |
| --- | --- |
| `Name` | Unique id, used in the quest giver's `NPC.Quest` list |
| `PrintName` | Title in the quest menu and HUD tracker |
| `Story` / `TurnInStory` | Text shown when reading the quest / after completing it |
| `Level` | Minimum player level to accept it |
| `QuestNeeded` | Optional quest that must be completed first; hidden until then |
| `Kill` | `{npc_name = count}`, using names from the NPC database |
| `ObtainItems` | `{item_name = count}`, taken from the player on turn-in |
| `StartingItems` | Optional `{item_name = count}`, given on accept |
| `GainedExp` / `GainedItems` | Rewards |

An item with `Item.QuestItem = "<quest name>"` only drops while the killer has that quest active.

## In-game editors (single player, admin)

| Console command | What it does |
| --- | --- |
| `UD_Dev_EditMap` | Opens or closes the map editor for NPC spawn points and props. Layouts are saved per map to `data/underdone/Maps/<map>.txt`. |
| `UD_Dev_EditPaperDoll` | Position worn equipment models on the player and copy the offsets for an item definition. |

Using the map editor:

- It opens with the mouse cursor on. Press **C** to switch between using the cursor (window and clicking in the world) and looking around with the mouse. WASD moves you either way. `UD_Dev_EditMap_Mouse` does the same as C.
- **Left-click** the ground (with the cursor, or with the crosshair while the cursor is off) to place a marker, then pick its settings and press **Add**. Nothing spawns until you add it.
- **Left-click** an existing marker to select it: change its settings and press **Apply changes**, **Move** it to your next click, or **Remove** it.
- **Right-click** cancels or deselects. Your weapon does not fire while the editor is open.
- A spawn point spawns **How many NPCs** at once, randomly inside its **Spawn area radius** (0 means exactly on the marker). Each one respawns its own **Respawn** seconds after dying.
- Press **Save map** when you are done; the window shows when there are unsaved changes.

## Client options

| Console variable | Default | Effect |
| --- | --- | --- |
| `ud_showhud` | 1 | Show the HUD |
| `ud_showminimap` | 1 | Show the minimap (turn off on slow machines) |
| `ud_showcrosshair` | 1 | Show the crosshair |
