local Branch = "bulwark"

local Skill = CreateSkill("skill_bul_thickskin", "Thick Skin", Branch, 1, 5, "icons/item_healthkit", "Bruises heal. Rebels learn to stop counting them.")
AddSkillStatDesc(Skill, "stat_maxhealth", "Max Health", {10, 20, 30, 40, 50})
RegisterSkill(Skill)

local ShieldTraining = {3, 6, 9}
local Skill = CreateSkill("skill_bul_shieldtraining", "Shield Training", Branch, 2, 3, "icons/armor_carbonsheild", "Kaelmoor's shieldwall drills, passed on in secret.", "skill_bul_thickskin")
SetSkillDesc(Skill, function(Rank) return "While holding something in your off hand, take " .. ShieldTraining[Rank] .. "% less damage" end)
Skill.Hooks.damage_taken_mod = function(ply, Rank, Damage, entAttacker)
	if Damage and ply:GetSlot("slot_offhand") then Damage = Damage * (1 - SkillRankValue(ShieldTraining, Rank) / 100) end
	return Damage, entAttacker
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_bul_hardy", "Hardy", Branch, 3, 4, "icon16/heart.png", "Cold nights in the Bremergard woods make for hard men and harder women.", "skill_bul_shieldtraining")
AddSkillStatDesc(Skill, "stat_maxhealth", "Max Health", {15, 30, 45, 60})
RegisterSkill(Skill)

local ArmorDrill = {5, 10, 15}
local Skill = CreateSkill("skill_bul_armordrill", "Armor Drill", Branch, 4, 3, "icon16/shield.png", "Straps tight, plates overlapped, nothing left loose for a blade to find.", "skill_bul_hardy")
SetSkillDesc(Skill, function(Rank) return "Armor from your gear counts " .. ArmorDrill[Rank] .. "% more" end)
Skill.Hooks.armor_mod = function(ply, Rank, Armor)
	return Armor * (1 + SkillRankValue(ArmorDrill, Rank) / 100)
end
RegisterSkill(Skill)

local SecondWind = {2, 3, 4}
local Skill = CreateSkill("skill_bul_secondwind", "Second Wind", Branch, 5, 3, "icon16/heart_add.png", "When the end feels near, something in you refuses.", "skill_bul_armordrill")
SetSkillDesc(Skill, function(Rank) return "Dropping below 30% health restores " .. SecondWind[Rank] .. "% of your max health every second for 6 seconds (once a minute)" end)
Skill.Hooks.damage_taken_mod = function(ply, Rank, Damage, entAttacker)
	if SERVER and Damage and Damage > 0 and Damage < ply:Health() and (ply.UD_SecondWindReady or 0) <= CurTime() then
		if (ply:Health() - Damage) < ply:GetMaximumHealth() * 0.3 then
			ply.UD_SecondWindReady = CurTime() + 60
			ply:AddBuff("buff_secondwind", 6, SkillRankValue(SecondWind, Rank))
		end
	end
	return Damage, entAttacker
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_bul_stalwart", "Stalwart", Branch, 6, 5, "icon16/shield_add.png", "You stand where others break.", "skill_bul_secondwind")
AddSkillStatDesc(Skill, "stat_maxhealth", "Max Health", {25, 50, 75, 100, 125})
RegisterSkill(Skill)

local Unbroken = {4, 7, 10}
local Skill = CreateSkill("skill_bul_unbroken", "Unbroken", Branch, 7, 3, "icon16/brick.png", "Some blows simply do not land.", "skill_bul_stalwart")
SetSkillDesc(Skill, function(Rank) return Unbroken[Rank] .. "% chance to block an enemy hit completely" end)
Skill.Hooks.damage_taken_mod = function(ply, Rank, Damage, entAttacker)
	if SERVER and Damage and Damage > 0 and math.Rand(0, 100) < SkillRankValue(Unbroken, Rank) then
		ply.UD_BlockedHit = true
		Damage = 0
	end
	return Damage, entAttacker
end
RegisterSkill(Skill)

local Constitution = {1, 2, 3}
local Skill = CreateSkill("skill_bul_ironconstitution", "Iron Constitution", Branch, 8, 3, "icon16/pill.png", "A night's sleep would be nice. A minute's rest will do.", "skill_bul_unbroken")
SetSkillDesc(Skill, function(Rank) return "Out of combat, restore " .. Constitution[Rank] .. "% of your max health every 3 seconds" end)
function Skill:Think(ply, Rank)
	if not ply:IsOutOfCombat(8) or ply:Health() >= ply:GetMaximumHealth() then return end
	if (ply.UD_NextConstitution or 0) > CurTime() then return end
	ply.UD_NextConstitution = CurTime() + 3
	ply:HealPercent(SkillRankValue(Constitution, Rank))
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_bul_vanguard", "Vanguard", Branch, 9, 5, "icon16/bricks.png", "First into the breach, last out of it.", "skill_bul_ironconstitution")
AddSkillStatDesc(Skill, "stat_maxhealth", "Max Health", {40, 80, 120, 160, 200})
RegisterSkill(Skill)

local LastStandCooldown = {180, 150, 120}
local Skill = CreateSkill("skill_bul_laststand", "Last Stand", Branch, 10, 3, "icon16/exclamation.png", "Not today.", "skill_bul_vanguard")
SetSkillDesc(Skill, function(Rank) return "A killing blow leaves you at 1 health and halves the damage you take for 5 seconds (every " .. LastStandCooldown[Rank] .. " seconds)" end)
Skill.Hooks.damage_taken_mod = function(ply, Rank, Damage, entAttacker)
	if SERVER and Damage and Damage >= ply:Health() and ply:Health() > 1 and (ply.UD_LastStandReady or 0) <= CurTime() then
		ply.UD_LastStandReady = CurTime() + SkillRankValue(LastStandCooldown, Rank)
		Damage = ply:Health() - 1
		ply:AddBuff("buff_laststand", 5, 1)
		ply:CreateNotification("Last Stand!")
	end
	return Damage, entAttacker
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_bul_gravenmark", "The Gravenmark", Branch, 11, 1, "icon16/building.png", "They built a wall to keep the world out. You have become the wall that keeps them out.", "skill_bul_laststand")
Skill.Cost = 5
AddSkillStat(Skill, "stat_maxhealth", {250})
SetSkillDesc(Skill, function() return "+250 Max Health and 10% less damage taken" end)
Skill.Hooks.damage_taken_mod = function(ply, Rank, Damage, entAttacker)
	if Damage then Damage = Damage * 0.9 end
	return Damage, entAttacker
end
RegisterSkill(Skill)
