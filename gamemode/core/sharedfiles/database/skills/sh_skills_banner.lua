local Branch = "banner"

local function RallyRange(ply, intRange)
	if ply:GetSkill("skill_ban_threefold") > 0 then return intRange * 2 end
	return intRange
end

local Skill = CreateSkill("skill_ban_resolve", "Rebel's Resolve", Branch, 1, 3, "icon16/flag_blue.png", "Ulric asks for no oath. Only that you keep standing.")
AddSkillStatDesc(Skill, "stat_luck", "Luck", {1, 2, 3})
RegisterSkill(Skill)

local QuickStudy = {3, 6, 9}
local Skill = CreateSkill("skill_ban_quickstudy", "Quick Study", Branch, 2, 3, "icons/item_book1", "Aldric struggled with letters and read every book on war anyway. So can you.", "skill_ban_resolve")
SetSkillDesc(Skill, function(Rank) return "Gain " .. QuickStudy[Rank] .. "% more experience" end)
Skill.Hooks.exp_mod = function(ply, Rank, Amount)
	return Amount * (1 + SkillRankValue(QuickStudy, Rank) / 100)
end
RegisterSkill(Skill)

local Rally = {2, 4, 6}
local Skill = CreateSkill("skill_ban_rallyingcry", "Rallying Cry", Branch, 3, 3, "icon16/bell.png", "For Dunmarrow! For the Threefold Crowns!", "skill_ban_quickstudy")
SetSkillDesc(Skill, function(Rank) return "You and squadmates within 600 units gain +" .. Rally[Rank] .. " Strength and Dexterity" end)
function Skill:Think(ply, Rank)
	if (ply.UD_NextRally or 0) > CurTime() then return end
	ply.UD_NextRally = CurTime() + 3
	local intPower = SkillRankValue(Rally, Rank)
	for _, plyAlly in ipairs(ply:GetSquadInRange(RallyRange(ply, 600))) do
		if plyAlly:GetBuffPower("buff_rallied") <= intPower then plyAlly:AddBuff("buff_rallied", 4, intPower) end
	end
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_ban_fortune", "Fortune's Favor", Branch, 4, 3, "icon16/ruby.png", "The odds have been against the Trifecta for years. Lately they seem to be turning.", "skill_ban_rallyingcry")
AddSkillStatDesc(Skill, "stat_luck", "Luck", {2, 4, 6})
RegisterSkill(Skill)

local Medic = {1, 2, 3}
local Skill = CreateSkill("skill_ban_fieldmedic", "Field Medic", Branch, 5, 3, "icons/item_antivirus", "Clean bandages, boiled water, steady hands.", "skill_ban_fortune")
SetSkillDesc(Skill, function(Rank) return "Every 10 seconds, you and squadmates within 500 units recover " .. Medic[Rank] .. "% of max health" end)
function Skill:Think(ply, Rank)
	if (ply.UD_NextFieldMedic or 0) > CurTime() then return end
	ply.UD_NextFieldMedic = CurTime() + 10
	for _, plyAlly in ipairs(ply:GetSquadInRange(500)) do
		plyAlly:HealPercent(SkillRankValue(Medic, Rank))
	end
end
RegisterSkill(Skill)

local Spoils = {5, 10, 15}
local Skill = CreateSkill("skill_ban_spoils", "Spoils of War", Branch, 6, 3, "icon16/briefcase.png", "Morvaine's supply wagons are well stocked. Were.", "skill_ban_fieldmedic")
SetSkillDesc(Skill, function(Rank) return "All item drops are " .. Spoils[Rank] .. "% more likely" end)
Skill.Hooks.drop_mod = function(ply, Rank, strItem, tblInfo)
	if tblInfo then
		tblInfo = table.Copy(tblInfo)
		tblInfo.Chance = math.min((tblInfo.Chance or 0) * (1 + SkillRankValue(Spoils, Rank) / 100), 100)
	end
	return strItem, tblInfo
end
RegisterSkill(Skill)

local Brothers = {3, 6, 9}
local Skill = CreateSkill("skill_ban_shieldbrothers", "Shield-Brothers", Branch, 7, 3, "icon16/group.png", "Nobody in the squad falls alone.", "skill_ban_spoils")
SetSkillDesc(Skill, function(Rank) return "You and squadmates within 600 units take " .. Brothers[Rank] .. "% less damage" end)
function Skill:Think(ply, Rank)
	if (ply.UD_NextBrothers or 0) > CurTime() then return end
	ply.UD_NextBrothers = CurTime() + 3
	local intPower = SkillRankValue(Brothers, Rank)
	for _, plyAlly in ipairs(ply:GetSquadInRange(RallyRange(ply, 600))) do
		if plyAlly:GetBuffPower("buff_shieldbrothers") <= intPower then plyAlly:AddBuff("buff_shieldbrothers", 4, intPower) end
	end
end
RegisterSkill(Skill)

local Council = {2, 4, 6}
local Skill = CreateSkill("skill_ban_councilvoice", "Voice of the Council", Branch, 8, 3, "icon16/comments.png", "Ulric's Threefold Council needs men who can talk as well as fight.", "skill_ban_shieldbrothers")
SetSkillDesc(Skill, function(Rank) return "Shop prices are " .. Council[Rank] .. "% lower and you gain " .. Council[Rank] .. "% more experience" end)
Skill.Hooks.price_mod = function(ply, Rank, Price)
	return Price * (1 - SkillRankValue(Council, Rank) / 100)
end
Skill.Hooks.exp_mod = function(ply, Rank, Amount)
	return Amount * (1 + SkillRankValue(Council, Rank) / 100)
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_ban_luckofthree", "Luck of the Three Crowns", Branch, 9, 4, "icon16/coins_add.png", "Three brothers, three crowns, one stubborn streak of luck.", "skill_ban_councilvoice")
AddSkillStatDesc(Skill, "stat_luck", "Luck", {3, 6, 9, 12})
RegisterSkill(Skill)

local WarBanner = {5, 10, 15}
local Skill = CreateSkill("skill_ban_warbanner", "War Banner", Branch, 10, 3, "icon16/transmit.png", "Raise the banner over the fallen and let the others see it.", "skill_ban_luckofthree")
SetSkillDesc(Skill, function(Rank) return "Your kills give you and squadmates within 800 units " .. WarBanner[Rank] .. "% more damage for 6 seconds" end)
Skill.Hooks.on_kill = function(ply, Rank, entNPC)
	if SERVER then
		local intPower = SkillRankValue(WarBanner, Rank)
		for _, plyAlly in ipairs(ply:GetSquadInRange(800)) do
			if plyAlly:GetBuffPower("buff_warbanner") <= intPower then plyAlly:AddBuff("buff_warbanner", 6, intPower) end
		end
	end
	return entNPC
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_ban_threefold", "The Threefold Council", Branch, 11, 1, "icons/npc_quest", "Chosen men of Dunmarrow, Kaelmoor and Vestergrim, sitting at one table. You made that possible.", "skill_ban_warbanner")
Skill.Cost = 5
AddSkillStat(Skill, "stat_luck", {5})
SetSkillDesc(Skill, function() return "+5 Luck, 10% more experience, and Rallying Cry and Shield-Brothers reach twice as far" end)
Skill.Hooks.exp_mod = function(ply, Rank, Amount)
	return Amount * 1.1
end
RegisterSkill(Skill)
