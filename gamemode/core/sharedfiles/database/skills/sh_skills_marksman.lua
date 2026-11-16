local Branch = "marksman"

local function IsHostileNPC(ent)
	return IsValid(ent) and ent:IsNPC() and ent.Race ~= "human"
end

local function HealthFraction(ent)
	local intMax = ent:GetMaxHealth()
	if not intMax or intMax <= 0 then return 1 end
	return ent:Health() / intMax
end

local Skill = CreateSkill("skill_mark_steadyaim", "Steady Aim", Branch, 1, 5, "icons/weapon_sniper1", "Breathe out, then loose.")
AddSkillStatDesc(Skill, "stat_dexterity", "Dexterity", {1, 2, 3, 4, 5})
RegisterSkill(Skill)

local QuickDraw = {4, 8, 12}
local Skill = CreateSkill("skill_mark_quickdraw", "Quick Draw", Branch, 2, 3, "icons/weapon_pistol", "The second shot matters as much as the first.", "skill_mark_steadyaim")
SetSkillDesc(Skill, function(Rank) return "Ranged attacks are " .. QuickDraw[Rank] .. "% faster" end)
Skill.Hooks.firerate_mod = function(ply, Rank, FireRate)
	if FireRate and not ply:IsMelee() then FireRate = FireRate * (1 + SkillRankValue(QuickDraw, Rank) / 100) end
	return FireRate
end
RegisterSkill(Skill)

local KeenEye = {3, 6, 9, 12}
local Skill = CreateSkill("skill_mark_keeneye", "Keen Eye", Branch, 3, 4, "icon16/eye.png", "Gaps in armor, seams in mail. You see them all.", "skill_mark_quickdraw")
SetSkillDesc(Skill, function(Rank) return "Ranged attacks deal " .. KeenEye[Rank] .. "% more damage" end)
Skill.Hooks.damage_mod = function(ply, Rank, Damage)
	if not ply:IsMelee() then Damage = Damage * (1 + SkillRankValue(KeenEye, Rank) / 100) end
	return Damage
end
RegisterSkill(Skill)

local PinChance, PinTime = {4, 7, 10}, {1.5, 2, 2.5}
local Skill = CreateSkill("skill_mark_pinningshot", "Pinning Shot", Branch, 4, 3, "icon16/anchor.png", "A shot to the leg ends a charge.", "skill_mark_keeneye")
SetSkillDesc(Skill, function(Rank) return PinChance[Rank] .. "% chance on a ranged hit to slow the enemy for " .. PinTime[Rank] .. " seconds" end)
function Skill:BulletCallBack(ply, Rank, Trace, DamageInfo)
	if not SERVER or ply:IsMelee() or not IsHostileNPC(Trace.Entity) then return end
	if math.Rand(0, 100) < SkillRankValue(PinChance, Rank) then
		Trace.Entity:Stun(SkillRankValue(PinTime, Rank), 0.1)
	end
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_mark_fletcher", "Fletcher's Patience", Branch, 5, 5, "icons/item_wood", "A hunter who makes his own shafts knows exactly how they fly.", "skill_mark_pinningshot")
AddSkillStatDesc(Skill, "stat_dexterity", "Dexterity", {3, 6, 9, 12, 15})
RegisterSkill(Skill)

local Focus = {8, 12, 16}
local Skill = CreateSkill("skill_mark_huntersfocus", "Hunter's Focus", Branch, 6, 3, "icon16/star.png", "The forest goes quiet. Only the next target remains.", "skill_mark_fletcher")
SetSkillDesc(Skill, function(Rank) return "Ranged kills grant Hunter's Focus: " .. Focus[Rank] .. "% more ranged damage for 8 seconds" end)
Skill.Hooks.on_kill = function(ply, Rank, entNPC)
	if SERVER and not ply:IsMelee() then ply:AddBuff("buff_huntersfocus", 8, SkillRankValue(Focus, Rank)) end
	return entNPC
end
RegisterSkill(Skill)

local Shafts = {10, 20, 30}
local Skill = CreateSkill("skill_mark_scavengedshafts", "Scavenged Shafts", Branch, 7, 3, "icons/item_pistolammobox", "Most of what you loose can be loosed again.", "skill_mark_huntersfocus")
SetSkillDesc(Skill, function(Rank) return "Ammunition drops are " .. Shafts[Rank] .. "% more likely" end)
Skill.Hooks.drop_mod = function(ply, Rank, strItem, tblInfo)
	local tblItem = ItemTable(strItem)
	if tblItem and tblItem.AmmoAmount and tblInfo then
		tblInfo = table.Copy(tblInfo)
		tblInfo.Chance = math.min((tblInfo.Chance or 0) * (1 + SkillRankValue(Shafts, Rank) / 100), 100)
	end
	return strItem, tblInfo
end
RegisterSkill(Skill)

local CalledShot = {20, 35, 50}
local Skill = CreateSkill("skill_mark_calledshot", "Called Shot", Branch, 8, 3, "icon16/flag_red.png", "The first arrow should end the fight before it starts.", "skill_mark_scavengedshafts")
SetSkillDesc(Skill, function(Rank) return "Ranged hits on enemies above 75% health deal " .. CalledShot[Rank] .. "% more damage" end)
function Skill:BulletCallBack(ply, Rank, Trace, DamageInfo)
	if not SERVER or ply:IsMelee() or not IsHostileNPC(Trace.Entity) then return end
	if HealthFraction(Trace.Entity) > 0.75 then
		DamageInfo:ScaleDamage(1 + SkillRankValue(CalledShot, Rank) / 100)
	end
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_mark_deadeye", "Deadeye", Branch, 9, 5, "icon16/rosette.png", "Wind, distance, the turn of a head. You account for all of it without thinking.", "skill_mark_calledshot")
AddSkillStatDesc(Skill, "stat_dexterity", "Dexterity", {5, 10, 15, 20, 25})
RegisterSkill(Skill)

local Skirmisher = {20, 35, 50}
local Skill = CreateSkill("skill_mark_skirmisher", "Skirmisher", Branch, 10, 3, "icon16/weather_lightning.png", "Shoot, move, and never be where they expect.", "skill_mark_deadeye")
SetSkillDesc(Skill, function(Rank) return "Ranged kills grant +" .. Skirmisher[Rank] .. " movement speed for 4 seconds" end)
Skill.Hooks.on_kill = function(ply, Rank, entNPC)
	if SERVER and not ply:IsMelee() then ply:AddBuff("buff_skirmisher", 4, SkillRankValue(Skirmisher, Rank)) end
	return entNPC
end
RegisterSkill(Skill)

local Skill = CreateSkill("skill_mark_gravenmarkeye", "Eye of the Gravenmark", Branch, 11, 1, "icon16/award_star_gold_1.png", "From the top of the great wall, the sentries could see a man coming for miles. You see further.", "skill_mark_skirmisher")
Skill.Cost = 5
AddSkillStat(Skill, "stat_dexterity", {20})
SetSkillDesc(Skill, function() return "+20 Dexterity, 10% more ranged damage, and Hunter's Focus lasts twice as long" end)
Skill.Hooks.damage_mod = function(ply, Rank, Damage)
	if not ply:IsMelee() then Damage = Damage * 1.1 end
	return Damage
end
Skill.Hooks.buff_duration_mod = function(ply, Rank, Duration, strBuff, strCategory)
	if strBuff == "buff_huntersfocus" then Duration = Duration * 2 end
	return Duration, strBuff, strCategory
end
RegisterSkill(Skill)
