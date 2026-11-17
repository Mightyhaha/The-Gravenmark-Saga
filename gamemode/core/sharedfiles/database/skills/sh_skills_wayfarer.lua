local Branch = "wayfarer"

local Forager = {10, 20, 30, 40, 50}
local Skill = CreateSkill("skill_way_forager", "Forager", Branch, 1, 5, "icons/food_orange", "Berries, roots, a hare in a snare. The forest feeds those who know where to look.")
SetSkillDesc(Skill, function(Rank) return "Food and drink heal " .. Forager[Rank] .. "% more" end)
Skill.Hooks.food_mod = function(ply, Rank, HealthToAdd)
	return HealthToAdd * (1 + SkillRankValue(Forager, Rank) / 100)
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_way_packmule", "Pack Mule", Branch, 2, 3, "icons/junk_box1", "Smugglers from Kaelmoor carry twice their weight across the border. You can manage a little more.", "skill_way_forager")
AddSkillStatDesc(Skill, "stat_maxweight", "Max Weight", {3, 6, 9})
RegisterSkill(Skill)

local Appetite = {15, 30, 45}
local Skill = CreateSkill("skill_way_goodappetite", "Good Appetite", Branch, 3, 3, "icon16/cake.png", "A full belly carries you further.", "skill_way_packmule")
SetSkillDesc(Skill, function(Rank) return "Food effects last " .. Appetite[Rank] .. "% longer" end)
Skill.Hooks.buff_duration_mod = function(ply, Rank, Duration, strBuff, strCategory)
	if strCategory == "food" then Duration = Duration * (1 + SkillRankValue(Appetite, Rank) / 100) end
	return Duration, strBuff, strCategory
end
RegisterSkill(Skill)

local ScavengerDrops = {5, 10}
local Skill = CreateSkill("skill_way_scavenger", "Scavenger", Branch, 4, 2, "icon16/basket.png", "Nothing useful gets left behind.", "skill_way_goodappetite")
SetSkillDesc(Skill, function(Rank) return "+" .. Rank .. " to resources gathered and " .. ScavengerDrops[Rank] .. "% better odds of finding items" end)
Skill.Hooks.resouce_mod = function(ply, Rank, strItem, intMaxAmount)
	return strItem, (intMaxAmount or 0) + Rank
end
Skill.Hooks.drop_mod = function(ply, Rank, strItem, tblInfo)
	if strItem ~= "money" and tblInfo then
		tblInfo = table.Copy(tblInfo)
		tblInfo.Chance = math.min((tblInfo.Chance or 0) * (1 + SkillRankValue(ScavengerDrops, Rank) / 100), 100)
	end
	return strItem, tblInfo
end
RegisterSkill(Skill)

local DeepSleeper = {20, 40, 60}
local Skill = CreateSkill("skill_way_deepsleeper", "Deep Sleeper", Branch, 5, 3, "icon16/house.png", "You can sleep on stones, in rain, beside a dying fire.", "skill_way_scavenger")
SetSkillDesc(Skill, function(Rank) return "Rested lasts " .. DeepSleeper[Rank] .. "% longer" end)
Skill.Hooks.buff_duration_mod = function(ply, Rank, Duration, strBuff, strCategory)
	if strCategory == "rest" then Duration = Duration * (1 + SkillRankValue(DeepSleeper, Rank) / 100) end
	return Duration, strBuff, strCategory
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_way_fleetfooted", "Fleet-Footed", Branch, 6, 3, "icon16/world.png", "Every deer trail from Bremergard to the Dunmarrow hills, learned by heart.", "skill_way_deepsleeper")
AddSkillStatDesc(Skill, "stat_agility", "Agility", {1, 2, 3})
RegisterSkill(Skill)

local Haggle = {3, 6, 9, 12}
local Skill = CreateSkill("skill_way_haggler", "Smuggler's Haggle", Branch, 7, 4, "icons/item_cash", "Every merchant has a price, and it is never the first one.", "skill_way_fleetfooted")
SetSkillDesc(Skill, function(Rank) return "Shop prices are " .. Haggle[Rank] .. "% lower" end)
Skill.Hooks.price_mod = function(ply, Rank, Price)
	return Price * (1 - SkillRankValue(Haggle, Rank) / 100)
end
RegisterSkill(Skill)

local LightFingers = {10, 20, 30}
local Skill = CreateSkill("skill_way_lightfingers", "Light Fingers", Branch, 8, 3, "icon16/coins.png", "The dead do not need their coin. The rebellion does.", "skill_way_haggler")
SetSkillDesc(Skill, function(Rank) return "Enemies drop " .. LightFingers[Rank] .. "% more denars" end)
Skill.Hooks.drop_mod = function(ply, Rank, strItem, tblInfo)
	if strItem == "money" and tblInfo then
		tblInfo = table.Copy(tblInfo)
		local Multiplier = 1 + SkillRankValue(LightFingers, Rank) / 100
		tblInfo.Min = math.Round((tblInfo.Min or 1) * Multiplier)
		tblInfo.Max = math.Round((tblInfo.Max or tblInfo.Min) * Multiplier)
	end
	return strItem, tblInfo
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_way_beastofburden", "Beast of Burden", Branch, 9, 4, "icon16/package.png", "If it can be lifted, it can be carried home.", "skill_way_lightfingers")
AddSkillStatDesc(Skill, "stat_maxweight", "Max Weight", {5, 10, 15, 20})
RegisterSkill(Skill)

local Gatherer = {5, 10, 15}
local Skill = CreateSkill("skill_way_huntergatherer", "Hunter-Gatherer", Branch, 10, 3, "icon16/drink.png", "Soldiers march on their stomachs, and they carry their rations with them.", "skill_way_beastofburden")
SetSkillDesc(Skill, function(Rank) return Gatherer[Rank] .. "% chance to find provisions on enemies you defeat" end)
Skill.Hooks.on_kill = function(ply, Rank, entNPC)
	if SERVER and IsValid(entNPC) and entNPC.Race ~= "human" and math.Rand(0, 100) < SkillRankValue(Gatherer, Rank) then
		local tblDrops = GAMEMODE.ProvisionDrops or {}
		local strItem = tblDrops[math.random(#tblDrops)]
		if strItem and ItemTable(strItem) then
			local entLoot = CreateWorldItem(strItem, 1, entNPC:GetPos() + Vector(0, 0, 30))
			if IsValid(entLoot) then entLoot:SetOwner(ply) end
		end
	end
	return entNPC
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_way_childofbremergard", "Child of Bremergard", Branch, 11, 1, "icon16/flag_green.png", "The forest has fed and sheltered you for so long that it no longer feels like hiding.", "skill_way_huntergatherer")
Skill.Cost = 5
SetSkillDesc(Skill, function() return "Two different food effects can be active at once, and Rested lasts 50% longer" end)
Skill.Hooks.max_food_buffs = function(ply, Rank, intMax)
	return intMax + 1
end
Skill.Hooks.buff_duration_mod = function(ply, Rank, Duration, strBuff, strCategory)
	if strCategory == "rest" then Duration = Duration * 1.5 end
	return Duration, strBuff, strCategory
end
RegisterSkill(Skill)
