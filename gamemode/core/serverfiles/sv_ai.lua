local LeashInterval = 0.25
local AggroRangeSqr = 200 ^ 2

local function UpdateNPCLeash()
	local Players = player.GetAll()
	for _, npc in ipairs(ents.FindByClass("npc_*")) do
		if not IsValid(npc) or npc.DontReturn or not npc.Position then continue end
		local NPCTable = NPCTable(npc.Name or npc:GetNWString("npc"))
		if not NPCTable or not NPCTable.DistanceRetreat then continue end

		local Leash = NPCTable.DistanceRetreat
		local Home = npc.Position
		if npc.UD_Patrolling then
			if not npc.HasTask and not IsValid(npc:GetEnemy()) then npc.UD_LeashAnchor = npc:GetPos() end
			Home = npc.UD_LeashAnchor or npc.Position
		end
		local DistSqr = npc:GetPos():DistToSqr(Home)

		if DistSqr > Leash ^ 2 and not npc.HasTask then
			npc:ReturnSpawn()
			npc.HasTask = true
			timer.Simple(20, function()
				if IsValid(npc) and npc.HasTask then
					npc:Idle()
					npc.HasTask = false
				end
			end)
		end
		if DistSqr > (Leash * 2) ^ 2 then
			npc:SetPos(Home)
			DistSqr = 0
		end
		if npc.HasTask then
			if DistSqr < (Leash * 0.1) ^ 2 then
				npc:Idle()
				npc.HasTask = false
			end
			if npc:IsBlocked() then
				npc:SetPos(Home)
				npc.HasTask = false
			end
		end
		if npc:IsNPC() and not npc:GetEnemy() then
			local NPCPos = npc:GetPos()
			local Nearest, NearestDistSqr = nil, AggroRangeSqr
			for _, ply in ipairs(Players) do
				local PlyDistSqr = ply:GetPos():DistToSqr(NPCPos)
				if PlyDistSqr < NearestDistSqr and ply:Alive() and npc:Disposition(ply) == GAMEMODE.RelationHate then
					Nearest, NearestDistSqr = ply, PlyDistSqr
				end
			end
			if Nearest then npc:AttackEnemy(Nearest) end
		end
	end
end
timer.Create("UD_NPCLeash", LeashInterval, 0, UpdateNPCLeash)

local function SpawnLoot(Target, Killer, Item, Amount)
	local Loot = CreateWorldItem(Item, Amount, Target:GetPos() + Vector(0, 0, 30))
	if not IsValid(Loot) then return end
	Loot:SetOwner(Killer)
	local LootPhys = Loot:GetPhysicsObject()
	if not IsValid(LootPhys) and IsValid(Loot.Grip) then LootPhys = Loot.Grip:GetPhysicsObject() end
	if not IsValid(LootPhys) then return end
	LootPhys:Wake()
	LootPhys:ApplyForceCenter(Vector(math.random(-100, 100), math.random(-100, 100), math.random(350, 400)))
end

