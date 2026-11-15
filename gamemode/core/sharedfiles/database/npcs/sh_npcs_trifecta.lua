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
local function AddDrop(Table, Name, Chance, Min, Max, MinLevel)
	Table.Drops = Table.Drops or {}
	Table.Drops[Name] = {Chance = Chance, Min = Min, Max = Max, MinLevel = MinLevel}
	return Table
end

local NPC = QuickNPC("quest_ulric", "Ulric of Dunmarrow", "npc_eli", "human")
NPC = AddBool(NPC, false, true, true)
NPC.Title = "Lord of Dunmarrow"
NPC.Quest = {"quest_trifecta_banners", "quest_trifecta_quietgift", "quest_trifecta_council"}
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("morvaine_warden", "Morvaine Warden", "npc_metropolice", "combine", 600)
NPC = AddDrop(NPC, "money", 50, 10, 20)
NPC = AddDrop(NPC, "item_smallammo_small", 20)
NPC = AddDrop(NPC, "trifecta_supplycrate", 40)
NPC = AddMultiplier(NPC, 15, 2)
NPC.Weapon = "weapon_stunstick"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("morvaine_soldier", "Morvaine Soldier", "npc_combine_s", "combine", 300, "models/Combine_Soldier.mdl")
NPC = AddDrop(NPC, "money", 50, 25, 40)
NPC = AddDrop(NPC, "item_smallammo_small", 20)
NPC = AddDrop(NPC, "item_rifleammo_small", 10)
NPC = AddDrop(NPC, "trifecta_supplycrate", 40)
NPC = AddMultiplier(NPC, 20, 3)
NPC.Weapon = "weapon_smg1"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("morvaine_captain", "Morvaine Garrison Captain", "npc_combine_s", "combine", 300, "models/combine_super_soldier.mdl")
NPC = AddDrop(NPC, "money", 100, 80, 120)
NPC = AddDrop(NPC, "item_rifleammo_small", 40)
NPC = AddMultiplier(NPC, 30, 4)
NPC.Weapon = "weapon_ar2"
NPC.DeathDistance = 14
Register.NPC(NPC)
