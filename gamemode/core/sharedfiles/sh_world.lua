GM.NightRoamers = {"roamer_gravewight", "roamer_paleknight"}
GM.NightRoamerChance = 0.6

function GM:SpawnTimeAllows(intWhen)
	if (intWhen or 0) == 1 then return self:IsNight() end
	if intWhen == 2 then return not self:IsNight() end
	return true
end

if CLIENT then return end

local PatrolArrive = 90
local PatrolRetry = 20

local function NearestIndex(vecPos, tblPoints)
	local intBest, flBest = 1, math.huge
	for intIndex, vecPoint in ipairs(tblPoints) do
		local flDist = vecPos:DistToSqr(vecPoint)
		if flDist < flBest then intBest, flBest = intIndex, flDist end
	end
	return intBest
end

local function PatrolOffset(entNPC)
	local flTheta = entNPC:EntIndex() * 2.4
	return Vector(math.cos(flTheta) * 40, math.sin(flTheta) * 40, 0)
end

function GM:PatrolStep(entNPC, Route, boolRun)
	local tblPoints = Route and Route.Points
	if not tblPoints or #tblPoints == 0 then return end
	if IsValid(entNPC:GetEnemy()) then
		entNPC.UD_PatrolIssued = nil
		return
	end
	entNPC.UD_PatrolIndex = entNPC.UD_PatrolIndex or NearestIndex(entNPC:GetPos(), tblPoints)
	if entNPC.UD_PatrolIndex > #tblPoints then entNPC.UD_PatrolIndex = 1 end
	local vecTarget = tblPoints[entNPC.UD_PatrolIndex] + PatrolOffset(entNPC)
	local boolArrived = entNPC:GetPos():DistToSqr(vecTarget) < PatrolArrive ^ 2
	local boolStuck = entNPC.UD_PatrolIssued and CurTime() - entNPC.UD_PatrolIssued > PatrolRetry
	if boolArrived or boolStuck then
		if #tblPoints == 1 then
			if boolArrived then return end
		else
			entNPC.UD_PatrolIndex = entNPC.UD_PatrolIndex % #tblPoints + 1
			vecTarget = tblPoints[entNPC.UD_PatrolIndex] + PatrolOffset(entNPC)
		end
		entNPC.UD_PatrolIssued = nil
	end
	local intSchedule = boolRun and SCHED_FORCED_GO_RUN or SCHED_FORCED_GO
	if entNPC.UD_PatrolIssued and entNPC:IsCurrentSchedule(intSchedule) then return end
	entNPC:SetLastPosition(vecTarget)
	entNPC:SetSchedule(intSchedule)
	entNPC.UD_PatrolIssued = entNPC.UD_PatrolIssued or CurTime()
end

local function DespawnQuietly(entNPC)
	local Effect = EffectData()
	Effect:SetOrigin(entNPC:GetPos())
	Effect:SetScale(40)
	Effect:SetMagnitude(40)
	util.Effect("ThumperDust", Effect, true, true)
	entNPC:Remove()
end

timer.Create("UD_Patrols", 1.5, 0, function()
	if not GAMEMODE or not GAMEMODE.MapEntities then return end
	local tblRoutes = GAMEMODE.MapEntities.PatrolRoutes
	for _, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
		for _, entNPC in pairs(Spawn.Monsters or {}) do
			if IsValid(entNPC) and entNPC:IsNPC() and entNPC:Health() > 0 then
				if not GAMEMODE:SpawnTimeAllows(entNPC.UD_SpawnWhen) and not IsValid(entNPC:GetEnemy()) then
					DespawnQuietly(entNPC)
				elseif (entNPC.UD_Route or 0) > 0 and tblRoutes[entNPC.UD_Route] then
					GAMEMODE:PatrolStep(entNPC, tblRoutes[entNPC.UD_Route], false)
				end
			end
		end
	end
	local entRoamer = GAMEMODE.ActiveRoamer
	if IsValid(entRoamer) and entRoamer:Health() > 0 then
		if not GAMEMODE:IsNight() and not IsValid(entRoamer:GetEnemy()) then
			GAMEMODE:Announce((entRoamer.UD_RoamerName or "The night walker") .. " fades with the dawn.", Color(240, 200, 120))
			DespawnQuietly(entRoamer)
			GAMEMODE.ActiveRoamer = nil
		else
			GAMEMODE:PatrolStep(entRoamer, entRoamer.UD_RoamRoute, false)
		end
	end
end)