function GM:OnNPCKilled(Target, Killer, weapon)
	if Target:GetClass() == "npc_zombie" then GAMEMODE:RemoveAll("npc_headcrab") end
	if not Killer:IsPlayer() and Target.LastPlayerAttacker then Killer = Target.LastPlayerAttacker end
	if Killer.EntityDamageData then
		if Killer.EntityDamageData[Target] then
			for _, ply in pairs(player.GetAll()) do
				if ply.EntityDamageData then
					if ply.EntityDamageData[Target] then
						if ply.EntityDamageData[Target] > Killer.EntityDamageData[Target] then
							Killer = ply
						end
					end
				end
			end
		end
	end
	for _, ply in pairs(player.GetAll()) do
		if ply.EntityDamageData then
			if ply.EntityDamageData[Target] then
				ply.EntityDamageData[Target] = nil
			end
		end
	end
	if Target:GetNWInt("level") > 0 and Killer and Killer:IsValid() and Killer:IsPlayer() then
		local NPCTable = NPCTable(Target:GetNWString("npc"))
		local flExpShare = Target.UD_Summoned and GAMEMODE.SummonExpShare or 1
		if #(Killer.Squad or {}) > 1 then
			local TotalExp = math.Round(GAMEMODE:GetKillExp(Target, Killer:GetAverageSquadLevel()) * flExpShare * 6 / (#(Killer.Squad or {}) + 7))
			local PerPlayer = math.Round(TotalExp / #Killer.Squad)
			for _, ply in pairs(Killer.Squad) do
				if IsValid(ply) then
					ply:GiveExp(PerPlayer, true)
				end
			end
		else
			Killer:GiveExp(math.max(math.Round(GAMEMODE:GetKillExp(Target, Killer:GetLevel()) * flExpShare), 1), true)
		end
		if Target.UD_Summoned then return end
		for Item, Info in pairs(NPCTable.Drops or {}) do
			local ItemTable = ItemTable(Item)
			--Check Level of player and of npc
			if Target:GetLevel() >= (Info.MinLevel or 0) and Target:GetLevel() <= (Info.MaxLevel or math.huge) then
				if not ItemTable.QuestItem or (Killer:GetQuest(ItemTable.QuestItem) and not Killer:HasCompletedQuest(ItemTable.QuestItem)) then
					Item, Info = Killer:CallSkillHook("drop_mod", Item, Info)
					local Chance = (Info.Chance or 0) * (1 + (Killer:GetStat("stat_luck") / 45))
					local ItemChance = 100 / math.Clamp(Chance, 0, 100)
					if math.random(1, (ItemChance or 100)) == 1 then
						SpawnLoot(Target, Killer, Item, math.random(Info.Min or 1, Info.Max or Info.Min or 1))
					end
				end
			end
		end
		local strRecipe = GAMEMODE:RollRecipeDrop(Target, Killer, NPCTable)
		if strRecipe then
			SpawnLoot(Target, Killer, strRecipe, 1)
			Killer:ChatPrint("A recipe fell from " .. (NPCTable.PrintName or "your enemy") .. ": " .. (ItemTable(strRecipe).PrintName or strRecipe))
		end
		if NPCTable.EliteLoot then
			for _ = 1, NPCTable.EliteLoot.Rolls or 1 do
				local strLoot = GAMEMODE:RollEliteLoot(Target:GetLevel(), NPCTable.EliteLoot)
				if strLoot then
					SpawnLoot(Target, Killer, strLoot, 1)
					GAMEMODE:AnnounceLoot(Target, strLoot)
				end
			end
		end
	end
end

local function NPCAdjustDamage(Victim, DamageInfo)
	local Attacker = DamageInfo:GetAttacker()
	if not IsValid(Victim) or not IsValid(Attacker) or not NPCTable(Victim:GetNWString("npc")) then return end
	if Attacker.OverrideDamge then DamageInfo:SetDamage(Attacker.OverrideDamge) end
	if not Attacker:IsPlayer() and Attacker:GetOwner():IsPlayer() then
		Attacker = Attacker:GetOwner()
	end
	local NPCTable = NPCTable(Victim:GetNWString("npc"))
	local Invincible = NPCTable.Invincible or Attacker.Race == NPCTable.Race
	if Attacker:IsPlayer() and not Invincible then
		local DisplayColor = "white"
		DamageInfo:SetDamage(DamageInfo:GetDamage() * GAMEMODE:GetOutgoingDamageScale(Victim:GetNWInt("level"), Attacker:GetLevel()))
		if math.random() < GAMEMODE:GetCritChance(Attacker, ItemTable(Attacker:GetSlot("slot_primaryweapon"))) then
			DamageInfo:SetDamage(math.Round(DamageInfo:GetDamage() * 2))
			Attacker:CreateIndicator("Crit!", DamageInfo:GetDamagePosition(), "blue", true)
			DisplayColor = "blue"
		end
		if Victim:IsNPC() then
			if not Victim:GetEnemy() then
				Victim:AttackEnemy(Attacker)
			end
			Victim:AddEntityRelationship(Attacker, GAMEMODE.RelationHate, 99)
		end
		if Victim:Health() < 2 and Victim:IsBuilding() then
			Attacker:AddQuestKill(Victim:GetNWString("npc"))
		end
		DamageInfo:SetDamage(math.Round(DamageInfo:GetDamage() + math.random(-1, math.Round(1 * (1 + (Attacker:GetStat("stat_luck") / 55))))))
		DamageInfo:SetDamage(math.max(math.Round(DamageInfo:GetDamage() * GAMEMODE:GetNPCDamageTakenMod(Victim)), 0))
		Attacker:CallSkillHook("on_hit", Victim, DamageInfo:GetDamage())
		if not Attacker.EntityDamageData then
			Attacker.EntityDamageData = {}
		end
		Attacker.EntityDamageData[Victim] = (Attacker.EntityDamageData[Victim] or 0) + math.Clamp(DamageInfo:GetDamage(),0,Victim:Health())
		Attacker:CreateIndicator(DamageInfo:GetDamage(), DamageInfo:GetDamagePosition(), DisplayColor, true)
		Victim.FirstPlayerAttacker = Victim.FirstPlayerAttacker or Attacker
		Victim.LastPlayerAttacker = Attacker
		if Victim:Health() <= DamageInfo:GetDamage() then
			if Victim:IsNPC() then
				DamageInfo:SetDamage(Victim:Health() + DamageInfo:GetDamage())
				return
			end
			Victim:Remove()
		end
		Victim:SetHealth(Victim:Health() - DamageInfo:GetDamage())
		Victim:SetNWInt("Health", Victim:Health())
		DamageInfo:SetDamage(0)
	end
	if Invincible then DamageInfo:SetDamage(0) end
end
hook.Add("EntityTakeDamage", "UD_NPCAdjustDamage", NPCAdjustDamage)

function GM:ScaleNPCDamage(Victim, strHitGroup, DamageInfo)
	DamageInfo:ScaleDamage(1)
	local NPCTable = NPCTable(Victim:GetNWString("npc"))
	if not NPCTable then return end
	if NPCTable.Invincible or DamageInfo:GetAttacker().Race == NPCTable.Race then
		DamageInfo:ScaleDamage(0)
	end
end
