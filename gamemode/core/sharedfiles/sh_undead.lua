if CLIENT then return end

local tblRecentDeaths = {}

GM.SummonExpShare = 0.25

local function RiseEffect(vecPos)
	local Effect = EffectData()
	Effect:SetOrigin(vecPos)
	Effect:SetScale(60)
	Effect:SetMagnitude(60)
	util.Effect("ThumperDust", Effect, true, true)
	sound.Play("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav", vecPos, 75, math.random(80, 95), 1)
end

local function GroundNear(vecOrigin)
	local vecTry = vecOrigin + Angle(0, math.random(0, 359), 0):Forward() * math.random(60, 120)
	local trcDown = util.TraceLine({start = vecTry + Vector(0, 0, 64), endpos = vecTry - Vector(0, 0, 160), mask = MASK_SOLID_BRUSHONLY})
	if not trcDown.Hit or trcDown.StartSolid then return nil end
	return trcDown.HitPos + Vector(0, 0, 4)
end

function GM:SummonForNPC(entNPC, tblSummon)
	entNPC.UD_Summons = entNPC.UD_Summons or {}
	for intIndex = #entNPC.UD_Summons, 1, -1 do
		if not IsValid(entNPC.UD_Summons[intIndex]) then table.remove(entNPC.UD_Summons, intIndex) end
	end
	local entEnemy = entNPC:GetEnemy()
	for _ = 1, tblSummon.PerCast or 1 do
		if #entNPC.UD_Summons >= tblSummon.Max then return end
		local vecPos = GroundNear(entNPC:GetPos())
		if vecPos then
			if tblSummon.Rise ~= false then RiseEffect(vecPos) end
			local intLevel = math.max(entNPC:GetNWInt("level", 1) + (tblSummon.LevelOffset or 0), 1)
			local entRaised = self:CreateNPC(tblSummon.NPC[math.random(#tblSummon.NPC)], {Position = vecPos, Angle = Angle(0, math.random(0, 359), 0), Level = intLevel})
			if IsValid(entRaised) then
				entRaised.UD_Summoned = true
				entRaised.UD_Unbound = tblSummon.Bound == false
				entRaised.UD_SummonMaster = entNPC
				table.insert(entNPC.UD_Summons, entRaised)
				if IsValid(entEnemy) then
					entRaised:SetEnemy(entEnemy)
					entRaised:UpdateEnemyMemory(entEnemy, entEnemy:GetPos())
				end
			end
		end
	end
end

local function StartSummoning(entNPC, tblSummon)
	local strTimer = "UD_Summon_" .. entNPC:EntIndex()
	entNPC.UD_NextSummon = 0
	timer.Create(strTimer, 1, 0, function()
		if not IsValid(entNPC) or entNPC:Health() <= 0 then timer.Remove(strTimer) return end
		if not IsValid(entNPC:GetEnemy()) or CurTime() < entNPC.UD_NextSummon then return end
		entNPC.UD_NextSummon = CurTime() + tblSummon.Interval
		GAMEMODE:SummonForNPC(entNPC, tblSummon)
	end)
end

function GM:ApplyNPCUndead(entNPC, tblNPCTable)
	if not IsValid(entNPC) or not tblNPCTable then return end
	if tblNPCTable.Mute then entNPC.UD_Mute = true end
	if tblNPCTable.NoHeadcrab then
		entNPC.UD_NoHeadcrab = true
		for intGroup = 0, entNPC:GetNumBodyGroups() - 1 do
			if string.find(string.lower(entNPC:GetBodygroupName(intGroup) or ""), "headcrab", 1, true) then
				entNPC:SetBodygroup(intGroup, 0)
			end
		end
	end
	if tblNPCTable.Bodygroups then
		for intGroup, intValue in pairs(tblNPCTable.Bodygroups) do entNPC:SetBodygroup(intGroup, intValue) end
	end
	if tblNPCTable.Summon then StartSummoning(entNPC, tblNPCTable.Summon) end
end

hook.Add("EntityEmitSound", "UD_MuteUndead", function(tblData)
	local ent = tblData.Entity
	if IsValid(ent) and ent.UD_Mute and tblData.Channel == CHAN_VOICE then return false end
end)

hook.Add("OnNPCKilled", "UD_UndeadDeath", function(entNPC)
	if not IsValid(entNPC) then return end
	local tblNPCTable = NPCTable(entNPC:GetNWString("npc", ""))
	if entNPC.UD_NoHeadcrab then
		table.insert(tblRecentDeaths, {Pos = entNPC:GetPos(), Time = CurTime()})
	end
	for _, entRaised in ipairs(entNPC.UD_Summons or {}) do
		if IsValid(entRaised) and not entRaised.UD_Unbound then
			RiseEffect(entRaised:GetPos())
			entRaised:Remove()
		end
	end
	if tblNPCTable and tblNPCTable.DeathSound then
		local tblSounds = istable(tblNPCTable.DeathSound) and tblNPCTable.DeathSound or {tblNPCTable.DeathSound}
		sound.Play(tblSounds[math.random(#tblSounds)], entNPC:GetPos() + Vector(0, 0, 30), 75, math.random(90, 110), 1)
	end
end)

hook.Add("OnEntityCreated", "UD_NoUndeadHeadcrabs", function(ent)
	if not string.StartWith(ent:GetClass(), "npc_headcrab") then return end
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		for intIndex = #tblRecentDeaths, 1, -1 do
			local Death = tblRecentDeaths[intIndex]
			if CurTime() - Death.Time > 2 then
				table.remove(tblRecentDeaths, intIndex)
			elseif ent:GetPos():Distance(Death.Pos) < 160 then
				ent:Remove()
				return
			end
		end
	end)
end)
