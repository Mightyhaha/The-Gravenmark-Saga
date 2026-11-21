local function Roamer(Name, PrintName, Title, Model, HeldItems, Health, Damage)
	local NPC = {}
	NPC.Name = Name
	NPC.PrintName = PrintName
	NPC.Title = Title
	NPC.SpawnName = "npc_citizen"
	NPC.Race = "undead"
	NPC.DistanceRetreat = 300
	NPC.Model = Model
	NPC.Weapon = "weapon_crowbar"
	NPC.KeyValues = {citizentype = 4}
	NPC.HeldItems = HeldItems
	NPC.Mute = true
	NPC.DeathDistance = 14
	NPC.Boss = true
	NPC.HealthPerLevel = Health
	NPC.DamagePerLevel = Damage
	NPC.EliteLoot = {Rolls = 2}
	NPC.Drops = {money = {Chance = 100, Min = 800, Max = 1600}}
	return NPC
end

local NPC = Roamer("roamer_gravewight", "The Gravewight", "Walker of the Night Roads", "models/Humans/Group03/male_07.mdl", {"weapon_melee_iron_longsword"}, 95, 6)
NPC.SkinModel = "models/player/skeleton.mdl"
NPC.DeathSound = {"physics/wood/wood_crate_break3.wav"}
NPC.RoamerLine = "A cold wind rises. The Gravewight walks tonight"
NPC.RoamerSound = "ambient/wind/wind_hit2.wav"
NPC.Summon = {NPC = {"undead_risen"}, Max = 3, PerCast = 1, Interval = 18, LevelOffset = -8}
NPC.Abilities = {
	{Type = "slam", Interval = 12, Radius = 200, Range = 220, Windup = 1.3, Damage = 1.7, Sound = "npc/zombie/zombie_alert2.wav"},
	{Type = "enrage", Health = 0.3, Damage = 1.5, Line = "The Gravewight howls and the ground shakes!"},
}
Register.NPC(NPC)

local NPC = Roamer("roamer_paleknight", "The Pale Knight", "Who Rides After Midnight", "models/npcs/mercfootknight.mdl", {"weapon_melee_silver_longsword", "armor_shield_guard"}, 90, 7)
NPC.Color = {170, 200, 255, 255}
NPC.RenderAlpha = 150
NPC.DeathSound = {"ambient/levels/citadel/weapon_disintegrate2.wav"}
NPC.RoamerLine = "Hoofbeats in the dark. The Pale Knight rides tonight"
NPC.RoamerSound = "ambient/levels/citadel/strange_talk3.wav"
NPC.Abilities = {
	{Type = "blink", Behind = true, Interval = 10, Range = 700, FirstDelay = 5, Sound = "ambient/wind/wind_snippet2.wav"},
	{Type = "slam", Interval = 14, Radius = 170, Range = 200, Windup = 1.0, Damage = 1.6},
	{Type = "guard", Health = 0.5, Duration = 5, Reduction = 0.8, Line = "The Pale Knight fades half out of the world!"},
	{Type = "enrage", Health = 0.25, Damage = 1.5},
}
Register.NPC(NPC)

local NPC = Roamer("roamer_nightbeast", "The Night Beast", "That Which Hunts the Dark", nil, nil, 110, 12)
NPC.SpawnName = "npc_antlionguard"
NPC.Race = "beast"
NPC.Weapon = nil
NPC.KeyValues = {allowbark = 0, cavernbreed = 0, incavern = 0}
NPC.Mute = false
NPC.DistanceRetreat = 450
NPC.Color = {38, 34, 48, 255}
NPC.DeathSound = {"npc/antlion_guard/antlion_guard_die1.wav", "npc/antlion_guard/antlion_guard_die2.wav"}
NPC.RoamerLine = "Something huge crashes through the trees. The Night Beast hunts tonight"
NPC.RoamerSound = "npc/antlion_guard/angry1.wav"
NPC.Abilities = {
	{Type = "slam", Interval = 13, Radius = 230, Range = 260, Windup = 1.4, Damage = 2.2, Sound = "npc/antlion_guard/angry2.wav"},
	{Type = "enrage", Health = 0.3, Damage = 1.6, Sound = "npc/antlion_guard/angry3.wav", Line = "The Night Beast roars and tears at the ground!"},
}
Register.NPC(NPC)
