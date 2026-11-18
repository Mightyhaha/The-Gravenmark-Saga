local function QuickNPC(Name, PrintName, SpawnName, Race, Distance, Model)
	local NPC = {}
	NPC.Name = Name
	NPC.PrintName = PrintName
	NPC.SpawnName = SpawnName
	NPC.Race = Race
	NPC.DistanceRetreat = Distance
	NPC.Model = Model
	return NPC
end
local function AddBool(Table, IsFrozen, IsInvincible, IsIdle)
	Table.Frozen = IsFrozen
	Table.Invincible = IsInvincible
	Table.Idle = IsIdle
	return Table
end
local function AddMultiplier(Table, Health, Damage)
	Table.HealthPerLevel = Health
	Table.DamagePerLevel = Damage
	return Table
end
local function AddDrop(Table, Name, Chance, Min, Max, MinLevel, MaxLevel)
	Table.Drops = Table.Drops or {}
	Table.Drops[Name] = {Chance = Chance, Min = Min, Max = Max, MinLevel = MinLevel, MaxLevel = MaxLevel}
	return Table
end

local function AddMaterialDrops(Table)
	local intBands = #GM.CraftBands
	for intBand = 1, intBands do
		local intMin = intBand == 1 and 1 or (intBand - 1) * 20
		local intMax = intBand == intBands and 150 or intBand * 20 - 1
		for strKind, tblBands in pairs(GM.CraftMaterials) do
			if strKind == "leather" then
				AddDrop(Table, tblBands[intBand], GM.Combat.LeatherDropChance, 1, 1, intMin, intMax)
			elseif strKind ~= "metal" then
				AddDrop(Table, tblBands[intBand], GM.Combat.ClothDropChance, 1, 1, intMin, intMax)
			end
		end
	end
	return Table
end

local RedSide = "models/player/martin/camprouge/"
local Mercs = "models/npcs/"
local MeleeBase = "models/Humans/Group03/male_07.mdl"
local CitizenKeyValues = {citizentype = 4}

local function RedSideSet(strPrefix, intCount)
	local tblModels = {}
	for i = 1, intCount do
		table.insert(tblModels, RedSide .. strPrefix .. string.format("%02d", i) .. ".mdl")
	end
	return tblModels
end

local function MorvaineMelee(Name, PrintName, Distance, SkinModel, HeldItems)
	local NPC = QuickNPC(Name, PrintName, "npc_citizen", "combine", Distance, MeleeBase)
	NPC.Weapon = "weapon_crowbar"
	NPC.KeyValues = CitizenKeyValues
	NPC.SkinModel = SkinModel
	NPC.HeldItems = HeldItems
	NPC.DeathDistance = 14
	return AddMaterialDrops(NPC)
end

local function GallowsMelee(Name, PrintName, Distance, Model, Weapon)
	local NPC = QuickNPC(Name, PrintName, "npc_citizen", "bandit", Distance, Mercs .. Model)
	NPC.Weapon = Weapon
	NPC.KeyValues = CitizenKeyValues
	NPC.DeathDistance = 14
	return AddMaterialDrops(NPC)
end

local function QuestGiver(Name, PrintName, Title, Model, Quests)
	local NPC = QuickNPC(Name, PrintName, "npc_breen", "human", nil, Model)
	NPC = AddBool(NPC, false, true, true)
	NPC.Title = Title
	NPC.Quest = Quests
	NPC.DeathDistance = 14
	return NPC
end

local NPC = QuestGiver("quest_sergeant", "Sergeant Osric Varne", "Drillmaster of the Dunmarrow Levy", Mercs .. "mercsergeant.mdl", {
	"quest_dm_muster",
	"quest_dm_greensteel",
	"quest_dm_rations",
	"quest_dm_caches",
	"quest_trifecta_banners",
	"quest_dm_turncloaks",
	"quest_dm_coinpurses",
	"quest_dm_ironforthelevy",
	"quest_dm_blackjory",
	"quest_dm_sealedletter",
})
NPC.Voice = "hero"
Register.NPC(NPC)

local NPC = QuestGiver("quest_ulric", "Ulric of Dunmarrow", "Lord of Dunmarrow, Last of the Three Brothers", Mercs .. "merccommander.mdl", {
	"quest_trifecta_quietgift",
	"quest_ulric_ashbeads",
	"quest_trifecta_council",
	"quest_ulric_grellspride",
	"quest_ulric_ambush",
	"quest_ulric_robberknight",
	"quest_ulric_marshal",
	"quest_ulric_writ",
	"quest_rebellion_1",
	"quest_rebellion_2",
	"quest_rebellion_3",
	"quest_rebellion_4",
	"quest_rebellion_5",
	"quest_rebellion_6",
})
NPC.Voice = "keeper_neutral"
Register.NPC(NPC)