function GM:SpawnNightRoamer(intRoute, strNPC)
	if IsValid(self.ActiveRoamer) then self.ActiveRoamer:Remove() end
	local tblRoutes = {}
	for intKey, Route in ipairs(self.MapEntities.PatrolRoutes) do
		if (intRoute and intKey == intRoute) or (not intRoute and Route.Roamer) then
			if Route.Points and #Route.Points > 0 then table.insert(tblRoutes, Route) end
		end
	end
	if #tblRoutes == 0 then return false end
	local Route = tblRoutes[math.random(#tblRoutes)]
	strNPC = strNPC or self.NightRoamers[math.random(#self.NightRoamers)]
	local tblNPC = NPCTable(strNPC)
	if not tblNPC then return false end
	local entRoamer = self:CreateNPC(strNPC, {Position = Route.Points[1] + Vector(0, 0, 8), Angle = Angle(0, math.random(0, 359), 0), Level = Route.Level or 30})
	if not IsValid(entRoamer) then return false end
	entRoamer.UD_Roamer = true
	entRoamer.UD_RoamRoute = Route
	entRoamer.UD_RoamerName = tblNPC.PrintName
	if tblNPC.RenderAlpha then
		entRoamer:SetRenderMode(RENDERMODE_TRANSCOLOR)
		local clr = entRoamer:GetColor()
		entRoamer:SetColor(Color(clr.r, clr.g, clr.b, tblNPC.RenderAlpha))
	end
	self.ActiveRoamer = entRoamer
	local strWhere = (Route.Name or "") ~= "" and (" near " .. Route.Name) or ""
	self:Announce((tblNPC.RoamerLine or (tblNPC.PrintName .. " walks tonight")) .. strWhere .. ".", Color(190, 140, 255), tblNPC.RoamerSound or "ambient/creatures/town_child_scream1.wav")
	return true
end

hook.Add("UD_NightChanged", "UD_NightRoamers", function(boolNight)
	if not boolNight or math.random() > GAMEMODE.NightRoamerChance then return end
	timer.Simple(math.random(20, 90), function()
		if GAMEMODE:IsNight() and not IsValid(GAMEMODE.ActiveRoamer) then GAMEMODE:SpawnNightRoamer() end
	end)
end)

hook.Add("OnNPCKilled", "UD_NightRoamerSlain", function(entNPC, entAttacker)
	if not IsValid(entNPC) or not entNPC.UD_Roamer then return end
	local strKiller = IsValid(entAttacker) and entAttacker:IsPlayer() and entAttacker:Nick() or "Someone"
	GAMEMODE:Announce(strKiller .. " has slain " .. (entNPC.UD_RoamerName or "the night walker") .. "!", Color(255, 215, 120), "ambient/levels/citadel/strange_talk5.wav")
	if GAMEMODE.ActiveRoamer == entNPC then GAMEMODE.ActiveRoamer = nil end
end)

concommand.Add("UD_Dev_SummonRoamer", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	local boolOk = GAMEMODE:SpawnNightRoamer(tonumber(args[1]), args[2])
	if not boolOk then print("[Gravenmark] No night monster spawned. Tick \"A night monster may roam this route\" on a patrol route (UD_Dev_EditMap), or pass a route number: UD_Dev_SummonRoamer <route> [npc].") end
end)
