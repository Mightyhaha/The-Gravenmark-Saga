
local Crimson = Color(175, 25, 35, 255)
local DarkBlood = Color(120, 50, 55, 255)

local SetName = "set_regalia_rebellion"
local FirstStage = "legendary_rebellion_1"

local function Look(strItem, clrTint)
	local tblItem = GM.DataBase.Items[strItem]
	local tblModel = table.Copy(tblItem.Model)
	if clrTint and tblModel[1] then tblModel[1].Color = clrTint end
	return tblModel
end

RegisterBuff({
	Name = "buff_rally",
	PrintName = "Rally",
	Icon = "icon16/flag_red.png",
	Category = "combat",
	Duration = 10,
	Desc = function(Power) return math.Round(Power * 3) .. "% more damage" end,
	Hooks = {
		damage_mod = function(ply, Power, Damage)
			return Damage * (1 + 0.03 * Power)
		end,
	},
})

local function RallyOnKill(intMaxStacks, boolHealAtFull)
	return function(ply, Rank, entNPC)
		if SERVER and IsValid(ply) and ply:Alive() then
			local intStacks = math.min(ply:GetBuffPower("buff_rally") + 1, intMaxStacks)
			if boolHealAtFull and ply:GetBuffPower("buff_rally") >= intMaxStacks then ply:HealPercent(3) end
			ply:AddBuff("buff_rally", 10, intStacks)
		end
		return entNPC
	end
end

local Stages = {
	{Level = 100, Name = "Start of the Rebellion", Base = "weapon_melee_ebony_longsword", Look = Look("weapon_melee_iron_longsword"),
		Desc = "A plain iron soldier's blade, nicked and worn. It was the first one raised.",
		Lore = "Every rebellion starts with one blade and someone foolish enough to hold it up."},
	{Level = 110, Name = "Voice of the Rebellion", Base = "weapon_melee_ashen_longsword", Look = Look("weapon_melee_steel_longsword"),
		Desc = "Re-edged in good steel. People have started to say its name.",
		Lore = "A blade is only iron until people start to talk about it."},
	{Level = 120, Name = "Banner of the Rebellion", Base = "weapon_melee_gravensteel_longsword", Look = Look("weapon_melee_silver_longsword"),
		Desc = "Silvered and bright enough to rally to.",
		Lore = "They no longer follow the one who carries it. They follow the blade."},
	{Level = 130, Name = "Fire of the Rebellion", Base = "weapon_melee_gravensteel_bastard", Look = Look("weapon_melee_gravensteel_longsword"),
		Desc = "Folded with Gravensteel. It runs hotter than it should.",
		Lore = "What began in Dunmarrow now burns along the whole border.",
		Effects = {{Type = "embers", Color = Color(255, 140, 50), Size = 0.8, Amount = 0.6, Pulse = 1}}},
	{Level = 140, Name = "Fury of the Rebellion", Base = "weapon_melee_daedric_longsword", Look = Look("weapon_melee_ebony_longsword", DarkBlood),
		Desc = "Black ebony, stained dark. It has been used for what it was made for.",
		Lore = "Mercy was asked for, once. No one remembers the answer.",
		Effects = {{Type = "glow", Color = Color(160, 20, 20), Size = 0.8, Amount = 1, Pulse = 0.6}, {Type = "smoke", Color = Color(60, 40, 40), Size = 0.8, Amount = 0.5, Pulse = 1}}},
	{Level = 150, Name = "Rebellion", Base = "weapon_melee_dreadforged_oathblade", Look = Look("weapon_melee_dreadforged_oathblade", Crimson),
		Desc = "The blade the rebellion became. It has no other name, and needs none.",
		Lore = "Kings are made by crowns. This was made by everyone who refused one.", HealAtFull = true,
		Effects = {{Type = "glow", Color = Color(220, 30, 30), Size = 1, Amount = 1, Pulse = 1}, {Type = "embers", Color = Color(255, 90, 40), Size = 1, Amount = 1, Pulse = 1}, {Type = "light", Color = Color(255, 60, 40), Size = 0.8, Amount = 0.7, Pulse = 1}}},
}

for intStage, Stage in ipairs(Stages) do
	local strPower = "Each kill grants a stack of Rally, +3% damage for 10 seconds, up to " .. intStage .. (intStage == 1 and " stack." or " stacks.")
	if Stage.HealAtFull then strPower = strPower .. " Kills at full Rally also restore 3% of your health." end
	GM:MakeLegendaryItem(GM.DataBase.Items[Stage.Base], "legendary_rebellion_" .. intStage, Stage.Name, {
		Model = Stage.Look,
		Effects = Stage.Effects,
		Desc = Stage.Desc,
		Lore = Stage.Lore,
		Stats = {stat_strength = 0.7, stat_maxhealth = 0.3},
		Hooks = {on_kill = RallyOnKill(intStage, Stage.HealAtFull)},
		PowerDesc = strPower,
		Set = SetName,
		BaseItem = intStage > 1 and FirstStage or nil,
	})
end

GM:MakeLegendaryItem(GM.DataBase.Items["ring_strength_6"], "legendary_trifecta_signet", "Signet of the Trifecta", {
	Desc = "Three bands twisted into one. Ulric had it made for the ones who carried the rebellion the furthest.",
	Lore = "Three brothers, three oaths. One of them still keeps his.",
	Stats = {stat_strength = 0.5, stat_maxhealth = 0.5},
	Hooks = {
		max_food_buffs = function(ply, Rank, intMax) return intMax + 1 end,
		buff_duration_mod = function(ply, Rank, flDuration, strBuff, strCategory)
			if strCategory == "food" or strCategory == "rest" then flDuration = flDuration * 1.25 end
			return flDuration, strBuff, strCategory
		end,
	},
	PowerDesc = "You can have one more food effect at once, and food and Rested last 25% longer.",
	Level = 120,
	Set = SetName,
})

GM:MakeLegendaryItem(GM.DataBase.Items["neck_pendant_6"], "legendary_ember_dunmarrow", "Ember of Dunmarrow", {
	Desc = "A coal from the first fire lit in Dunmarrow's defiance, sealed in glass. It has never gone out.",
	Lore = "It burns brightest when everything else is going dark.",
	Stats = {stat_maxhealth = 0.6, stat_strength = 0.4},
	Hooks = {
		damage_taken_mod = function(ply, Rank, Damage, entAttacker)
			if Damage and ply:Health() < ply:GetMaximumHealth() * 0.5 then Damage = Damage * 0.85 end
			return Damage, entAttacker
		end,
	},
	PowerDesc = "Take 15% less damage while below half health.",
	Level = 140,
	Set = SetName,
})

Register.EquipmentSet({
	Name = SetName,
	PrintName = "Regalia of the Rebellion",
	Items = {FirstStage, "legendary_trifecta_signet", "legendary_ember_dunmarrow"},
	Buffs = {
		stat_strength = GM:GetAffixStat("stat_strength", 140, 0.06),
		stat_maxhealth = GM:GetAffixStat("stat_maxhealth", 140, 0.04),
	},
})
