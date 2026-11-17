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
| Sergeant Osric Varne (`quest_sergeant`) | Levy camp | Levels 1 to 9: gear, first kills, looting, searching chests; ends by sending you to Ulric |
| Ulric of Dunmarrow (`quest_ulric`) | His hall | Levels 10 to 28: the Threefold Council main story |
| Maren Holt (`quest_maren`) | North road | Levels 8 to 19: Kaelmoor smuggling side quests |
| Halvard Grey (`quest_halvard`) | Near Ulric | Levels 20 to 27: Vestergrim side quests; receives Ulric's council writ |
| Hilde Rook (`shop_quartermaster`) | Levy camp | Sells gear up to level 20 and starter materials |
| Old Bettany (`shop_provisioner`) | Levy camp | Camp cook, sells food and bedrolls |
| Brannoc Hale (`shop_smith`) | Next to the anvil | Master smith, sells every crafting material |
| Dunmarrow Levyman (`dunmarrow_levyman`) | Around the camp | Friendly guards that fight Morvaine and bandits |

Enemies are Morvaine (`morvaine_recruit`, `_warden`, `_soldier`, `_outrider`, `_captain`, `_knight`, `_royalguard`, boss `_marshal`) and the Gallows Company bandits (`bandit_deserter`, `_brigand`, `_sellsword`, `_veteran`, `_footknight`, `_hedgeknight`, named `bandit_jory` and `bandit_wat`, boss `bandit_raubritter`). Bandits are their own race, so they fight Morvaine too.

Suggested spawn levels: recruits 2 and deserters 5 in the pines near the camp, wardens 5 on the roads, brigands 8 with Jory 10 at their camp, soldiers 8 and outriders 10 on the north road, soldiers 14 with a captain 16 at the crossing, sellswords 13 with Wat 13 and veterans 17 at the Gallows camp, knights 19 and Hallowgate Guards 20 on the far bank, hedge knights 23, Gallows knights 25 and Thorne 26 at the robber keep, knights 26 with Vane 29 at the marshal's camp. "The Old Caches" needs at least two searchable chests near the camp.

### Equipment slots

Slots are defined in `gamemode/core/sharedfiles/database/items/sh_slots.lua`. `Position` places the slot in the paperdoll panel (percent of its width and height). A slot with `NoModel = true` gives stats only and attaches nothing to the character, like the necklace and ring slots.

