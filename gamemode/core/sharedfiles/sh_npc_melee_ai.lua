GM.MeleeAI = {
	Interval = 0.25,
	Reach = 75,
	ReachHeight = 70,
	RepathDistance = 80,
	RepathDelay = 0.5,
	ChaseRange = 2500,
	Classes = {"npc_citizen"},
}

if CLIENT then return end

local function DriveMelee(entNPC, entEnemy, Settings)
	local vecEnemy = entEnemy:GetPos()
	local vecTo = vecEnemy - entNPC:GetPos()
	local flDist = vecTo:Length2D()
	if flDist > Settings.ChaseRange then return end
	entNPC:UpdateEnemyMemory(entEnemy, vecEnemy)

	if flDist <= Settings.Reach and math.abs(vecTo.z) < Settings.ReachHeight then
		entNPC.UD_ChaseTarget = nil
		if entNPC:IsCurrentSchedule(SCHED_MELEE_ATTACK1) then return end
		entNPC:SetSchedule(SCHED_MELEE_ATTACK1)
		return
	end

	if entNPC:IsCurrentSchedule(SCHED_FORCED_GO_RUN) and entNPC.UD_ChaseTarget then
		if CurTime() < (entNPC.UD_NextRepath or 0) then return end
		if entNPC.UD_ChaseTarget:DistToSqr(vecEnemy) < Settings.RepathDistance ^ 2 then return end
	end
	entNPC.UD_ChaseTarget = vecEnemy
	entNPC.UD_NextRepath = CurTime() + Settings.RepathDelay
	entNPC:SetLastPosition(vecEnemy)
	entNPC:SetSchedule(SCHED_FORCED_GO_RUN)
end

timer.Create("UD_MeleeAI", 0.25, 0, function()
	if not GAMEMODE or not GAMEMODE.MeleeAI then return end
	local Settings = GAMEMODE.MeleeAI
	local flNow = CurTime()
	for _, strClass in ipairs(Settings.Classes) do
		for _, entNPC in ipairs(ents.FindByClass(strClass)) do
			if entNPC.Name and not entNPC.Invincible and not entNPC.HasTask and entNPC:Health() > 0 and flNow >= (entNPC.UD_HoldUntil or 0) then
				local entEnemy = entNPC:GetEnemy()
				if IsValid(entEnemy) and entEnemy:Health() > 0 and (not entEnemy:IsPlayer() or entEnemy:Alive()) then
					DriveMelee(entNPC, entEnemy, Settings)
				else
					entNPC.UD_ChaseTarget = nil
				end
			end
		end
	end
end)