local NPC = QuestGiver("quest_maren", "Maren Holt", "Smuggler of Kaelmoor", "models/Humans/Group03/Female_02.mdl", {
	"quest_maren_wagons",
	"quest_maren_wat",
	"quest_maren_tolls",
	"quest_maren_nightcrossing",
})
Register.NPC(NPC)

local NPC = QuestGiver("quest_halvard", "Halvard Grey", "Envoy of Vestergrim", "models/Humans/Group03/Male_09.mdl", {
	"quest_halvard_proof",
	"quest_halvard_honour",
	"quest_halvard_seal",
})
NPC.Voice = "keeper_groan"
Register.NPC(NPC)

local NPC = QuickNPC("shop_quartermaster", "Hilde Rook", "npc_breen", "human", nil, "models/Humans/Group03/Female_01.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Shop = "shop_dunmarrow_quartermaster"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_provisioner", "Old Bettany", "npc_breen", "human", nil, "models/Humans/Group03/Female_04.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Title = "Camp Cook"
NPC.Shop = "shop_provisions"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_scribe", "Brother Aldwin", "npc_breen", "human", nil, "models/Humans/Group03/Male_04.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Title = "Scribe of Dunmarrow"
NPC.Shop = "shop_scribe"
NPC.Voice = "keeper_neutral"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_smith", "Brannoc Hale", "npc_breen", "human", nil, "models/Humans/Group03/Male_07.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Title = "Master Smith"
NPC.Shop = "shop_craftsupplies"
NPC.Voice = "dwarf"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("dunmarrow_levyman", "Dunmarrow Levyman", "npc_citizen", "human", 400, Mercs .. "englishconscript.mdl")
NPC = AddMultiplier(NPC, 25, 3)
NPC.Weapon = "npc_short_sword_shield"
NPC.KeyValues = CitizenKeyValues
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_recruit", "Morvaine Levy Recruit", 400, RedSideSet("recruerouge", 6), {"weapon_melee_rustysword"})
NPC = AddDrop(NPC, "money", 40, 3, 8)
NPC = AddDrop(NPC, "dm_morvaine_rations", 55)
NPC = AddDrop(NPC, "item_orange", 10)
NPC = AddDrop(NPC, "weapon_melee_rustysword", 3)
NPC = AddMultiplier(NPC, 12, 1)
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_warden", "Morvaine Warden", 600, RedSide .. "harmesrouge00.mdl", {"weapon_melee_spear"})
NPC = AddDrop(NPC, "money", 50, 10, 20)
NPC = AddDrop(NPC, "item_arrows", 20)
NPC = AddDrop(NPC, "dm_morvaine_rations", 30)
NPC = AddDrop(NPC, "trifecta_supplycrate", 40)
NPC = AddDrop(NPC, "weapon_melee_spear", 2)
NPC = AddMultiplier(NPC, 15, 2)
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_soldier", "Morvaine Soldier", 300, RedSideSet("fantassinrouge", 6), {"weapon_melee_sword", "armor_shield_round"})
NPC = AddDrop(NPC, "money", 50, 25, 40)
NPC = AddDrop(NPC, "item_arrows", 20)
NPC = AddDrop(NPC, "trifecta_supplycrate", 40)
NPC = AddDrop(NPC, "weapon_melee_sword", 2)
NPC = AddDrop(NPC, "armor_shield_buckler", 3)
NPC = AddDrop(NPC, "armor_belt_quilted", 3)
NPC = AddDrop(NPC, "armor_helm_paddedcoif", 2)
NPC = AddMultiplier(NPC, 20, 3)
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_captain", "Morvaine Garrison Captain", 300, RedSide .. "officierrouge.mdl", {"weapon_melee_sword"})
NPC = AddDrop(NPC, "money", 100, 80, 120)
NPC = AddDrop(NPC, "weapon_melee_sword", 25)
NPC = AddDrop(NPC, "armor_shield_round", 15)
NPC = AddDrop(NPC, "weapon_melee_waraxe", 10)
NPC = AddMultiplier(NPC, 30, 4)
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_outrider", "Morvaine Outrider", 600, RedSide .. "archerrouge.mdl", {"weapon_melee_handaxe"})
NPC = AddDrop(NPC, "money", 50, 20, 35)
NPC = AddDrop(NPC, "dm_seized_cargo", 45)
NPC = AddDrop(NPC, "trifecta_supplycrate", 30)
NPC = AddDrop(NPC, "weapon_melee_handaxe", 2)
NPC = AddMultiplier(NPC, 18, 3)
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_knight", "Morvaine Knight", 400, RedSide .. "chvrouge.mdl", {"weapon_melee_sword", "armor_shield_round"})
NPC = AddDrop(NPC, "money", 60, 40, 70)
NPC = AddDrop(NPC, "dm_morvaine_banner", 35)
NPC = AddDrop(NPC, "armor_shield_round", 3)
NPC = AddDrop(NPC, "armor_chest_breastplate", 2)
NPC = AddDrop(NPC, "armor_shoulder_pauldrons", 2)
NPC = AddMultiplier(NPC, 30, 4)
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_royalguard", "Hallowgate Guard", 400, RedSide .. "groyalrouge.mdl", {"weapon_melee_spear"})
NPC = AddDrop(NPC, "money", 60, 50, 90)
NPC = AddDrop(NPC, "dm_morvaine_banner", 35)
NPC = AddDrop(NPC, "weapon_melee_boarspear", 3)
NPC = AddDrop(NPC, "armor_helm_greathelm", 2)
NPC = AddMultiplier(NPC, 34, 5)
Register.NPC(NPC)

local NPC = MorvaineMelee("morvaine_marshal", "Lord-Marshal Edric Vane", 400, RedSide .. "generalrouge.mdl", {"weapon_melee_sword", "armor_shield_round"})
NPC.Title = "Marshal of the Crossing"
NPC = AddDrop(NPC, "money", 100, 250, 400)
NPC = AddDrop(NPC, "dm_marshal_seal", 100)
NPC = AddDrop(NPC, "weapon_melee_iron_longsword", 15)
NPC = AddDrop(NPC, "armor_helm_greathelm", 10)
NPC = AddMultiplier(NPC, 70, 7)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_deserter", "Banner Deserter", 500, "merclevy.mdl", "npc_short_sword")
NPC = AddDrop(NPC, "money", 45, 5, 15)
NPC = AddDrop(NPC, "dm_stolen_purse", 45)
NPC = AddDrop(NPC, "item_canspoilingmeat", 10)
NPC = AddMultiplier(NPC, 14, 2)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_brigand", "Forest Brigand", 500, "mercfootman.mdl", "npc_medieval_axe")
NPC = AddDrop(NPC, "money", 50, 10, 20)
NPC = AddDrop(NPC, "dm_stolen_purse", 40)
NPC = AddDrop(NPC, "weapon_melee_handaxe", 2)
NPC = AddMultiplier(NPC, 16, 2)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_jory", "Black Jory", 300, "mercveteran.mdl", "npc_short_sword_shield")
NPC.Title = "Chief of the Deserters"
NPC = AddDrop(NPC, "money", 100, 60, 90)
NPC = AddDrop(NPC, "armor_shield_buckler", 25)
NPC = AddDrop(NPC, "weapon_melee_sword", 20)
NPC = AddMultiplier(NPC, 45, 3)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_sellsword", "Gallows Company Sellsword", 500, "mercarbalest.mdl", "npc_long_sword")
NPC = AddDrop(NPC, "money", 50, 20, 40)
NPC = AddDrop(NPC, "dm_ashbeads", 40)
NPC = AddDrop(NPC, "dm_company_toll", 35)
NPC = AddDrop(NPC, "weapon_melee_waraxe", 2)
NPC = AddMultiplier(NPC, 22, 3)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_wat", "Wat the Weasel", 300, "merclevy.mdl", "npc_short_sword")
NPC.Title = "Informer"
NPC = AddDrop(NPC, "money", 100, 80, 120)
NPC = AddMultiplier(NPC, 35, 3)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_veteran", "Gallows Company Veteran", 400, "mercveteran.mdl", "npc_long_sword_shield")
NPC = AddDrop(NPC, "money", 55, 30, 60)
NPC = AddDrop(NPC, "dm_company_toll", 35)
NPC = AddDrop(NPC, "dm_ashbeads", 30)
NPC = AddDrop(NPC, "weapon_melee_shortsword", 2)
NPC = AddDrop(NPC, "armor_shield_round", 2)
NPC = AddMultiplier(NPC, 28, 4)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_footknight", "Gallows Company Knight", 400, "mercfootknight.mdl", "npc_long_sword_shield")
NPC = AddDrop(NPC, "money", 60, 50, 90)
NPC = AddDrop(NPC, "weapon_melee_shortsword", 3)
NPC = AddDrop(NPC, "armor_shield_round", 3)
NPC = AddMultiplier(NPC, 34, 5)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_hedgeknight", "Hedge Knight", 400, "hedgeknight.mdl", "npc_silver_sword")
NPC = AddDrop(NPC, "money", 60, 50, 90)
NPC = AddDrop(NPC, "weapon_melee_iron_longsword", 2)
NPC = AddMultiplier(NPC, 34, 5)
Register.NPC(NPC)

local NPC = GallowsMelee("bandit_raubritter", "Sir Gaspard Thorne", 400, "raubritter.mdl", "npc_silver_sword_shield")
NPC.Title = "The Robber Knight"
NPC.EliteLoot = {Epic = {"unique_thornes_oath"}}
NPC = AddDrop(NPC, "money", 100, 300, 500)
NPC = AddDrop(NPC, "weapon_melee_longsword", 12)
NPC = AddDrop(NPC, "armor_helm_greathelm", 10)
NPC = AddMultiplier(NPC, 75, 7)
Register.NPC(NPC)
