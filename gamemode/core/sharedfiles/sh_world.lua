GM.NightRoamers = {"roamer_gravewight", "roamer_paleknight", "roamer_nightbeast"}
GM.NightRoamerChance = 0.6

function GM:IsNightRoamer(strNPC)
	if not strNPC or strNPC == "" then return false end
	for _, strName in ipairs(self.NightRoamers) do
		if strName == strNPC then return true end
	end
	return false
end

function GM:SpawnTimeAllows(intWhen)
	if (intWhen or 0) == 1 then return self:IsNight() end
	if intWhen == 2 then return not self:IsNight() end
	return true
end

if CLIENT then return end

local PatrolArrive = 90
local PatrolStuckTime = 8
local PatrolStuckMove = 40

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

local function NextIndex(entNPC, intCount, strMode)
	if intCount <= 1 then return 1 end
	local intIndex = entNPC.UD_PatrolIndex
	if strMode == "pingpong" then
		local intDir = entNPC.UD_PatrolDir or 1
		if intIndex + intDir > intCount or intIndex + intDir < 1 then intDir = -intDir end
		entNPC.UD_PatrolDir = intDir
		return intIndex + intDir
	end
	return intIndex % intCount + 1
end

function GM:PatrolStep(entNPC, Route, boolRun)
	local tblPoints = Route and Route.Points
	if not tblPoints or #tblPoints == 0 then return end
	entNPC.UD_Patrolling = true
	if IsValid(entNPC:GetEnemy()) or entNPC.HasTask then
		entNPC.UD_PatrolIssued = nil
		return
	end
	local flNow = CurTime()
	if flNow < (entNPC.UD_PatrolWaitUntil or 0) then return end
	entNPC.UD_PatrolIndex = entNPC.UD_PatrolIndex or NearestIndex(entNPC:GetPos(), tblPoints)
	if entNPC.UD_PatrolIndex > #tblPoints then entNPC.UD_PatrolIndex = 1 end
	local vecPos = entNPC:GetPos()
	if not entNPC.UD_PatrolLastPos or vecPos:DistToSqr(entNPC.UD_PatrolLastPos) > PatrolStuckMove ^ 2 then
		entNPC.UD_PatrolLastPos = vecPos
		entNPC.UD_PatrolLastMove = flNow
	end
	local vecTarget = tblPoints[entNPC.UD_PatrolIndex] + PatrolOffset(entNPC)
	local boolArrived = vecPos:DistToSqr(vecTarget) < PatrolArrive ^ 2
	local boolStuck = entNPC.UD_PatrolIssued and flNow - (entNPC.UD_PatrolLastMove or flNow) > PatrolStuckTime
	if boolArrived or boolStuck then
		if #tblPoints == 1 then
			if boolArrived then return end
		else
			if boolArrived and (Route.Wait or 0) > 0 and not entNPC.UD_PatrolWaited then
				entNPC.UD_PatrolWaited = true
				entNPC.UD_PatrolWaitUntil = flNow + Route.Wait
				entNPC.UD_PatrolIssued = nil
				return
			end
			entNPC.UD_PatrolWaited = nil
			entNPC.UD_PatrolIndex = NextIndex(entNPC, #tblPoints, Route.Mode)
			vecTarget = tblPoints[entNPC.UD_PatrolIndex] + PatrolOffset(entNPC)
		end
		entNPC.UD_PatrolIssued = nil
		entNPC.UD_PatrolLastMove = flNow
	end
	local intSchedule = (boolRun or Route.Run) and SCHED_FORCED_GO_RUN or SCHED_FORCED_GO
	if entNPC.UD_PatrolIssued and entNPC:IsCurrentSchedule(intSchedule) then return end
	entNPC:SetLastPosition(vecTarget)
	entNPC:SetSchedule(intSchedule)
	entNPC.UD_PatrolIssued = entNPC.UD_PatrolIssued or flNow
end

local FightRange = 1500
GM.OutOfTimeGrace = 20

local function IsFighting(entNPC)
	local entEnemy = entNPC:GetEnemy()
	if not IsValid(entEnemy) or entEnemy:Health() <= 0 then return false end
	if entEnemy:IsPlayer() and not entEnemy:Alive() then return false end
	return entEnemy:GetPos():DistToSqr(entNPC:GetPos()) < FightRange ^ 2
end

local function DespawnQuietly(entNPC)
	for _, entRaised in ipairs(entNPC.UD_Summons or {}) do
		if IsValid(entRaised) and not entRaised.UD_Unbound then entRaised:Remove() end
	end
	local Effect = EffectData()
	Effect:SetOrigin(entNPC:GetPos())
	Effect:SetScale(40)
	Effect:SetMagnitude(40)
	util.Effect("ThumperDust", Effect, true, true)
	entNPC:Remove()
end

local function OutOfTime(entNPC)
	return (entNPC.UD_SpawnWhen or 0) ~= 0 and not GAMEMODE:SpawnTimeAllows(entNPC.UD_SpawnWhen)
end

timer.Create("UD_Patrols", 1.5, 0, function()
	if not GAMEMODE or not GAMEMODE.MapEntities then return end
	local tblRoutes = GAMEMODE.MapEntities.PatrolRoutes
	local flNow = CurTime()
	for _, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
		for _, entNPC in pairs(Spawn.Monsters or {}) do
			if IsValid(entNPC) and entNPC:IsNPC() and entNPC:Health() > 0 then
				entNPC.UD_SpawnWhen = Spawn.When or 0
				if not OutOfTime(entNPC) and (entNPC.UD_Route or 0) > 0 and tblRoutes[entNPC.UD_Route] then
					GAMEMODE:PatrolStep(entNPC, tblRoutes[entNPC.UD_Route], false)
				end
			end
		end
	end
	for _, entNPC in ipairs(ents.FindByClass("npc_*")) do
		if IsValid(entNPC) and entNPC:IsNPC() and entNPC:Health() > 0 and OutOfTime(entNPC) then
			entNPC.UD_OutOfTimeSince = entNPC.UD_OutOfTimeSince or flNow + math.Rand(0, 4)
			if flNow >= entNPC.UD_OutOfTimeSince and (not IsFighting(entNPC) or flNow - entNPC.UD_OutOfTimeSince > GAMEMODE.OutOfTimeGrace) then
				DespawnQuietly(entNPC)
			end
		elseif IsValid(entNPC) then
			entNPC.UD_OutOfTimeSince = nil
		end
	end
	local entRoamer = GAMEMODE.ActiveRoamer
	if IsValid(entRoamer) and entRoamer:Health() > 0 then
		if not GAMEMODE:IsNight() and not entRoamer.UD_DevSummoned and not IsFighting(entRoamer) then
			GAMEMODE:Announce((entRoamer.UD_RoamerName or "The night walker") .. " fades with the dawn.", Color(240, 200, 120))
			DespawnQuietly(entRoamer)
			GAMEMODE.ActiveRoamer = nil
		else
			GAMEMODE:PatrolStep(entRoamer, entRoamer.UD_RoamRoute, false)
		end
	end
end)

function GM:SpawnNightRoamer(intRoute, strNPC, boolDev)
	if IsValid(self.ActiveRoamer) then self.ActiveRoamer:Remove() end
	local tblRoutes = {}
	for intKey, Route in ipairs(self.MapEntities.PatrolRoutes) do
		if (intRoute and intKey == intRoute) or (not intRoute and Route.Roamer) then
			if Route.Points and #Route.Points > 0 then table.insert(tblRoutes, Route) end
		end
	end
	if #tblRoutes == 0 then return false end
	local Route = tblRoutes[math.random(#tblRoutes)]
	if not strNPC and self:IsNightRoamer(Route.Monster) then strNPC = Route.Monster end
	strNPC = strNPC or self.NightRoamers[math.random(#self.NightRoamers)]
	local tblNPC = NPCTable(strNPC)
	if not tblNPC then return false end
	local intStart = 1
	local entRoamer = self:CreateNPC(strNPC, {Position = Route.Points[intStart] + Vector(0, 0, 8), Angle = Angle(0, math.random(0, 359), 0), Level = Route.Level or 30})
	if not IsValid(entRoamer) then return false end
	entRoamer.UD_PatrolIndex = intStart
	entRoamer.UD_Roamer = true
	entRoamer.UD_DevSummoned = boolDev
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
	local intRoute, strNPC = tonumber(args[1]), args[2]
	if not intRoute and args[1] then strNPC = args[1] end
	if strNPC and not NPCTable(strNPC) then
		print("[Gravenmark] No NPC called " .. strNPC .. ". Night monsters: " .. table.concat(GAMEMODE.NightRoamers, ", "))
		return
	end
	local boolOk = GAMEMODE:SpawnNightRoamer(intRoute, strNPC, true)
	if not boolOk then
		print("[Gravenmark] No night monster spawned. Tick \"A night monster may roam this route\" on a patrol route (UD_Dev_EditMap), or pass a route number: UD_Dev_SummonRoamer <route> [npc].")
		return
	end
	local entRoamer = GAMEMODE.ActiveRoamer
	if IsValid(entRoamer) then print("[Gravenmark] Spawned " .. (entRoamer.UD_RoamerName or "?") .. " at " .. tostring(entRoamer:GetPos()) .. ". It stays until killed or replaced, even by day.") end
end)

concommand.Add("UD_Dev_NightCheck", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end
	local function Say(strText)
		if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, strText) else print(strText) end
	end
	Say("[Gravenmark] Time " .. GAMEMODE:FormatTimeOfDay() .. ", " .. (GAMEMODE:IsNight() and "night" or "day") .. ", night factor " .. math.Round(GAMEMODE:GetNightFactor(), 2))
	local intShown = 0
	for _, entNPC in ipairs(ents.FindByClass("npc_*")) do
		if (entNPC.UD_SpawnWhen or 0) ~= 0 then
			intShown = intShown + 1
			local entEnemy = entNPC:GetEnemy()
			local strEnemy = IsValid(entEnemy) and ((entEnemy:IsPlayer() and entEnemy:Nick() or entEnemy:GetClass()) .. " at " .. math.Round(entEnemy:GetPos():Distance(entNPC:GetPos()))) or "none"
			local strLeft = entNPC.UD_OutOfTimeSince and math.Round(entNPC.UD_OutOfTimeSince + GAMEMODE.OutOfTimeGrace - CurTime()) .. "s" or "-"
			Say(string.format("  %s #%d  when %d  allowed %s  fighting %s  enemy %s  forced out in %s", entNPC:GetNWString("npc", entNPC:GetClass()), entNPC:EntIndex(), entNPC.UD_SpawnWhen, tostring(GAMEMODE:SpawnTimeAllows(entNPC.UD_SpawnWhen)), tostring(IsFighting(entNPC)), strEnemy, strLeft))
		end
	end
	Say("[Gravenmark] " .. intShown .. " NPCs with a day or night spawn time.")
end)
