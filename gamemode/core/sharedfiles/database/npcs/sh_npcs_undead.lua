local function QuickNPC(Name, PrintName, SpawnName, Distance, Model)
	local NPC = {}
	NPC.Name = Name
	NPC.PrintName = PrintName
	NPC.SpawnName = SpawnName
	NPC.Race = "undead"
	NPC.DistanceRetreat = Distance
	NPC.Model = Model
	NPC.DeathDistance = 14
	return NPC
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

local function AddMaterialDrops(Table, boolCloth)
	local intBands = #GM.CraftBands
	for intBand = 1, intBands do
		local intMin = intBand == 1 and 1 or (intBand - 1) * 20
		local intMax = intBand == intBands and 150 or intBand * 20 - 1
		if boolCloth then AddDrop(Table, GM.CraftMaterials.cloth[intBand], GM.Combat.ClothDropChance, 1, 1, intMin, intMax) end
		AddDrop(Table, GM.CraftMaterials.leather[intBand], GM.Combat.LeatherDropChance, 1, 1, intMin, intMax)
	end
	return Table
end

local BoneSounds = {"physics/wood/wood_box_break1.wav", "physics/wood/wood_box_break2.wav", "physics/wood/wood_crate_break3.wav"}
local SkeletonModel = "models/player/skeleton.mdl"
local SkeletonBase = "models/Humans/Group03/male_07.mdl"
local ZombieTint = {150, 165, 140, 255}
local ZombieModels = {}
for i = 1, 11 do table.insert(ZombieModels, string.format("models/zombie/zclassic_%02dpl.mdl", i)) end

local function Skeleton(Name, PrintName, Distance, HeldItems)
	local NPC = QuickNPC(Name, PrintName, "npc_citizen", Distance, SkeletonBase)
	NPC.Weapon = "weapon_crowbar"
	NPC.KeyValues = {citizentype = 4}
	NPC.SkinModel = SkeletonModel
	NPC.HeldItems = HeldItems
	NPC.Mute = true
	NPC.DeathSound = BoneSounds
	return AddMaterialDrops(NPC, false)
end

local function Zombie(Name, PrintName, SpawnName, Distance)
	local NPC = QuickNPC(Name, PrintName, SpawnName, Distance)
	NPC.NoHeadcrab = true
	NPC.Color = ZombieTint
	return AddMaterialDrops(NPC, true)
end

local NPC = Skeleton("undead_risen", "Risen Bones", 500, {"weapon_melee_rustysword"})
NPC = AddDrop(NPC, "money", 40, 60, 120)
NPC = AddDrop(NPC, "ud_ledger_page", 25)
NPC = AddMultiplier(NPC, 18, 3)
Register.NPC(NPC)

local NPC = Skeleton("undead_barrowguard", "Barrow Guard", 400, {"weapon_melee_sword", "armor_shield_round"})
NPC = AddDrop(NPC, "money", 50, 90, 160)
NPC = AddDrop(NPC, "ud_ledger_page", 25)
NPC = AddMultiplier(NPC, 26, 3)
Register.NPC(NPC)

local NPC = Skeleton("undead_gravespear", "Grave Spearman", 600, {"weapon_melee_spear"})
NPC = AddDrop(NPC, "money", 50, 80, 150)
NPC = AddDrop(NPC, "ud_ledger_page", 25)
NPC = AddMultiplier(NPC, 20, 4)
Register.NPC(NPC)

local NPC = Skeleton("undead_bonelord", "Barrow Lord", 400, {"weapon_melee_iron_longsword", "armor_shield_round"})
NPC.Title = "Keeper of the Barrow"
NPC.Boss = true
NPC.Abilities = {
	{Type = "slam", Interval = 12, Radius = 190, Range = 210, Windup = 1.3, Damage = 1.7, Sound = "npc/zombie/zombie_alert1.wav"},
	{Type = "enrage", Health = 0.35, Damage = 1.4, Sound = "npc/zombie/zombie_pain6.wav", Line = "The Barrow Lord's bones blaze with grave-light!"},
}
NPC.Color = {200, 190, 160, 255}
NPC = AddDrop(NPC, "money", 100, 600, 900)
NPC = AddDrop(NPC, "ud_ledger_page", 100, 2, 2)
NPC = AddMultiplier(NPC, 60, 6)
NPC.EliteLoot = {}
Register.NPC(NPC)

local NPC = Skeleton("undead_necromancer", "The Necromancer", 300, {"unique_gravecaller"})
NPC.SkinModel = "models/mailer/characters/arantir.mdl"
NPC.Title = "Who Wakes the Barrows"
NPC.Boss = true
NPC.Abilities = {
	{Type = "blink", Interval = 9, Range = 200, FirstDelay = 3},
	{Type = "summon", Health = 0.5, NPC = {"undead_barrowguard", "undead_gravespear"}, Count = 3, Max = 7, LevelOffset = -3, Sound = "npc/stalker/go_alert2a.wav", Line = "The Necromancer tears open the graves!"},
	{Type = "enrage", Health = 0.2, Damage = 1.5, Line = "The Necromancer screams. The air goes cold."},
}
NPC.DeathSound = {"npc/stalker/go_alert2a.wav"}
NPC.Summon = {NPC = {"undead_risen", "undead_risen", "undead_gravespear"}, Max = 4, PerCast = 2, Interval = 12, LevelOffset = -3}
NPC = AddDrop(NPC, "money", 100, 1500, 2500)
NPC = AddMultiplier(NPC, 80, 6)
NPC.EliteLoot = {Rolls = 2}
Register.NPC(NPC)

local NPC = Zombie("undead_plaguedead", "Plague Dead", "npc_zombie", 800)
NPC.SkinModel = ZombieModels
NPC.Color = nil
NPC = AddDrop(NPC, "money", 30, 40, 90)
NPC = AddDrop(NPC, "ud_grave_token", 30)
NPC = AddMultiplier(NPC, 28, 4)
Register.NPC(NPC)

local NPC = Zombie("undead_runner", "Barrow Runner", "npc_fastzombie", 900)
NPC.SkinModel = ZombieModels
NPC.Color = nil
NPC = AddDrop(NPC, "money", 30, 40, 90)
NPC = AddDrop(NPC, "ud_grave_token", 30)
NPC = AddMultiplier(NPC, 14, 4)
Register.NPC(NPC)

local NPC = Zombie("undead_bloated", "Bloated Dead", "npc_poisonzombie", 500)
NPC.KeyValues = {crabcount = 0}
NPC = AddDrop(NPC, "money", 60, 120, 220)
NPC = AddDrop(NPC, "ud_grave_token", 50)
NPC = AddMultiplier(NPC, 50, 6)
Register.NPC(NPC)

local NPC = {}
NPC.Name = "quest_edda"
NPC.PrintName = "Mother Edda"
NPC.Title = "Gravewife of Dunmarrow"
NPC.SpawnName = "npc_breen"
NPC.Race = "human"
NPC.Model = "models/Humans/Group01/Female_07.mdl"
NPC.Frozen = false
NPC.Invincible = true
NPC.Idle = true
NPC.DeathDistance = 14
NPC.Quest = {
	"quest_barrow_field",
	"quest_barrow_runners",
	"quest_barrow_tokens",
	"quest_barrow_bloated",
	"quest_barrow_gravehouse",
	"quest_barrow_spears",
	"quest_barrow_lord",
	"quest_barrow_ledger",
	"quest_barrow_necromancer",
}
Register.NPC(NPC)