Slots that share a `Group` accept the same items. Rings use `Item.SlotGroup = "ring"` and fit either ring slot; a player who owns two of the same ring can wear both. Double-clicking a ring puts it in a free ring slot (or takes it off if it's worn), and dragging it onto a ring slot puts it in that one. Another slot with `Group = "ring"` adds a third ring slot without touching any items.

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

Slots open by item level. Chest and off hand are open from 1, the waist from 10, the helmet from 15 and shoulders from 20. `GM.SlotUnlockLevel` in `sh_combat.lua` holds the numbers, and `sh_items_zz_slotlevels.lua` raises any item in those slots to its unlock level, including leftover Underdone items. Rings and necklaces are in Jewelry below.

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

How the numbers are set, all in `sh_combat.lua`:

- Armor per piece is `GM:GetArmorTierValue(slot, level)`. It takes the combat armor curve (`10 + 3 x level`) 6 levels ahead of the piece's level and splits it by slot share (chest 1.5, shield 1.2, helmet, shoulders and belt 1 each) across only the slots open at that level. A full set therefore always matches the curve, and the early pieces are not under-armored because later slots are not open yet. The gap between sets means you take a little less damage than the curve right after a new set and a little more just before the next one.
- Price is `16 x level^1.5` for weapons (`GM:GetGearPrice`). Armor uses 0.6 times its slot share of that (`GM:GetArmorPrice`).
- Piece buffs: helmets give max health equal to half the level; shoulders and belts give strength equal to level / 60 from level 30. The set bonus is max health equal to the level and strength equal to level / 40 (at least 1).

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

Rings are not sold in shops. From level 45 there are six unique rings that are meant to come from quests (`Item.QuestReward = true`): Dunmarrow Oathring (45), Kaelmoor Smuggler's Signet (65), Council Seal Ring (85), Gravenmark Wardenband (105), Ashen Vow (125) and Valcrest Signet (145). No quest hands them out yet; add them to a quest's `GainedItems` when the content above level 30 is written.

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

**Where materials come from.** Metal comes from mining ore and smelting it (below). Every Morvaine and Gallows Company enemy drops the leather and cloth of its own level band (25% chance per kind, one or two at a time), so what drops follows the level you spawn the enemy at. Brannoc Hale (`shop_smith`, shop `shop_craftsupplies`) sells bands 1 and 2 only (`GM.Combat.ShopMaterialMaxBand`), and the Dunmarrow Quartermaster sells band 1. The level 7 quest "Iron for the Levy" hands out a starter bundle.

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
2. **Add part**, then choose its model with **Browse** (shapes, household props, medieval models) or type any model path and press Enter.
3. Move it with **Position**. On the head, chest, shoulder and waist slots this is forward / left / up from the slot point, so it means the same on every slot. Turn it with **Angle**, size it per axis with **Scale**.
4. Give it a **Material** (Browse has the Bremergard leather, iron, steel and wood, plus cloth) and a **Tint**.
5. **Duplicate** copies a part, **Mirror** copies it to the other side of the body (pauldrons, greaves), **Remove** deletes it. The selected part has a yellow box.
6. **Copy item Lua** puts the `AddModel` lines on the clipboard (and in the console). Paste them into an item. While the builder is open your design is worn live in that slot and follows every slider. **Apply to worn item** keeps the design on the item you wear there after you close the builder, until the map changes.

The camera sliders orbit around your character (0 is the front). To get items to test with, use `UD_Dev_GiveItem <item> [amount]`.

### Item icons

`UD_Dev_RenderIcons` (single player) renders inventory icons from the items' own models (`cl_icon_renderer.lua`). Each item is drawn off-screen at 128 x 128 on a parchment background with fixed studio lighting, framed automatically to fill the icon, and saved to `data/gravenmark_icons/<item>.png`. The new icon shows in your inventory straight away.

| Command | Renders |
| --- | --- |
| `UD_Dev_RenderIcons` | Every gear item, ore and crafting material that has a model and no generated icon yet |
| `UD_Dev_RenderIcons <filter>` | Only items whose name contains the filter, for any item with a model, for example `weapon_melee_iron` |
| `UD_Dev_RenderIcons <filter> force` | The same, even if an icon already exists. Use `UD_Dev_RenderIcons all force` to redo everything |

Armor is shown from the front (helmets three-quarter front), weapons from the side running diagonally, and shields from their face. An item that looks wrong can set its own view, where `Zoom` above 1 moves closer:

```lua
Item.IconView = {Angle = Angle(0, 210, 0), Zoom = 1.1}
```

To keep the icons, copy the PNG files from `garrysmod/data/gravenmark_icons/` to `content/materials/icons/gen/` and commit them. `sh_items_zzz_icons.lua` gives every item with a file there its generated icon, and items without one keep their old icon. Icons only in the data folder are also used, but only on your own machine. An icon rendered again with `force` shows its new picture after a map change, because the game caches images it has already loaded.

### Skills and leveling

Characters can reach level 150. Each level needs more experience than the last (25 x level + 1.5 x level², about 6,000 equal-level kills from 1 to 150), and every level adds 6 max health and, every third level, 1 Strength and 1 Dexterity. Admins can use `UD_Admin_GiveExp <amount> [name]` and `UD_Admin_SetLevel <level> [name]`.

| Level | Experience to next level | Equal-level kills per level |
| --- | --- | --- |
| 1 | 26 | about 9 |
| 10 | 400 | about 12 |
| 25 | 1,562 | about 19 |
| 50 | 5,000 | about 30 |
| 100 | 17,500 | about 53 |
| 149 | 37,026 | about 75 |

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
| `UD_Dev_EditMap` | Opens or closes the map editor for NPC spawn points and props. Layouts are saved per map to `data/underdone/Maps/<map>.txt`. |
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
- Press **Save map** when you are done; the window shows when there are unsaved changes.

## Client options

| Console variable | Default | Effect |
| --- | --- | --- |
| `ud_showhud` | 1 | Show the HUD |
| `ud_showminimap` | 1 | Show the minimap (turn off on slow machines) |
| `ud_showcrosshair` | 1 | Show the crosshair |
