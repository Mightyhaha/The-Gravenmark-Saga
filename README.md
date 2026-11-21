# The Gravenmark Saga

An RPG gamemode for Garry's Mod set during the Trifecta rebellion. It is built on Underdone, originally made by Polkm and refactored for GMod 13 by Zeni, TwentySix and Q2F2.

## Installing

Copy or clone this repository into `garrysmod/gamemodes/gravenmark/`. The folder name must match `gravenmark.txt`; the Lua loader works out its own paths from the folder name.

The main map is `rp_bremergard_forest`, which the menu lists under the gamemode. The older `ud_rebellland_beta_02b` is still included under `content/maps/`; pick the gamemode manually for it.

Saves, auctions and map layouts are stored in `garrysmod/data/underdone/` (set by `GM.DataFolder` in `gamemode/shared.lua`).

### Workshop content

Subscribe to these. A server sends them to joining players automatically (`GM.RequiredWorkshop` in `gamemode/core/sh_resource.lua`; the Rebellland map only on its own map). A dedicated server also needs them mounted itself, for example through a Workshop collection and `+host_workshop_collection`.

| Workshop id | Addon | Used for |
| --- | --- | --- |
| [908477738](https://steamcommunity.com/sharedfiles/filedetails/?id=908477738) | Medieval playermodels - red side | Morvaine soldiers (`NPC.SkinModel`) |
| [3686861961](https://steamcommunity.com/sharedfiles/filedetails/?id=3686861961) | rp_bremergard_forest | The map, its props, and the medieval weapon and shield models |
| [3686864365](https://steamcommunity.com/sharedfiles/filedetails/?id=3686864365) | rp_bremergard_forest content | Textures for the map, props and weapons |
| [1941832894](https://steamcommunity.com/sharedfiles/filedetails/?id=1941832894) | The Mercenaries (PM, Ragdoll & NPC) | Sergeant, Ulric and the Gallows Company bandits (used directly as NPC models) |
| [2210971880](https://steamcommunity.com/sharedfiles/filedetails/?id=2210971880) | TES Morrowind swords | The iron to dreadforged longswords |
| [385795223](https://steamcommunity.com/sharedfiles/filedetails/?id=385795223) | Medieval NPC Melee Weapons | Guard shield, short, long and silvered swords, war axe; NPC melee weapons for the bandits |
| [2905070104](https://steamcommunity.com/sharedfiles/filedetails/?id=2905070104) | zombie!! playermodels | The 11 looks of the Plague Dead and Barrow Runners |
| [903784487](https://steamcommunity.com/sharedfiles/filedetails/?id=903784487) | Arantir | The Necromancer |
| [104782818](https://steamcommunity.com/sharedfiles/filedetails/?id=104782818) | Rebellland Beta02b for Underdone | The old `ud_rebellland_beta_02b` map |

## Building content

| What | Where |
| --- | --- |
| Quests | `gamemode/core/sharedfiles/database/quests/` |
| NPC types (enemies, quest givers, shopkeepers) | `gamemode/core/sharedfiles/database/npcs/` |
| Items, including quest items | `gamemode/core/sharedfiles/database/items/` |
| Shops | `gamemode/core/sharedfiles/database/shops/` |
| Crafting trades and recipes | `gamemode/core/sharedfiles/database/masters/` and `.../recipes/` |

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
| `TurnInNPC` | Optional NPC name the quest is turned in to instead of its giver. That NPC's quest menu lists it, the giver shows "Turn in to ...". With no kill or item objectives it is a "go and talk to" step |

An item with `Item.QuestItem = "<quest name>"` only drops while the killer has that quest active. With `Item.FoundBySearching = true` it is also found by searching a chest from `GM.SearchableProps` while the quest needs it (one per chest per player).

### Story NPCs and quests

All of these are placed with the map editor (`UD_Dev_EditMap`). They are defined in `sh_npcs_trifecta.lua`, `sh_quest_dunmarrow_levy.lua`, `sh_quest_trifecta.lua`, `sh_quest_trifecta_allies.lua` and `sh_items_trifecta.lua`.

| NPC | Where | Quests |
| --- | --- | --- |
| Sergeant Osric Varne (`quest_sergeant`) | Levy camp | Levels 1 to 19: gear, first kills, looting, searching chests; ends by sending you to Ulric |
| Ulric of Dunmarrow (`quest_ulric`) | His camp: the palisade with the mine, reached through the cave by the lighthouse | Levels 22 to 75: the Threefold Council main story |
| Maren Holt (`quest_maren`) | North road | Levels 15 to 40: Kaelmoor smuggling side quests |
| Halvard Grey (`quest_halvard`) | Near Ulric | Levels 45 to 68: Vestergrim side quests; receives Ulric's council writ |
| Mother Edda (`quest_edda`) | Between the Harrow house and the chapel graveyard | Levels 36 to 125: the Barrow Dead chain (below) |
| Hilde Rook (`shop_quartermaster`) | Levy camp | Sells gear up to level 20 and starter materials |
| Old Bettany (`shop_provisioner`) | Levy camp | Camp cook, sells food and bedrolls |
| Brannoc Hale (`shop_smith`) | Next to the anvil | Master smith, sells every crafting material |
| Dunmarrow Levyman (`dunmarrow_levyman`) | Around the camp | Friendly guards that fight Morvaine and bandits |

Enemies are Morvaine (`morvaine_recruit`, `_warden`, `_soldier`, `_outrider`, `_captain`, `_knight`, `_royalguard`, boss `_marshal`) and the Gallows Company bandits (`bandit_deserter`, `_brigand`, `_sellsword`, `_veteran`, `_footknight`, `_hedgeknight`, named `bandit_jory` and `bandit_wat`, boss `bandit_raubritter`). Bandits are their own race, so they fight Morvaine too.

The story is spread over levels 1 to 75, and the Rebellion legendary chain (Ulric, after "The First Sitting") runs from 100 to 150. Grinding is expected between quests. Quest experience, coin and gear scale with the quest's level (`GM.QuestRewards`, `GM:GetQuestExp`, `GM:GetQuestMoney` and `GM:GetQuestGear` in `sh_combat.lua`): the Dunmarrow quests give half a level's worth of experience, main story quests 0.9, side quests 0.4, and a gear reward is the best crafted item of its kind at or below the quest's level.

The map zones on rp_bremergard_forest, in walking order:

| Zone | Levels | Enemies |
| --- | --- | --- |
| Levy camp | 1 | None (Sergeant Varne) |
| Road camp | 2 to 10 | Morvaine recruits 2 to 5, wardens 8 to 9, a few soldiers 10 to 14 |
| The mountain | 8 to 30 | Deserters 8 to 12, brigands 14 to 17 with Black Jory 18, then sellswords 24 to 30 and Wat 26 near the top; Red Hal (`bandit_redhal`) as a rare around 30 |
| Ulric's camp | hub | Ulric; the mine tunnel leads to the cave by the lighthouse |
| The walled town | not decided | |
| The lighthouse | 20 to 37 | Morvaine outriders 20 to 25, soldiers 30 to 35, a captain 37 |
| The Harrow house | 35 to 60 | Plague Dead and Barrow Runners 35 to 45, Bloated Dead 44 to 50, skeletons 50 to 60 |
| The Gallows tent camp | 40 to 61 | Veterans 40 to 48, Gallows knights 50 to 57, hedge knights 58 to 60, Sir Gaspard Thorne 61 |
| Outpost outside the Morvaine castle | 40 to 55 | Knights 40 to 50, Hallowgate Guards 50 to 55 |
| The Morvaine castle | 60 to 100 | Knights and Hallowgate Guards 60 to 100, Marshal Vane 70 |
| The chapel graveyard and catacombs | 85 to 125 | Skeletons 85 to 105, Barrow Lord 92 to 100, zombie guards 110 to 115, the Necromancer 125 |

| Quest | Level | Kill targets and where |
| --- | --- | --- |
| Green Steel | 2 | Recruits 2 to 4, road camp |
| Wardens on the Road | 8 | Wardens 8 to 9, road camp |
| Turncloaks in the Pines | 10 | Deserters 10 to 11, the mountain |
| Iron for the Levy | 13 | Soldiers 13 to 14, road camp |
| Black Jory | 16 | Brigands 16 to 17, Jory 18, the mountain |
| A Loose Tongue | 24 | Sellswords 24 to 25, Wat 26, the mountain |
| The Threefold Council | 35 | Soldiers 34 to 35, a captain 37, the lighthouse |
| Night Crossing, Grell's Pride | 40, 42 | Knights 40 to 43, outpost outside the castle |
| The Nephew's Warning | 50 | Soldiers 48 to 50, Hallowgate Guards 50 to 52, outpost outside the castle |
| Grell's Honour | 55 | Gallows knights 55 to 57, tent camp |
| The Robber Knight | 58 | Hedge knights 58 to 60, Thorne 61, tent camp |
| The Marshal of the Crossing | 67 | Knights 66 to 68, Vane 70, the Morvaine castle |

Sir Gaspard Thorne (`bandit_raubritter`) belongs at the tent camp around level 61; spawned lower, he is far stronger than anything near him. Outriders and veterans aren't quest targets and are good grinding packs. Between 75 and 100 there are no new quests except Mother Edda's Barrow Lord (92) and Ledger (100); the Morvaine castle is the grinding ground for that range, and its top levels lead into the Rebellion chain. "The Old Caches" needs at least two searchable chests near the camp.

**The Barrow Dead** (`sh_npcs_undead.lua`, race `undead`) fight everyone, Morvaine and bandits included. Skeletons are `npc_citizen` wearing Garry's Mod's own `models/player/skeleton.mdl` as a `SkinModel`, with held items and their voices muted (`NPC.Mute`); they clatter apart when they die (`NPC.DeathSound`). The zombies are HL2's own zombies, so they move and attack like them, with their headcrabs taken off (`NPC.NoHeadcrab`): the headcrab bodygroups are hidden at spawn, and any headcrab that pops out of one on death is removed. The Plague Dead and Barrow Runners wear one of the 11 zombie playermodels at random; the Bloated Dead keep HL2's poison zombie, tinted a grave grey-green.

The Necromancer (`undead_necromancer`, the Arantir model) raises two skeletons from the ground every 12 seconds while he has an enemy, up to four at a time, 3 levels below his own (`NPC.Summon`). Raised skeletons give a quarter of the usual experience (`GM.SummonExpShare`) and no loot, and they crumble when he dies. He carries Gravecaller (`unique_gravecaller`), his staff, which is also the reward for killing him.

| NPC | Base | Suggested levels |
| --- | --- | --- |
| Plague Dead (`undead_plaguedead`) | HL2 zombie in a zombie playermodel, slow and tough | 35 to 45, Harrow house yard |
| Barrow Runner (`undead_runner`) | HL2 fast zombie in a zombie playermodel, fragile | 38 to 45, Harrow house yard |
| Bloated Dead (`undead_bloated`) | HL2 poison zombie, no headcrabs to throw | 44 to 50, Harrow house yard |
| Risen Bones (`undead_risen`) | Skeleton, rusty sword | 50 to 54 in the Harrow house, 85 to 95 in the catacombs |
| Grave Spearman (`undead_gravespear`) | Skeleton, spear | 55 to 60 in the Harrow house, 90 to 105 in the catacombs |
| Barrow Guard (`undead_barrowguard`) | Skeleton, sword and shield | 55 to 60 in the Harrow house, 90 to 105 in the catacombs |
| Barrow Lord (`undead_bonelord`), elite | Skeleton, longsword and shield | 92 to 100, catacombs |
| Zombie guards around the Necromancer | Any of the zombies | 110 to 115, deepest crypt |
| The Necromancer (`undead_necromancer`), boss | Arantir, raises skeletons | 125, deepest crypt |

Mother Edda's quests (`sh_quest_barrows.lua`), each needing the one before:

| Quest | Level | Task | Reward |
| --- | --- | --- | --- |
| The Restless Field | 36 | Kill 8 Plague Dead | Coin, 2 healthkits |
| Runners in the Rows | 40 | Kill 6 Barrow Runners | Boots, coin |
| Grave-Tokens | 44 | Bring 6 Grave-Tokens (any zombie, while on the quest) | Helmet, coin |
| The Swollen Dead | 48 | Kill 3 Bloated Dead and 6 Plague Dead | Dunmarrow Oathring, coin |
| The Harrow Cellar | 52 | Kill 10 Risen Bones | Coin, 4 healthkits |
| The Old Watch | 57 | Kill 6 Grave Spearmen and 4 Barrow Guards | Spear |
| The Barrow Lord | 92 | Kill the Barrow Lord and 6 Barrow Guards | Chest piece, coin |
| The Ledger of Names | 100 | Bring 5 Ledger Pages (any skeleton; the Barrow Lord always drops 2) | Coin |
| Who Wakes the Barrows | 125 | Kill the Necromancer | Gravecaller, Ashen Vow, coin |

Gravecaller (`sh_items_zy_undead.lua`) is an epic level 125 spear-class staff built on the Gravensteel spear, tinted grave-green with a green glow. Each kill with it heals 8% of your health.

### Equipment slots

Slots are defined in `gamemode/core/sharedfiles/database/items/sh_slots.lua`. `Position` places the slot in the paperdoll panel (percent of its width and height). A slot with `NoModel = true` gives stats only and attaches nothing to the character, like the necklace and ring slots.

Slots that share a `Group` accept the same items. Rings use `Item.SlotGroup = "ring"` and fit either ring slot; a player who owns two of the same ring can wear both. The boots slot attaches to `ValveBiped.Bip01_R_Foot` and mirrors the same model onto `ValveBiped.Bip01_L_Foot` (`SLOT.MirrorAttachment`), so you build the right boot only. With `SLOT.RestAligned` the attachment is turned so that, in the standing pose, its forward, left and up match the body's; the offset is measured once per playermodel from its idle pose (`GM:GetRestOffset`).

Double-clicking a ring puts it in a free ring slot (or takes it off if it's worn), and dragging it onto a ring slot puts it in that one. Another slot with `Group = "ring"` adds a third ring slot without touching any items.

### NPCs wearing other models (bonemerge)

Workshop playermodels have no NPC animations, so setting one as an NPC's `Model` makes it T-pose or slide. Instead, give the NPC a `SkinModel`:

```lua
local NPC = QuickNPC("guard_red", "Red Guard", "npc_combine_s", "human", 400)
NPC.SkinModel = "models/path/to/playermodel.mdl"
```

The base NPC still does the AI and animation, but each client draws the `SkinModel` in its place, copying the NPC's bone positions every frame so it follows every animation. Bones the NPC's skeleton lacks (such as the wrist helper bones many playermodels have) keep their natural position relative to their parent bone instead of stretching. Notes:

- Only works on human NPC classes with the standard skeleton (`npc_citizen`, `npc_combine_s`, `npc_metropolice`, `npc_breen`, `npc_eli`, `npc_kleiner`), not zombies, antlions or vortigaunts. The model needs `ValveBiped` bone names, like normal playermodels.
- `NPC.Color` tints the worn model; freeze and burn effects do too.
- The ragdoll wears the same model when the NPC dies.
- If the model isn't mounted (the Workshop addon is missing), the NPC spawns with its normal look and a warning is printed in the server console.
- `SkinModel` can also be a list of models; each NPC that spawns picks one at random, like the six Morvaine Soldier variants in `sh_npcs_trifecta.lua`.

### NPCs holding items

`NPC.HeldItems = {"weapon_melee_sword", "armor_shield_round"}` puts item models in an NPC's hands, using each item's slot attachment and its `AddModel` offsets, so an item positioned for players is held the same way by NPCs. The NPC keeps its HL2 `NPC.Weapon` for its AI, but that weapon is hidden, and removed when the NPC dies. Use a melee weapon, or the NPC will shoot an invisible gun. The Morvaine units use `npc_citizen` with `weapon_crowbar`; `weapon_stunstick` would also work (with `npc_metropolice`), but its hits flash the player's screen red and kick their view.

`NPC.KeyValues = {key = value}` sets engine keyvalues before the NPC spawns. The Morvaine units use `citizentype = 4` so citizens keep the male rebel model (and voice) given in `QuickNPC` instead of picking a random one.

An item whose model has `BoneMerge = true` (the Morrowind longswords) snaps onto the hand bones instead of using offsets, on players and on NPCs.

The Medieval NPC Melee Weapons addon also gives NPC weapons that show their own sword and shield and run their own melee AI (`npc_short_sword`, `npc_short_sword_shield`, `npc_long_sword`, `npc_long_sword_shield`, `npc_silver_sword`, `npc_silver_sword_shield`, `npc_medieval_axe`, `npc_axe_shield`). Use them as `NPC.Weapon` without `HeldItems`, as the Gallows Company does. The gamemode cancels their view kick and knockback on players and undoes the fixed health they set on their owner.

### Day and night

`sh_daynight.lua` runs a clock: a full day takes 48 real minutes (`GM.DayNight.CycleMinutes`), starting at 09:00 when the map loads. Day is 07:00 to 19:00, dusk 19:00 to 21:00, night until 05:00 and dawn until 07:00. The time shows in the top-left corner of the minimap.

- The map's own lighting is dimmed through light style 0 (`engine.LightStyle`), from `m` by day to `c` at night, in small steps across dusk and dawn. Each step makes clients reload the lightmaps, which can stutter for a moment. Only the ground and buildings are relit: relighting the map's static models (`render.RedownloadAllLightmaps(true)`) turns the distant trees dark on this map, so trees and rocks keep their daytime light and night fog darkens them with distance instead. The fog fades in from the map's own fog toward a near-black blue that closes in at 2200 units (`NightFogEnd`, `NightFogDensity`), and nothing is reloaded at all until the first dusk.
- The sky is darkened with an overlay, and at night every player carries a small warm light so the forest isn't pitch black. `ud_lantern 0` turns that light off for yourself.
- At nightfall and dawn every player gets an announcement in the middle of the screen and in chat.
- The undead hit 25% harder at night (`GM.DayNight.NightUndeadDamage`).
- `UD_Dev_SetTime <hour>` sets the clock, for example `UD_Dev_SetTime 22`.

### Patrols and night monsters

`sh_world.lua`, placed with the map editor's **Patrol routes** mode.

- **Patrol routes** are chains of nodes (up to 250). NPCs from a spawn point with that route's number start at the nearest node and walk the chain, either as a **loop** (after the last node, back to the first) or **back and forth** (to the end, then turn around). A route can make them wait a number of seconds at each node, and walk or run. They break off to fight, and the leash then pulls them back to where they left the route, not to their spawn point, so routes can be as long as you like. An NPC that hasn't moved for 8 seconds skips to the next node. A one-node route sends them to that spot and keeps them there.
- **Day or night spawns:** a spawn point can spawn **Always**, **Only at night** or **Only by day**. Out of their time, NPCs vanish in a puff of dust within a few seconds and come back when their time returns. One that is fighting someone within 1500 units gets 20 more seconds (`GM.OutOfTimeGrace`), then vanishes anyway. Use night-only spawn points for rare night creatures.
- **Night monsters:** tick **A night monster may roam this route** on a route, pick which monster from the dropdown (or leave it on **any**) and set the monster's level. Each nightfall there is a 60% chance (`GM.NightRoamerChance`) that, 20 to 90 seconds later, one of the night monsters (`GM.NightRoamers`) appears at the first node of a random ticked route and walks it from there. Everyone gets an announcement, naming the place if the route has a name. If it's still alive at dawn and not fighting, it fades away. Whoever kills it is announced to everyone. Only one walks at a time.
- The night monsters (`sh_npcs_roamers.lua`) are bosses with elite loot (two rolls, and a good chance of a gem):
  - **The Gravewight**, "Walker of the Night Roads": a skeleton with an iron longsword. It raises Risen Bones as it walks, slams the ground and goes into a rage at 30%.
  - **The Pale Knight**, "Who Rides After Midnight": a see-through ghostly knight with a silver longsword and a guard shield. It steps behind its target, slams, turns half-ethereal at half health (takes 80% less damage for 5 seconds) and rages at 25%.
  - **The Night Beast**, "That Which Hunts the Dark": an antlion guard tinted almost black (`roamer_nightbeast`). It charges and shoves like any antlion guard, pounds the ground in a wide circle every 13 seconds and rages at 30%. It is its own race, so it also fights bandits, soldiers and the dead it meets.
- `UD_Dev_SummonRoamer [route] [npc]` spawns one straight away, for example `UD_Dev_SummonRoamer 3 roamer_paleknight` or just `UD_Dev_SummonRoamer roamer_nightbeast` (any ticked route). It works by day too: a summoned one doesn't fade at dawn, and stays until it is killed or another is summoned. The console prints where it spawned.

### Melee AI

Hostile humans and skeletons are `npc_citizen`, whose own AI hangs back, strafes and runs from danger. `sh_npc_melee_ai.lua` takes over while they have an enemy: four times a second it makes them run straight at their target, and swing once they are within `GM.MeleeAI.Reach` units. The leash (`DistanceRetreat`) still sends them home when they are pulled too far. Hostile NPCs attack players of any level; the old Underdone rule that left players above an NPC's level alone is gone.

### Boss abilities

`sh_bosses.lua` gives NPCs abilities through `NPC.Abilities`, a list of entries, and `NPC.Boss = true` shows a health bar at the top of the screen to everyone within 1200 units. An entry with `Health` fires once when the NPC drops to that share of its health; one with `Interval` fires every so many seconds (randomised by 15%, first after `FirstDelay`, default 4) while it has an enemy and the ability can be used.

| Type | What it does | Settings |
| --- | --- | --- |
| `slam` | A red circle grows on the ground under the boss, then everyone inside is hit (the boss's normal hit times `Damage`) and knocked back. Step out of the circle. | `Radius`, `Range` (only used when the target is this close), `Windup`, `Damage`, `Sound` |
| `enrage` | Hits harder from then on, glows red and the health bar turns orange. | `Damage`, `Line`, `Sound` |
| `warcry` | Every NPC of its race nearby hits harder for a while and glows amber. | `Radius`, `Damage`, `Duration`, `Line`, `Sound` |
| `guard` | Takes much less damage for a few seconds and glows blue. Wait it out. | `Duration`, `Reduction`, `Line` |
| `blink` | Vanishes in dust: away from a target that gets too close, or with `Behind = true` to just behind the target. | `Range`, `Behind`, `Sound` |
| `summon` | Calls NPCs. By default they rise from the ground and crumble when the boss dies; `Rise = false` and `Bound = false` make them walk in and stay, for soldiers. They give a quarter of the experience and no loot. | `NPC` (list), `Count`, `Max`, `LevelOffset`, `Line`, `Sound` |

`Line` is announced to players near the boss. The bosses so far:

| Boss | Abilities |
| --- | --- |
| Black Jory (18) | Rages at 40% |
| Red Hal (around 30) | War cry every 22 seconds, rages at 35% |
| Sir Gaspard Thorne (61) | Slam, war cry at 60%, rages at 30% |
| Lord-Marshal Vane (70) | Raises his guard every 16 seconds, slam, rings a bell for two soldiers or knights at 50%, rages at 25% |
| Barrow Lord (92 to 100) | Slam, rages at 35% |
| The Necromancer (125) | Raises skeletons every 12 seconds, blinks away when you close in, tears open the graves for three more at 50%, rages at 20% |
| The Gravewight, The Pale Knight, The Night Beast | See Night monsters |

### Medieval weapons

`sh_items_medieval.lua` holds six weapon classes: four melee and two ranged. Each class has its own ladder with a new weapon every 10 levels up to level 150. The ladders are staggered, so something new turns up every few levels, and any class can be used at any level.

| Class | Ladder levels | Speed | Trait |
| --- | --- | --- | --- |
| Sword | 1, 10, 20 ... 150 | 1.7, fast | Quickest swings |
| Axe | 5, 15, 25 ... 145 | 1.4 | +10% critical chance (`Item.CritBonus`) |
| Spear | 8, 18, 28 ... 148 | 1.2 | Reaches 95 units instead of 70 (`Item.Range`). One-handed, so it works with a shield |
| Hammer and mace | 3, 13, 23 ... 143 | 0.9, slow | Hits about 1.8 times harder per swing |
| Bow | 6, 16, 26 ... 146 | 1 shot a second (0.5 s draw, 0.5 s nock) | Ranged, uses arrows. 85% of melee damage per second |
| Crossbow | 12, 22, 32 ... 142 | 1 shot every 2 seconds (1.5 s reload) | Ranged and very accurate, uses bolts. Big single hits, 90% of melee damage per second |

Damage comes from `GM:GetWeaponTierPower(class, level)` in `gamemode/core/sharedfiles/sh_combat.lua`. It reads the `8 + 0.55 x level` curve half a gap ahead of the weapon's level (5 levels), so a weapon is a little strong when you get it and a little weak when the next one arrives. The class traits are paid for in swing speed, so damage per second stays within about 10% across classes, counting crits for axes. Hammers get 5% more because every swing slows you for `1 / speed` seconds. Class numbers are in `GM.WeaponClasses`.

| Class | Ladder |
| --- | --- |
| Sword | Rusty Sword, Arming Sword, Short Sword, Iron Longsword, Knight's Longsword, Steel Longsword, Silvered Sword, Silver Longsword, Glass Longsword, Moonglass Longsword, Ebony Longsword, Ashen Ebony Longsword, Gravensteel Longsword, Gravensteel Bastard Sword, Dreadforged Longsword, Dreadforged Oathblade |
| Axe | Hand Axe, War Axe, then a Hatchet and a Bearded Axe in each of Iron, Steel, Silver, Glass, Ebony and Gravensteel, then Dreadforged War Axe |
| Spear | Spear, Boar Spear, then a Spear and a Partisan in each of Iron, Steel, Silver, Glass, Ebony and Gravensteel, then Dreadforged Spear |
| Hammer and mace | Smithing Hammer, War Hammer, then a Mace and a Maul in each of Iron, Steel, Silver, Glass, Ebony and Gravensteel, then Dreadforged Maul |
| Bow | Hunting Bow, Horn Short Bow, Yew Longbow, then two bows in each of Iron/Steel, Silver, Glass, Ebony and Gravensteel, then Dreadforged Longbow |
| Crossbow | Light Crossbow, then a Crossbow and an Arbalest in each of Iron, Steel, Silver, Glass, Ebony and Gravensteel, then Dreadforged Arbalest |

**Bows and crossbows.** They use the Bremergard bow and crossbow models. Damage per tier comes from the full shot cycle, draw plus reload (`GM:GetWeaponCycleRate`), so a slow crossbow hits much harder per bolt. Both are two-handed, so no shield. Ammo is `item_arrows` (20 arrows) and `item_bolts` (15 bolts): use a bundle from your inventory to fill your quiver. The General Store and the Bowyer and Fletcher (`shop_ranged`) sell both, and the bowyer sells bows and crossbows up to level 20. Bows are crafted by Leatherworking at a leatherworking bench, crossbows by Blacksmithing with leather.

**Removed Underdone items.** The old sci-fi gear is gone: all guns and gun ammo, the cyborg, Overseer and Combine armor, the jetpack, gas mask, headcrab hat, scanner goggles, meta-carbon and composite shields, the EMP tool, power hammer, circular saw, car exhaust and anti-virus. Their two quests (Arsenal Upgrade and An offer you can't refuse) and the two sets went with them. A saved character that still holds one of these items is paid its old sell price in denars when it loads (`GM.RemovedItemValues` in `sh_items_removed.lua`). New characters start with a Rusty Sword, a Hunting Bow and 40 arrows.

Only a few weapon shapes exist (Bremergard sword, axe, spear and hammer, the five NPC Melee Weapons models, and the six Morrowind longswords), so most tiers recolour a shape with the metal's tint. Swap in a better model or adjust positions with the armor builder (below). The NPC Melee Weapons models use the hand positions from that addon. Item ids did not change, so old saves still load, but levels moved: the Iron Longsword went from 10 to 30, the Steel Longsword from 25 to 50 and the Glass Longsword from 70 to 80.

### Medieval armor

Slots open by item level. Chest and off hand are open from 1, boots from 5, the waist from 10, the helmet from 15 and shoulders from 20. `GM.SlotUnlockLevel` in `sh_combat.lua` holds the numbers, and `sh_items_zz_slotlevels.lua` raises any item in those slots to its unlock level, including leftover Underdone items. Rings and necklaces are in Jewelry below.

`sh_items_armor_medieval.lua` builds armor out of base-game shapes, textured with the Bremergard pack's leather, iron, steel and wood, and fitted to the default player body. A set arrives every 20 levels. Each set is four pieces (helmet, chest, shoulders, belt) with a set bonus; shields are a separate ladder at the same levels and are not part of a set, so ranged builds are not penalised.

| Level | Set | Helmet, chest, shoulders, belt | Shield |
| --- | --- | --- | --- |
| 1 to 15 | Recruit's Kit | Padded Coif (15), Padded Gambeson (1), Quilted Belt (10), no shoulders yet | Buckler (1) |
| 20 | Garrison Plate | Great Helm, Iron Breastplate, Iron Pauldrons, Sword Belt | Round Shield |
| 40 | Warden's Plate | Kettle Hat, Steel Cuirass, Steel Pauldrons, Steel-Studded Belt | Guard Shield |
| 60 | Silverguard Plate | Silver Great Helm, Cuirass, Pauldrons, Studded Belt | Silvered Guard Shield |
| 80 | Glasswright Plate | Glass Kettle Helm, Cuirass, Pauldrons, Studded Belt | Glass Round Shield |
| 100 | Ebon Bulwark | Ebony Great Helm, Cuirass, Pauldrons, Studded Belt | Ebony Guard Shield |
| 120 | Gravenwarden Plate | Gravensteel Helm, Cuirass, Pauldrons, Belt | Gravensteel Round Shield |
| 140 | Dreadforged Regalia | Dreadforged Great Helm, Cuirass, Pauldrons, Belt | Dreadforged Guard Shield |

Boots are their own ladder and not part of any set: Leather Boots (5), Iron-Shod Boots (20), then Steel, Silver, Glass, Ebony, Gravensteel and Dreadforged Sabatons at 40, 60, 80, 100, 120 and 140.

How the numbers are set, all in `sh_combat.lua`:

- Armor per piece is `GM:GetArmorTierValue(slot, level)`. It takes the combat armor curve (`10 + 3 x level`) 6 levels ahead of the piece's level and splits it by slot share (chest 1.5, shield 1.2, helmet, shoulders and belt 1 each, boots 0.3) across only the slots open at that level. A full set therefore always matches the curve, and the early pieces are not under-armored because later slots are not open yet. The gap between sets means you take a little less damage than the curve right after a new set and a little more just before the next one.
- Price is `16 x level^1.5` for weapons (`GM:GetGearPrice`). Armor uses 0.6 times its slot share of that (`GM:GetArmorPrice`).
- Piece buffs: helmets give max health equal to half the level; shoulders and belts give strength equal to level / 60 from level 30. Boots are mostly for speed: they add `6 + level / 4` move speed (`stat_movespeed`, a hidden stat added straight to walk and run speed, base 270; `GM.Combat.BootSpeedBase` and `BootSpeedPerLevel`) and agility equal to level / 60 from level 30. The set bonus is max health equal to the level and strength equal to level / 40 (at least 1).

The sets reuse the same prop-built shapes (three helmet shapes, the gambeson and breastplate, one pair of pauldrons, the sword belt and quilted belt, and the buckler, round and guard shields) with the metal parts re-textured and tinted per tier. Fit and tweak any of them with the armor builder.

### Jewelry

`sh_items_jewelry.lua`. Rings fit either ring slot and are only obtained by crafting at first. Necklaces are crafted and sold.

| Item | Levels | Effect |
| --- | --- | --- |
| Band of Might | 15, 35, 55 ... 135 | Strength, level / 45 (at least 1) |
| Band of Finesse | same | Dexterity, level / 45 (at least 1) |
| Band of Vigor | same | Max health, 0.35 x level |
| Band of Fortune | same | Luck, level / 8 |
| Pendant | 30, 50, 70 ... 150 | Max health, 0.7 x level |
| Talisman | same | Luck, level / 6 |

Rings are not sold in shops. From level 45 there are six unique rings that are meant to come from quests (`Item.QuestReward = true`): Dunmarrow Oathring (45), Kaelmoor Smuggler's Signet (65), Council Seal Ring (85), Gravenmark Wardenband (105), Ashen Vow (125) and Valcrest Signet (145). Mother Edda gives the Dunmarrow Oathring (The Swollen Dead) and the Ashen Vow (Who Wakes the Barrows); the others are not handed out yet.

### Loot rarity

`sh_rarity.lua` and `sh_items_zy_rarity.lua`. Besides the crafted (common) gear there are three rarities, shown as a coloured frame around the icon and a line in the tooltip:

| Rarity | Frame | Base damage or armor | Stat bonus (share of expected stats at the item's level) | Sells for |
| --- | --- | --- | --- | --- |
| Uncommon | Green | x 1.05 | 8% | 40% of the crafted item |
| Rare | Blue | x 1.10 | 16%, or 8% plus a power | 60% |
| Epic | Purple | x 1.15 | 16%, or 8% plus a power | 80% |

Loot sells for less than the crafted item it is based on because elites drop it on every kill; at full price elites would be the best way to make denars.

Greens and blues are generated at load time: every crafted weapon and armor piece (not jewelry) gets one copy per fitting suffix in `GM.LootSuffixes`, named `<item>_<suffix>` (for example `weapon_melee_steel_longsword_bear`, "Steel Longsword of the Bear"). Melee weapons get strength suffixes, ranged weapons dexterity ones, and armor both plus health. Rare suffixes "of Embers" (hits can set the target alight) and "of the Leech" (kills heal) carry powers. Bonuses scale with the expected stats and health at the item's level, so a suffix is worth about the same at level 10 and level 150. Copies keep their base item's model, icon and equipment set (a variant counts as the set piece), and are never crafted or sold in shops.

Epics are hand-made uniques built on a crafted item, defined at the bottom of `sh_items_zy_rarity.lua` with `Unique(...)`. The first is Thorne's Oath, Sir Gaspard Thorne's sword (based on the Knight's Longsword, kills restore 5% health).

Items with powers use the skill hooks: anything in an item's `Hooks` runs from `Player:CallSkillHook` while it is worn, at rank 1, and there is a new `on_hit` hook (`ply, rank, victim, damage`) called whenever a player damages an NPC.

An NPC with `NPC.EliteLoot` always drops exactly one of these on top of its normal drops:

```lua
NPC.EliteLoot = {
	Epic = {"unique_thornes_oath"},             -- epics this elite can drop; without any, an epic roll becomes rare
	Rarity = {uncommon = 70, rare = 25, epic = 5}, -- optional, these are the defaults
	LevelRange = 10,                             -- optional, greens and blues from (elite level - 10) to its level
	Slots = {"slot_primaryweapon"},              -- optional, only these slots
	Rolls = 1,                                   -- optional, more than one guaranteed drop
}
```

Sir Gaspard Thorne is the first elite. Rare and epic drops are announced in chat. All numbers are in `GM.Rarities` and `GM.RarityTuning` in `sh_rarity.lua`. Give yourself a variant with its name, for example `udk_edit_items_giveitem weapon_melee_longsword_warlord`; the item editor's give menu leaves the variants out.

### Legendaries: the Rebellion

`sh_items_zy_rebellion.lua` and `quests/sh_quest_rebellion.lua`. Legendary (orange) items are quest rewards only: they never drop, can't be sold, dropped or given away, and get their own icons from the icon renderer. Base damage or armor x 1.20, and a 20% stat budget split with their power. `GM:MakeLegendaryItem` in `sh_items_zy_rarity.lua` makes new ones.

Ulric's questline "The Rebellion" starts at level 100 after "The First Sitting". The first quest gives the sword; each later quest takes the current stage and crafting materials and gives the next, so the sword is awakened every 10 levels and changes its look each time:

| Level | Sword | Look | Also rewards |
| --- | --- | --- | --- |
| 100 | Start of the Rebellion | Plain iron longsword | |
| 110 | Voice of the Rebellion | Steel | |
| 120 | Banner of the Rebellion | Silver | Signet of the Trifecta |
| 130 | Fire of the Rebellion | Gravensteel | |
| 140 | Fury of the Rebellion | Blood-dark ebony | Ember of Dunmarrow |
| 150 | Rebellion | Crimson dreadforged | |

| Item | Power |
| --- | --- |
| The sword | Each kill grants a stack of Rally (+3% damage for 10 seconds), up to as many stacks as its stage. At stage six, kills at full Rally also restore 3% health |
| Signet of the Trifecta (ring, 120) | One more food effect at once, and food and Rested last 25% longer |
| Ember of Dunmarrow (amulet, 140) | 15% less damage taken while below half health |

Wearing all three gives the "Regalia of the Rebellion" set bonus. Every stage of the sword counts as the sword for the set (later stages have `BaseItem = "legendary_rebellion_1"`). The quest story text is a first draft.

### Gems and sockets

Gems (`sh_gems.lua`, `sh_items_gems.lua`) socket into gear for small extra stats. There are five kinds, ruby (Strength), emerald (Dexterity), sapphire (Max Health), topaz (Agility) and amethyst (Luck), in eight grades that follow the craft bands: Chipped (1), Rough (20), Flawed (40), Cut (60), Clear (80), Bright (100), Flawless (120) and Perfect (140). A gem gives `GM:GetAffixStat(stat, grade level, 0.05)`, a small share of what a piece of gear gives at that level.

Weapons have one socket, two if they are epic, legendary or unique. Helmets, chests, shoulders, belts, off hands and boots have one. Necklaces and rings have none.

- **Where gems come from:** every mined vein has a 4% chance (more with Luck) to give a gem of the ore's band. Elites drop one 25% of the time and bosses (`EliteLoot.Rolls` 2 or more) 50%, of the band of their level. Summoned NPCs drop none.
- **Socketing:** double-click a gem to set it into your worn weapon, or the first worn armor piece with a free socket. Or right-click it and pick any worn or carried item under "Socket into ...". The item's tooltip lists each socket, filled or empty.
- **Removing:** right-click a socketed item and choose "Remove gems". You get the gems and the plain item back, for half the gems' value in denars.
- **How it is stored:** a socketed item is its own item name, `<item>__gem_<kind>_<grade>`, with one part per gem, built on demand from that name on the server and client. Saving, trading, banks and shops treat it like any other item, and set bonuses still count it as the original piece.
- **Tuning:** `GM.Gems` holds the stat budget, drop chances, removal fee and which armor slots get a socket.
- **Testing:** `UD_Dev_GiveGems <grade>` gives one of each kind; `UD_Dev_GiveItem gem_ruby_3` gives one gem.

### Crafting

Three trades replace the old Underdone ones: **Blacksmithing**, **Leatherworking** and **Tailoring**. Trades level from tier 1 to 15 in the Character tab. A recipe needs the trade tier `ceil(item level / 10)`, so a level 30 sword needs tier 3 and a level 150 sword tier 15. Mining (below) is a fourth trade. You can hold 60 tiers in total, enough for all four trades at 15, and you pay one tier at a time with the arrow button once the bar is full. Crafting gives trade experience (`25 + 12 x tier`, scaled down when the recipe is easy for you), and a craft always succeeds when you meet the requirements.

| Item | Trades |
| --- | --- |
| Weapons, helmets, rings, necklaces | Blacksmithing |
| Shoulders, shields | Blacksmithing and Leatherworking |
| Chest pieces from level 20 | Blacksmithing and Tailoring |
| Belts from level 20 | Leatherworking |
| Gambeson, coif and quilted belt (the Recruit's Kit) | Tailoring |

**Stations.** Each trade crafts at its own station, within 200 units: Blacksmithing (and smelting) at a forge or anvil, Leatherworking at a leatherworking bench, and Tailoring at a tailoring table. Place them with the map editor's **World props** mode: the first three icons in the grid are the stations.

| Station | Built around | Decoration |
| --- | --- | --- |
| Forge (`station:forge`) | Stone fireplace | Coal brazier in the hearth, anvil with tongs and hammer, iron bars, quenching trough, log pile |
| Tailoring table (`station:tailoring`) | Work table | Cloth basket, open pattern scroll, three bolts of cloth, a dressed mannequin, a stool |
| Leatherworking bench (`station:leatherwork`) | Wooden bench | Hide on the bench, a mallet, a stretching frame with a hide, a tanning vat, a stool |

Only the main prop is solid; the decoration is drawn on every client around it. The stations are defined in `GM.StationBuilds` in `sh_stations.lua`, where each decoration part has a model, position and angle relative to the main prop, and an optional scale, material and tint. The Bremergard anvil and brazier still count as smithing stations on their own (`GM.CraftingStations` in `sh_recipes.lua`). Press E on a station to open the crafting window on its trade, or use **Library > Crafting ...** in the inventory, or `UD_OpenCraftMenu [smithing|leatherwork|tailoring]`.

**Recipes** are generated in `sh_recipes_gear.lua`, one per equipment item marked `Item.Crafted = true`. Every recipe is known from the start, and the window shows what you can make and what you are missing. A recipe can still use `Recipe.Hidden = true` to need a book (`GainRecipes` on a book item).

**Materials** (`sh_items_materials.lua`) come in eight bands of 20 levels, each with a metal, a leather and a cloth. An item uses the band of its level, so a level 30 item uses the iron band.

| Band | Levels | Metal | Leather | Cloth |
| --- | --- | --- | --- | --- |
| 1 | 1 to 19 | Scrap Iron | Rough Hide | Linen Bolt |
| 2 | 20 to 39 | Iron Ingot | Tanned Leather | Wool Bolt |
| 3 | 40 to 59 | Steel Ingot | Boiled Leather | Canvas Bolt |
| 4 | 60 to 79 | Silver Ingot | Waxed Leather | Silk Bolt |
| 5 | 80 to 99 | Glass Ingot | Stag Leather | Brocade Bolt |
| 6 | 100 to 119 | Ebony Ingot | Bearhide | Velvet Bolt |
| 7 | 120 to 139 | Gravensteel Ingot | Direwolf Hide | Gilded Brocade |
| 8 | 140 to 150 | Dreadforged Ingot | Wyrmhide | Royal Velvet |

**Where materials come from.** Metal comes from mining ore and smelting it (below). Every Morvaine and Gallows Company enemy drops the cloth of its own level band (4% chance, one at a time, `GM.Combat.ClothDropChance`) and, rarely, its leather (0.5%, one at a time, `GM.Combat.LeatherDropChance`), so what drops follows the level you spawn the enemy at. Brannoc Hale (`shop_smith`, shop `shop_craftsupplies`) sells bands 1 and 2 only (`GM.Combat.ShopMaterialMaxBand`), and the Dunmarrow Quartermaster sells band 1. The level 13 quest "Iron for the Levy" hands out a starter bundle and three starter recipes.

**Recipes.** Gear recipes have to be learned (`sh_items_zz_zrecipescrolls.lua`). Every craftable weapon, armor piece and piece of jewelry has a recipe scroll named after its trade: "Smith's Notes: Steel Longsword", "Tanner's Pattern: ...", "Tailor's Pattern: ...", "Bowyer's Notes: ..." for bows and crossbows, and "Jeweller's Sketch: ..." for rings and necklaces. Use a scroll to learn the recipe for good (it is kept in your library and saved). A scroll for a recipe you already know can be sold or given away. Every equipment set with two or more crafted pieces also has a folio, for example "Folio: Warden's Plate", that teaches the whole set at once. Smelting recipes are always known.

| Source | What |
| --- | --- |
| Any enemy | 1.5% chance per kill for a scroll (Luck raises it) |
| Elites | 12% per kill, and 40% of those are folios |
| Book Store (`shop_books`) and Brother Aldwin's Scribe's Satchel (`shop_scribe`) | Starter scrolls: every recipe of level 12 or below (Rusty Sword, Arming Sword, Hand Axe, Spear, Smithing Hammer, Hunting Bow, Light Crossbow, Padded Gambeson, Buckler, Quilted Belt) |
| "Iron for the Levy" | Arming Sword, Hunting Bow and Padded Gambeson |

A dropped scroll is for an item between 15 levels below and 3 levels above the enemy, and it is one you don't know yet if there is one. Morvaine soldiers lean towards smithing notes, and Gallows Company bandits towards leather and tailoring patterns. The killer gets a chat line naming the scroll. All numbers are in `GM.RecipeDrops`. Brother Aldwin (`shop_scribe`, "Scribe of Dunmarrow") is a new camp NPC: place him with the map editor. Give yourself a scroll by name, for example `UD_Dev_GiveItem recipe_scroll_weapon_melee_steel_longsword` or `UD_Dev_GiveItem recipe_folio_set_recruit`.

**Shops.** The Blacksmith (`shop_melee`) and the Armor Store (`shop_armor`) sell weapons, armor and necklaces up to level 20 (`GM.Combat.ShopGearMaxLevel`) at 2.7 times the item's sell price, listed by level. Better gear is crafted or looted. The Quartermaster sells gear up to level 20.

**Fair crafting.** The material value of a recipe is at least half of the item's sell price (`GM.Combat.CraftValueShare`, rounded up), so crafting from bought materials costs roughly half of buying the item. It can never make money by buying materials, crafting and selling, even with the two price skills stacked (about 17% off). Recipe counts follow the item's price, so higher-level items in a band cost more materials than lower ones. Material prices are set from the band's top level (`GM.Combat.CraftUnitsAtBandTop`).

The old Underdone trades (Mechanical, Electrical, Chemical, Physics, Biotech, Culinary, Horticulture and Crafting) and their recipes were removed. Their recipe books are still defined so old saves load, but teach nothing and are no longer sold.

### Mining and smelting

Ore veins are placed with the map editor's **Ore veins** mode (`sh_items_ores.lua`, `sh_mining.lua`). Press E on a vein to mine it for 3 seconds: you get 2 or 3 ore (sometimes one more with Luck) and Mining experience, and the vein disappears until its respawn time has passed (180 seconds by default, set per vein). Looking at a vein shows its ore and whether your Mining tier is high enough.

| Ore | Smelts into | Mining and Blacksmithing tier | Place veins in areas of level |
| --- | --- | --- | --- |
| Bog Iron | Scrap Iron | 1 | 1 to 19 |
| Iron | Iron Ingot | 2 | 20 to 39 |
| Blackiron | Steel Ingot | 4 | 40 to 59 |
| Silver | Silver Ingot | 6 | 60 to 79 |
| Glass Crystal | Glass Ingot | 8 | 80 to 99 |
| Ebony | Ebony Ingot | 10 | 100 to 119 |
| Gravenstone | Gravensteel Ingot | 12 | 120 to 139 |
| Dreadstone | Dreadforged Ingot | 14 | 140 to 150 |

Smelting is a Blacksmithing recipe at an anvil or forge (`sh_recipes_smelting.lua`): 2 ore make 1 ingot, or 10 ore make 5 in one go. The Smelting filter in the crafting window lists them. Each vein uses one of the stone models in `GM.OreVeinModels` (the rp_bremergard_forest stones first, then two HL2 granite rocks), tinted per ore, with the bottom 30% sunk into the ground where you click (`GM.OreVeinSink`).

### Armor builder

`UD_Dev_EditPaperDoll` opens the armor builder (single player). It shows a live preview on your character:

1. Pick a **slot**. It loads the item you wear there, or press **Start empty**.
2. **Add part**, then choose its model with **Browse** or type any model path and press Enter. Browse opens a searchable window of model pictures: a suggested set (shapes, bones and creatures such as skulls, spines and antlion shell, household props, medieval models), or every model in a folder such as the Bremergard pack, gibs, junk or street props. Click one to put it on the selected part; the window stays open so you can try several.
3. Move it with **Position**. On the head, chest, shoulder and waist slots this is forward / left / up from the slot point, so it means the same on every slot. Turn it with **Angle**, size it per axis with **Scale**.
4. Give it a **Material** and a **Tint**. Browse shows texture swatches: the suggested set (Bremergard leather, iron, steel and wood, cloth, and specials such as flesh, crystal, swirling energy and glow), every texture in a folder, or **Materials of a model**, which lists the textures of any model you type. **Own** puts the model's own material back.
5. Add **Effects** for the whole item (glow, embers, smoke, sparkles, light) and set their colour, size, amount and pulse. See Item effects below.
6. **Duplicate** copies a part, **Mirror** copies it to the other side of the body (pauldrons, greaves), **Remove** deletes it. The selected part has a yellow box.
7. **Copy item Lua** puts the `AddModel` lines (and `Item.Effects`) on the clipboard (and in the console). Paste them into an item. While the builder is open your design is worn live in that slot and follows every slider. **Apply to worn item** keeps the design on the item you wear there after you close the builder, until the map changes.

The camera sliders orbit around your character (0 is the front). To get items to test with, use `UD_Dev_GiveItem <item> [amount]`.

### Item effects

Any item can glow, smoke or throw sparks while it is worn (`sh_item_effects.lua`). Add them in the armor builder's Effects section, or by hand:

```lua
Item.Effects = {
	{Type = "glow", Color = Color(220, 30, 30), Size = 1, Amount = 1, Pulse = 1},
	{Type = "embers", Color = Color(255, 90, 40), Size = 1, Amount = 1, Pulse = 1},
}
```

| Type | Look | Size | Amount | Pulse |
| --- | --- | --- | --- | --- |
| `glow` | A coloured sheen over every part of the item | Brightness | Not used | Pulse speed (0 = steady) |
| `embers` | Glowing motes drifting up off the item | Mote size | How many | Not used |
| `smoke` | Thin smoke curling off the item | Puff size | How many | Not used |
| `sparkle` | Short twinkles along the item | Twinkle size | How many | Not used |
| `light` | Lights up the surroundings | Light radius | Brightness | Pulse speed |

Particles appear at random points on the item's parts. Effects show on worn gear (yours and other players'), not yet on items held by NPCs. The later Rebellion swords use them: Fire of the Rebellion has embers, Fury of the Rebellion a dark red glow and smoke, and Rebellion a crimson glow, embers and a red light.

### Weapon clash sounds

A melee hit on an armed enemy (a player, or an NPC with `HeldItems`) plays a random weapon clash from the attacker's weapon group (`sh_sounds.lua`): swords, axes, spears, and maces for hammers. Hits on unarmed creatures keep the normal impact sound. The 623 clips in `content/sound/gravenmark/clash/` were cut from the 48 recordings of "Medieval sound effects - Weapon impacts" (see Credits): every hit in a recording became its own clip, converted from 24-bit 192 kHz to 16-bit mono 44.1 kHz (the game cannot play the originals), with a short fade and even volume. The file names start with the group (`axe_`, `mace_`, `spear_`, `sword_`), so new clips dropped into the folder with the right prefix are used automatically.

### NPC voices

Quest givers and shopkeepers speak (`sh_sounds.lua`): a greeting when you press E on them, a "new objective" line when you accept a quest, and an "objective met" line when you hand one in. An NPC waits 4 seconds between lines (`GM.VoiceCooldown`), but accepting or handing in always plays.

There are four voices, from "Voice acting sketch [Open Dungeons]" (see Credits): `hero`, `dwarf`, `keeper_groan` (gruff) and `keeper_neutral` (calm). Set one with `NPC.Voice = "dwarf"`, or `NPC.Voice = false` for a silent NPC. An NPC without one gets a fixed voice picked from its name, except NPCs with a female model, who stay silent because all four voices are male. Sergeant Osric uses `hero`, Ulric `keeper_neutral`, Halvard `keeper_groan` and Brannoc `dwarf`.

The lines are in `content/sound/gravenmark/voice/<voice>/<line>_<n>.ogg`, where `<line>` is `greeting`, `objectivenew`, `objectivemet`, `objectivefailed`, `victory`, `defeat`, `enemydefeated`, `allydefeated` or `underattack`. Only the first three are used so far. The pack's dungeon-management lines about creatures were left out.

### Item icons

`UD_Dev_RenderIcons` (single player) renders inventory icons from the items' own models (`cl_icon_renderer.lua`). Each item is drawn off-screen at 128 x 128 on a parchment background with fixed studio lighting, framed automatically to fill the icon, and saved to `data/gravenmark_icons/<item>.png`. The new icon shows in your inventory straight away.

| Command | Renders |
| --- | --- |
| `UD_Dev_RenderIcons` | Every gear item, ore and crafting material that has a model and no generated icon yet |
| `UD_Dev_RenderIcons <filter>` | Only items whose name contains the filter, for any item with a model except jewelry (rings and necklaces have no model of their own and keep their icons), for example `weapon_melee_iron` |
| `UD_Dev_RenderIcons <filter> force` | The same, even if an icon already exists. Use `UD_Dev_RenderIcons all force` to redo everything |

Armor is shown from the front (helmets three-quarter front), weapons from the side running diagonally, and shields from their face. An item that looks wrong can set its own view, where `Zoom` above 1 moves closer:

```lua
Item.IconView = {Angle = Angle(0, 210, 0), Zoom = 1.1}
```

To keep the icons, copy the PNG files from `garrysmod/data/gravenmark_icons/` to `content/materials/icons/gen/` and commit them. `sh_items_zzz_icons.lua` gives every item with a file there its generated icon, and items without one keep their old icon. Icons only in the data folder are also used, but only on your own machine. An icon rendered again with `force` shows its new picture after a map change, because the game caches images it has already loaded.

### Skills and leveling

Characters can reach level 150. Each level needs more experience than the last (25 x level + 1.5 x level², about 12,000 equal-level kills from 1 to 150), and every level adds 6 max health and, every third level, 1 Strength and 1 Dexterity. Admins can use `UD_Admin_GiveExp <amount> [name]` and `UD_Admin_SetLevel <level> [name]`.

| Level | Experience to next level | Equal-level kills per level |
| --- | --- | --- |
| 1 | 26 | about 18 |
| 10 | 400 | about 24 |
| 25 | 1,562 | about 38 |
| 50 | 5,000 | about 60 |
| 100 | 17,500 | about 106 |
| 149 | 37,026 | about 150 |

A kill gives the enemy's max health x its level / your level / 12 (`GM.KillExp` in `sh_combat.lua`). The level ratio is held between 0.25 and 1.5, so enemies far above you don't give runaway experience and grey enemies still give a little.

You get one skill point per level and a bonus point every 10 levels (165 at level 150). The Skills tab in the main menu shows five branches: The Sword-Arm (melee), The Fletcher's Eye (ranged), The Bulwark (defense), The Wayfarer (food, rest, carrying, coin) and The Banner (luck, experience, squad auras). New rows unlock at levels 1, 5, 12, 20, 30, 45, 60, 80, 105, 130 and 150, each skill needs the one above it, and each branch ends in a capstone at level 150 that costs 5 points. Click a skill with a gold border to learn it; **Forget skills** refunds everything for 20 denars per level (at least 100).

Skills live in `gamemode/core/sharedfiles/database/skills/`. Use `CreateSkill`, `AddSkillStatDesc` / `SetSkillDesc` and `RegisterSkill`; hooks include `damage_mod`, `firerate_mod`, `damage_taken_mod`, `armor_mod`, `exp_mod`, `food_mod`, `price_mod`, `drop_mod`, `buff_duration_mod` and `on_kill`, plus `Skill:Think(ply, rank)` (every second) and `Skill:BulletCallBack`.

Combat balance numbers are in `GM.Combat` in `gamemode/core/sharedfiles/sh_combat.lua`. An enemy's `HealthPerLevel` is its health per level (20 is a standard soldier, about 4 to 6 hits at equal level), and `DamagePerLevel` is its hitting power relative to 3 (a standard soldier takes about 12 hits to kill an unarmored player of its level, 24 in a full set of level-appropriate armor).

### Food and rest

Food from the camp cook heals a share of your max health and gives a timed effect shown at the bottom left of the screen. Only one food effect is active at a time (two with the Wayfarer capstone); eating another replaces it.

| Food | Effect | Duration |
| --- | --- | --- |
| Rye Bread | 8% more max health | 15 min |
| Barley Porridge | 1% health every 4 seconds | 15 min |
| Trail Rations | 4% more max health, +3 max weight | 30 min |
| Smoked River Trout | 6% more ranged damage | 20 min |
| Summer Melon | 5% less damage taken | 10 min |
| Jar of Forest Honey | +25 movement speed | 10 min |
| Dunmarrow Ale | 10% more melee damage, 5% more damage taken | 10 min |
| Hunter's Stew | 6% more melee damage, 5% more max health | 20 min |
| Kaelmoor Red | 6% more experience | 15 min |
| Captain's Feast | 5% more damage, 10% more max health, 5% more experience | 30 min |

Use the Wayfarer's Bedroll (or press E on a bed or bedroll prop) to sleep for a few seconds and wake up **Rested**: full health, 25% more experience and slow healing out of combat for 30 minutes (45 in a real bed). You can't rest within 10 seconds of being hit, with an enemy chasing you, or while Rested still has more than 5 minutes left. Food and Rested survive death; combat effects don't. Beds compiled into the map itself can't be used; place bed props with the map editor instead.

### Searchable containers

Using a prop whose model is listed in `GM.SearchableProps` (`gamemode/init.lua`) searches it for a random item from `GM.SearchLoot`. That covers the medieval chests from the Bremergard pack, including the two already placed in the map.

## In-game editors (single player, admin)

| Console command | What it does |
| --- | --- |
| `UD_Dev_EditMap` | Opens or closes the map editor for NPC spawn points, props, player spawns, ore veins and patrol routes. Layouts are saved per map to `data/underdone/Maps/<map>.txt`. |
| `UD_Dev_SetTime <hour>` | Sets the time of day, 0 to 24. Without a number it prints the time. |
| `UD_Dev_NightCheck` | Lists every NPC with a day or night spawn time in the console: whether it is allowed out now, whether it counts as fighting, its enemy and how long until it is forced out. |
| `UD_Dev_SummonRoamer [route] [npc]` | Spawns a night monster on a ticked route, or on the route number given. |
| `UD_Dev_GiveGems <grade>` | Gives one gem of each kind, grade 1 to 8. |
| `UD_ResetCharacter confirm` | Wipes your character (level, items, bank, skills, quests, trades) and starts a new one. Your old save is copied to `data/underdone/backups/` first. In single player the map restarts; on a server you are kicked and start fresh when you rejoin. Anyone can use it on themselves. |
| `UD_Dev_EditPaperDoll` | The armor builder: design or adjust worn equipment from props and copy the item Lua. |
| `UD_Dev_RenderIcons [filter] [force]` | Renders item icons from the item models into `data/gravenmark_icons/` (see Item icons). |
| `UD_Dev_EditPaperDoll_Debug` | Prints what the armor builder and your character are drawing, for tracking down display problems. |
| `UD_Dev_GiveItem <item> [amount]` | Gives you an item (single player, or superadmin). |
| `UD_Dev_SetTrade <blacksmithing\|leatherworking\|tailoring\|mining\|all> <tier>` | Sets a trade to tier 1 to 15 (single player, or superadmin). |
| `UD_OpenCraftMenu [smithing\|leatherwork\|tailoring]` | Opens the crafting window on that trade. Press E on a station to open it in game. |

Using the map editor:

- It opens with the mouse cursor on. Press **C** to switch between using the cursor (window and clicking in the world) and looking around with the mouse. WASD moves you either way. `UD_Dev_EditMap_Mouse` does the same as C.
- **Left-click** the ground (with the cursor, or with the crosshair while the cursor is off) to place a marker, then pick its settings and press **Add**. Nothing spawns until you add it.
- **Left-click** an existing marker to select it: change its settings and press **Apply changes**, **Move** it to your next click, or **Remove** it.
- **Right-click** cancels or deselects. Your weapon does not fire while the editor is open.
- A spawn point spawns **How many NPCs** at once, randomly inside its **Spawn area radius** (0 means exactly on the marker). Each one respawns its own **Respawn** seconds after dying.
- **Ore veins** mode places mineable rocks: pick the ore, the stone model and the respawn time, then Add. Click a vein's marker to change, move or remove it.
- **Player spawns** mode places where players appear, facing the arrow's direction. Players spawn at a random one that nobody is standing on; with none placed, the map's own spawn is used.
- Spawn points also take a **Patrol route #** (0 keeps them where they spawn) and when they spawn: **Always**, **Only at night** or **Only by day**. The marker label shows both.
- **Patrol routes** mode: click the ground and press **Start a new route here**, then keep clicking to add nodes. The route is drawn in orange (purple if a night monster may roam it) with arrows showing the walking direction; the selected route shows a number on every node, and the selected node has a white ring.
  - Click a node to select it. Clicking the ground adds a new node **after the selected node**, so you can insert nodes in the middle of a route; **Select last node** goes back to adding at the end.
  - **Move selected node** then a click moves it; **Delete selected node** removes it.
  - Pick **Loop** or **Back and forth**, the wait at each node and whether they run, give it a place name (used in night monster announcements), tick **A night monster may roam this route**, pick the monster and set its level. Route settings take effect as soon as you change them; press **Save map** to keep them.
  - Click a node of another route to switch to it. Routes are also drawn in NPC spawn point mode, with a purple line from each spawn point to the nearest node of its route.
- Press **Save map** when you are done; the window shows when there are unsaved changes.

## Client options

| Console variable | Default | Effect |
| --- | --- | --- |
| `ud_showhud` | 1 | Show the HUD |
| `ud_showminimap` | 1 | Show the minimap (turn off on slow machines) |
| `ud_showcrosshair` | 1 | Show the crosshair |
| `ud_lantern` | 1 | Carry a small light at night |

## Credits

| Asset | Author | License |
| --- | --- | --- |
| Weapon clash sounds, from [Medieval sound effects - Weapon impacts](https://opengameart.org/content/medieval-sound-effects-weapon-impacts) | Ben Jaszczak and Brian Nelson (Still North Media) | CC0 |
| NPC voices, from [Voice acting sketch [Open Dungeons]](https://opengameart.org/content/voice-acting-sketch-open-dungeons) | Eugene Loza | CC0 (dual-licensed CC0 and CC-BY-SA 3.0; used under CC0) |
