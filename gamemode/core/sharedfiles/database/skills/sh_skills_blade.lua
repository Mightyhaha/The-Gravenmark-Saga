local Branch = "blade"

local function IsHostileNPC(ent)
	return IsValid(ent) and ent:IsNPC() and ent.Race ~= "human"
end

local function HealthFraction(ent)
	local intMax = ent:GetMaxHealth()
	if not intMax or intMax <= 0 then return 1 end
	return ent:Health() / intMax
end

local Values = {1, 2, 3, 4, 5}
local Skill = CreateSkill("skill_blade_discipline", "Steel Discipline", Branch, 1, 5, "icons/weapon_cleaver", "Every rebel of Dunmarrow starts the same way: a blade, a post, and a thousand cuts.")
AddSkillStatDesc(Skill, "stat_strength", "Strength", Values)
RegisterSkill(Skill)

local Skill = CreateSkill("skill_blade_footwork", "Footwork", Branch, 2, 3, "icons/junk_shoe", "Aldric's first lesson to Corvin: the feet win the fight before the blade does.", "skill_blade_discipline")
AddSkillStatDesc(Skill, "stat_agility", "Agility", {1, 2, 3})
RegisterSkill(Skill)

local HeavyHand = {3, 6, 9, 12}
local Skill = CreateSkill("skill_blade_heavyhand", "Heavy Hand", Branch, 3, 4, "icons/weapon_pipe", "Put your shoulder behind every cut.", "skill_blade_footwork")
SetSkillDesc(Skill, function(Rank) return "Melee attacks deal " .. HeavyHand[Rank] .. "% more damage" end)
Skill.Hooks.damage_mod = function(ply, Rank, Damage)
	if ply:IsMelee() then Damage = Damage * (1 + SkillRankValue(HeavyHand, Rank) / 100) end
	return Damage
end
RegisterSkill(Skill)

local FeintChance, FeintTime = {4, 7, 10}, {1.5, 2, 2.5}
local Skill = CreateSkill("skill_blade_feint", "Feint", Branch, 4, 3, "icon16/lightning.png", "Show them the high line, take the low one.", "skill_blade_heavyhand")
SetSkillDesc(Skill, function(Rank) return FeintChance[Rank] .. "% chance on a melee hit to stagger the enemy for " .. FeintTime[Rank] .. " seconds" end)
function Skill:BulletCallBack(ply, Rank, Trace, DamageInfo)
	if not SERVER or not ply:IsMelee() or not IsHostileNPC(Trace.Entity) then return end
	if math.Rand(0, 100) < SkillRankValue(FeintChance, Rank) then
		Trace.Entity:Stun(SkillRankValue(FeintTime, Rank), 0.1)
	end
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_blade_irongrip", "Iron Grip", Branch, 5, 5, "icons/tool_wrench", "Years of drills harden the hands until the hilt feels like part of the arm.", "skill_blade_feint")
AddSkillStatDesc(Skill, "stat_strength", "Strength", {3, 6, 9, 12, 15})
RegisterSkill(Skill)

local Bloodrush = {8, 12, 16}
local Skill = CreateSkill("skill_blade_bloodrush", "Bloodrush", Branch, 6, 3, "icon16/fire.png", "One falls, and the next one looks a lot easier.", "skill_blade_irongrip")
SetSkillDesc(Skill, function(Rank) return "Melee kills grant Bloodrush: " .. Bloodrush[Rank] .. "% more melee damage for 8 seconds" end)
Skill.Hooks.on_kill = function(ply, Rank, entNPC)
	if SERVER and ply:IsMelee() then ply:AddBuff("buff_bloodrush", 8, SkillRankValue(Bloodrush, Rank)) end
	return entNPC
end
RegisterSkill(Skill)

local SwitchHands = {5, 10, 15}
local Skill = CreateSkill("skill_blade_switchhands", "Switch Hands", Branch, 7, 3, "icon16/contrast.png", "Corvin learned to change hands mid-fight. Opponents never saw the second blow coming.", "skill_blade_bloodrush")
SetSkillDesc(Skill, function(Rank) return "Melee attacks are " .. SwitchHands[Rank] .. "% faster" end)
Skill.Hooks.firerate_mod = function(ply, Rank, FireRate)
	if FireRate and ply:IsMelee() then FireRate = FireRate * (1 + SkillRankValue(SwitchHands, Rank) / 100) end
	return FireRate
end
RegisterSkill(Skill)

local Executioner = {20, 35, 50}
local Skill = CreateSkill("skill_blade_executioner", "Executioner", Branch, 8, 3, "icons/weapon_axe", "Finish what you start.", "skill_blade_switchhands")
SetSkillDesc(Skill, function(Rank) return "Melee hits on enemies below 30% health deal " .. Executioner[Rank] .. "% more damage" end)
function Skill:BulletCallBack(ply, Rank, Trace, DamageInfo)
	if not SERVER or not ply:IsMelee() or not IsHostileNPC(Trace.Entity) then return end
	if HealthFraction(Trace.Entity) < 0.3 then
		DamageInfo:ScaleDamage(1 + SkillRankValue(Executioner, Rank) / 100)
	end
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_blade_weaponmaster", "Weapon Master", Branch, 9, 5, "icon16/medal_gold_1.png", "Sword, axe or hammer, it is all the same to you now.", "skill_blade_executioner")
AddSkillStatDesc(Skill, "stat_strength", "Strength", {5, 10, 15, 20, 25})
RegisterSkill(Skill)

local Riposte = {40, 70, 100}
local Skill = CreateSkill("skill_blade_riposte", "Riposte", Branch, 10, 3, "icon16/cut.png", "Their blow opens their guard. Make them pay for it.", "skill_blade_weaponmaster")
SetSkillDesc(Skill, function(Rank) return "After an enemy hits you, your next melee hit within 3 seconds deals " .. Riposte[Rank] .. "% more damage" end)
Skill.Hooks.damage_taken_mod = function(ply, Rank, Damage, entAttacker)
	if SERVER and Damage and Damage > 0 and IsValid(entAttacker) and entAttacker:IsNPC() then
		ply:AddBuff("buff_riposte", 3, SkillRankValue(Riposte, Rank))
	end
	return Damage, entAttacker
end
function Skill:BulletCallBack(ply, Rank, Trace, DamageInfo)
	if not SERVER or not ply:IsMelee() or not IsHostileNPC(Trace.Entity) or not ply:HasBuff("buff_riposte") then return end
	DamageInfo:ScaleDamage(1 + ply:GetBuffPower("buff_riposte") / 100)
	ply:RemoveBuff("buff_riposte")
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_blade_undefeated", "The Undefeated", Branch, 11, 1, "icon16/award_star_gold_1.png", "Corvin has never lost a duel. Neither, now, have you.", "skill_blade_riposte")
Skill.Cost = 5
AddSkillStat(Skill, "stat_strength", {20})
SetSkillDesc(Skill, function() return "+20 Strength, 10% more melee damage, and Bloodrush lasts twice as long" end)
Skill.Hooks.damage_mod = function(ply, Rank, Damage)
	if ply:IsMelee() then Damage = Damage * 1.1 end
	return Damage
end
Skill.Hooks.buff_duration_mod = function(ply, Rank, Duration, strBuff, strCategory)
	if strBuff == "buff_bloodrush" then Duration = Duration * 2 end
	return Duration, strBuff, strCategory
end
RegisterSkill(Skill)
