GM.MapEntities = {}
GM.MapEntities.NPCSpawnPoints = {}
GM.MapEntities.WorldProps = {}
GM.MapEntities.PlayerSpawns = {}
GM.MapEntities.OreVeins = {}

if SERVER then
	local DefaultPropModel = "models/props_junk/wood_crate001a.mdl"
	local MaxNPCs = 500

	local function EditorPlayer()
		if not game.SinglePlayer() then return end
		local ply = player.GetByID(1)
		if IsValid(ply) then return ply end
	end

	local function SendSpawnPoint(intKey)
		local ply = EditorPlayer()
		local Spawn = GAMEMODE.MapEntities.NPCSpawnPoints[intKey]
		if not ply or not Spawn then return end
		SendNetworkMessage("UD_UpdateSpawnPoint", ply, {intKey, Spawn.Position, Spawn.Angle, Spawn.NPC, Spawn.Level, Spawn.SpawnTime, Spawn.Radius, Spawn.Count})
	end

	local function SendWorldProp(intKey)
		local ply = EditorPlayer()
		local Prop = GAMEMODE.MapEntities.WorldProps[intKey]
		if not ply or not Prop or not Prop.Position then return end
		local EntIndex = IsValid(Prop.Entity) and Prop.Entity:EntIndex() or -1
		SendNetworkMessage("UD_UpdateWorldProp", ply, {intKey, Prop.Model or DefaultPropModel, Prop.Position, Prop.Angle or Angle(0, 0, 0), EntIndex})
	end

	function GM:RemoveSpawnedMonsters(Spawn)
		for _, Monster in pairs(Spawn.Monsters or {}) do
			if IsValid(Monster) then Monster:Remove() end
		end
		Spawn.Monsters = {}
		Spawn.NextSpawns = {}
	end

	function GM:CreateSpawnPoint(vecPosition, angAngle, strNPC, intLevel, intSpawnTime, intRadius, intCount)
		table.insert(GAMEMODE.MapEntities.NPCSpawnPoints, {Monsters = {}, NextSpawns = {}})
		GAMEMODE:UpdateSpawnPoint(#GAMEMODE.MapEntities.NPCSpawnPoints, vecPosition, angAngle, strNPC, intLevel, intSpawnTime, intRadius, intCount)
	end

	function GM:UpdateSpawnPoint(intKey, vecPosition, angAngle, strNPC, intLevel, intSpawnTime, intRadius, intCount)
		local Spawn = GAMEMODE.MapEntities.NPCSpawnPoints[intKey]
		if not Spawn then return end
		local OldNPC, OldPosition, OldLevel, OldRadius, OldCount = Spawn.NPC, Spawn.Position, Spawn.Level, Spawn.Radius, Spawn.Count
		Spawn.Position = vecPosition or Spawn.Position
		Spawn.Angle = angAngle or Spawn.Angle or Angle(0, 0, 0)
		Spawn.NPC = strNPC or Spawn.NPC or "zombie"
		Spawn.Level = intLevel or Spawn.Level or 5
		Spawn.SpawnTime = intSpawnTime or Spawn.SpawnTime or 30
		Spawn.Radius = intRadius or Spawn.Radius or 0
		Spawn.Count = intCount or Spawn.Count or 1
		Spawn.Monsters = Spawn.Monsters or {}
		Spawn.NextSpawns = Spawn.NextSpawns or {}
		local Changed = Spawn.NPC ~= OldNPC or Spawn.Position ~= OldPosition or Spawn.Level ~= OldLevel or Spawn.Radius ~= OldRadius or Spawn.Count ~= OldCount
		if Changed then
			GAMEMODE:RemoveSpawnedMonsters(Spawn)
		else
			for _, Monster in pairs(Spawn.Monsters) do
				if IsValid(Monster) then Monster:SetAngles(Spawn.Angle) end
			end
		end
		SendSpawnPoint(intKey)
	end

	function GM:RemoveSpawnPoint(intKey)
		local Spawn = GAMEMODE.MapEntities.NPCSpawnPoints[intKey]
		if not Spawn then return end
		GAMEMODE:RemoveSpawnedMonsters(Spawn)
		table.remove(GAMEMODE.MapEntities.NPCSpawnPoints, intKey)
		local ply = EditorPlayer()
		if ply then SendNetworkMessage("UD_RemoveSpawnPoint", ply, {intKey}) end
	end

	local function ReindexWorldProps()
		for intKey, Prop in ipairs(GAMEMODE.MapEntities.WorldProps) do
			if IsValid(Prop.Entity) then Prop.Entity.ObjectKey = intKey end
		end
	end

	function GM:CreateWorldProp(strModel, vecPosition, angAngle, entEntity, boolLoad)
		local tblNewObject = {Model = strModel or DefaultPropModel, Position = vecPosition, Angle = angAngle or Angle(0, 0, 0)}
		table.insert(GAMEMODE.MapEntities.WorldProps, tblNewObject)

		tblNewObject.SpawnProp = function()
			local intKey = table.KeyFromValue(GAMEMODE.MapEntities.WorldProps, tblNewObject)
			if not intKey then return end
			local entNewProp = ents.Create(GetPropClass(GAMEMODE:ResolvePropModel(tblNewObject.Model)))
			tblNewObject.Entity = entNewProp
			GAMEMODE:UpdateWorldProp(intKey, tblNewObject.Model, tblNewObject.Position, tblNewObject.Angle, nil, boolLoad)
			entNewProp:SetSkin(math.random(0, entNewProp:SkinCount()))
			entNewProp:Spawn()
		end
		tblNewObject.SpawnProp()

		return tblNewObject.Entity
	end

	function GM:UpdateWorldProp(intKey, strModel, vecPosition, angAngle, entEntity, boolLoad, boolFlush)
		local Prop = GAMEMODE.MapEntities.WorldProps[intKey]
		if not Prop then return end
		if strModel then Prop.Model = strModel end
		if vecPosition then Prop.Position = vecPosition end
		if angAngle then Prop.Angle = angAngle end

		local entProp = Prop.Entity
		if IsValid(entProp) then
			local strPreModel = entProp:GetModel()
			entProp:SetModel(GAMEMODE:ResolvePropModel(Prop.Model or DefaultPropModel))
			entProp:SetPos(Prop.Position or entProp:GetPos())
			entProp:SetAngles(Prop.Angle or entProp:GetAngles())
			if (boolFlush or strPreModel ~= entProp:GetModel()) and not boolLoad then
				entProp:SetPos(GetFlushToGround(entProp))
			end
			entProp:PhysicsInit(SOLID_VPHYSICS)
			entProp:SetMoveType(MOVETYPE_NONE)
			entProp:DrawShadow(false)
			entProp:SetKeyValue("spawnflags", 8)
			entProp.ObjectKey = intKey
			GAMEMODE:ApplyStationBuild(entProp, Prop.Model)
			if not GAMEMODE:GetStationBuild(Prop.Model) then Prop.Model = entProp:GetModel() end
			Prop.Position = entProp:GetPos()
			Prop.Angle = entProp:GetAngles()
		end
		SendWorldProp(intKey)
	end

	function GM:RemoveWorldProp(intKey)
		local Prop = GAMEMODE.MapEntities.WorldProps[intKey]
		if not Prop then return end
		if IsValid(Prop.Entity) then Prop.Entity:Remove() end
		table.remove(GAMEMODE.MapEntities.WorldProps, intKey)
		ReindexWorldProps()
		local ply = EditorPlayer()
		if ply then SendNetworkMessage("UD_RemoveWorldProp", ply, {intKey}) end
	end

	local function SendPlayerSpawn(intKey)
		local ply = EditorPlayer()
		local Spawn = GAMEMODE.MapEntities.PlayerSpawns[intKey]
		if not ply or not Spawn then return end
		SendNetworkMessage("UD_UpdatePlayerSpawn", ply, {intKey, Spawn.Position, Spawn.Angle})
	end

	function GM:CreatePlayerSpawn(vecPosition, angAngle)
		table.insert(GAMEMODE.MapEntities.PlayerSpawns, {Position = vecPosition, Angle = angAngle or Angle(0, 0, 0)})
		SendPlayerSpawn(#GAMEMODE.MapEntities.PlayerSpawns)
	end

	function GM:UpdatePlayerSpawn(intKey, vecPosition, angAngle)
		local Spawn = GAMEMODE.MapEntities.PlayerSpawns[intKey]
		if not Spawn then return end
		Spawn.Position = vecPosition or Spawn.Position
		Spawn.Angle = angAngle or Spawn.Angle
		SendPlayerSpawn(intKey)
	end

	function GM:RemovePlayerSpawn(intKey)
		if not GAMEMODE.MapEntities.PlayerSpawns[intKey] then return end
		table.remove(GAMEMODE.MapEntities.PlayerSpawns, intKey)
		local ply = EditorPlayer()
		if ply then SendNetworkMessage("UD_RemovePlayerSpawn", ply, {intKey}) end
	end

	local function SendOreVein(intKey)
		local ply = EditorPlayer()
		local Vein = GAMEMODE.MapEntities.OreVeins[intKey]
		if not ply or not Vein then return end
		SendNetworkMessage("UD_UpdateOreVein", ply, {intKey, Vein.Position, Vein.Angle, Vein.Ore, Vein.SpawnTime, Vein.Model})
	end

	local function SpawnOreVeinEntity(intKey)
		local Vein = GAMEMODE.MapEntities.OreVeins[intKey]
		if not Vein then return end
		if IsValid(Vein.Entity) then Vein.Entity:Remove() end
		local entVein = ents.Create("prop_physics")
		if not IsValid(entVein) then return end
		entVein:SetModel(Vein.Model)
		local vecMins, vecMaxs = entVein:GetModelBounds()
		entVein:SetPos(Vein.Position - Vector(0, 0, vecMins.z + (vecMaxs.z - vecMins.z) * GAMEMODE.OreVeinSink))
		entVein:SetAngles(Vein.Angle)
		entVein:Spawn()
		entVein:PhysicsInit(SOLID_VPHYSICS)
		entVein:SetMoveType(MOVETYPE_NONE)
		local physVein = entVein:GetPhysicsObject()
		if IsValid(physVein) then physVein:EnableMotion(false) end
		entVein:DrawShadow(false)
		local Ore = GAMEMODE:GetOreType(Vein.Ore)
		if Ore then entVein:SetColor(Ore.Tint) end
		entVein:SetNWString("UD_Ore", Vein.Ore)
		entVein.UD_OreVeinKey = intKey
		Vein.Entity = entVein
	end

	local function ReindexOreVeins()
		for intKey, Vein in ipairs(GAMEMODE.MapEntities.OreVeins) do
			if IsValid(Vein.Entity) then Vein.Entity.UD_OreVeinKey = intKey end
		end
	end

	function GM:CreateOreVein(vecPosition, angAngle, strOre, intSpawnTime, strModel, boolLoad)
		if not GAMEMODE:GetOreType(strOre) then return end
		local Vein = {Position = vecPosition, Angle = angAngle or Angle(0, 0, 0), Ore = strOre, SpawnTime = intSpawnTime or GAMEMODE.OreVeinRespawn}
		Vein.Model = util.IsValidModel(strModel or "") and strModel or GAMEMODE:DefaultOreVeinModel()
		table.insert(GAMEMODE.MapEntities.OreVeins, Vein)
		local intKey = #GAMEMODE.MapEntities.OreVeins
		if boolLoad then
			timer.Simple(1 + 0.05 * intKey, function()
				for intNow, Other in ipairs(GAMEMODE.MapEntities.OreVeins) do
					if Other == Vein then SpawnOreVeinEntity(intNow) end
				end
			end)
		else
			SpawnOreVeinEntity(intKey)
		end
		SendOreVein(intKey)
	end

	function GM:UpdateOreVein(intKey, vecPosition, angAngle, strOre, intSpawnTime, strModel)
		local Vein = GAMEMODE.MapEntities.OreVeins[intKey]
		if not Vein then return end
		Vein.Position = vecPosition or Vein.Position
		Vein.Angle = angAngle or Vein.Angle
		if GAMEMODE:GetOreType(strOre) then Vein.Ore = strOre end
		if GAMEMODE:IsOreVeinModel(strModel) then Vein.Model = strModel end
		Vein.SpawnTime = intSpawnTime or Vein.SpawnTime
		SpawnOreVeinEntity(intKey)
		SendOreVein(intKey)
	end

	function GM:RemoveOreVein(intKey)
		local Vein = GAMEMODE.MapEntities.OreVeins[intKey]
		if not Vein then return end
		if IsValid(Vein.Entity) then Vein.Entity:Remove() end
		table.remove(GAMEMODE.MapEntities.OreVeins, intKey)
		ReindexOreVeins()
		local ply = EditorPlayer()
		if ply then SendNetworkMessage("UD_RemoveOreVein", ply, {intKey}) end
	end

	function GM:PickPlayerSpawn()
		local tblSpawns = GAMEMODE.MapEntities.PlayerSpawns
		if #tblSpawns == 0 then return end
		local tblFree = {}
		for _, Spawn in ipairs(tblSpawns) do
			local boolBlocked = false
			for _, ent in ipairs(ents.FindInSphere(Spawn.Position, 40)) do
				if ent:IsPlayer() and ent:Alive() then
					boolBlocked = true
					break
				end
			end
			if not boolBlocked then table.insert(tblFree, Spawn) end
		end
		if #tblFree == 0 then tblFree = tblSpawns end
		return tblFree[math.random(#tblFree)]
	end

	function GM:LoadMapObjects()
		local strFileName = GAMEMODE.DataFolder .. "/Maps/" .. game.GetMap() .. ".txt"
		if not file.Exists(strFileName, "DATA") then return end
		local tblDecodedTable = util.JSONToTable(file.Read(strFileName, "DATA") or "")
		if not tblDecodedTable then
			ErrorNoHalt("[Gravenmark] Could not read map objects from data/" .. strFileName .. "\n")
			return
		end
		for _, SpawnPoint in ipairs(tblDecodedTable.NPCSpawnPoints or {}) do
			GAMEMODE:CreateSpawnPoint(SpawnPoint.Position, SpawnPoint.Angle or Angle(0, 90, 0), SpawnPoint.NPC, SpawnPoint.Level, SpawnPoint.SpawnTime, SpawnPoint.Radius, SpawnPoint.Count)
		end
		for k, WorldProp in ipairs(tblDecodedTable.WorldProps or {}) do
			timer.Simple(0.05 * k, function() GAMEMODE:CreateWorldProp(WorldProp.Model, WorldProp.Position, WorldProp.Angle, nil, true) end)
		end
		for _, PlayerSpawn in ipairs(tblDecodedTable.PlayerSpawns or {}) do
			GAMEMODE:CreatePlayerSpawn(PlayerSpawn.Position, PlayerSpawn.Angle)
		end
		for _, Vein in ipairs(tblDecodedTable.OreVeins or {}) do
			GAMEMODE:CreateOreVein(Vein.Position, Vein.Angle, Vein.Ore, Vein.SpawnTime, Vein.Model, true)
		end
	end
	hook.Add("Initialize", "LoadMapObjects", function() GAMEMODE:LoadMapObjects() end)

	function GM:SaveMapObjects()
		local strFileName = GAMEMODE.DataFolder .. "/Maps/" .. game.GetMap() .. ".txt"
		local tblSaveTable = {NPCSpawnPoints = {}, WorldProps = {}, PlayerSpawns = {}, OreVeins = {}}
		for _, Vein in ipairs(GAMEMODE.MapEntities.OreVeins) do
			table.insert(tblSaveTable.OreVeins, {Position = Vein.Position, Angle = Vein.Angle, Ore = Vein.Ore, SpawnTime = Vein.SpawnTime, Model = Vein.Model})
		end
		for _, Spawn in ipairs(GAMEMODE.MapEntities.PlayerSpawns) do
			table.insert(tblSaveTable.PlayerSpawns, {Position = Spawn.Position, Angle = Spawn.Angle})
		end
		for _, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
			table.insert(tblSaveTable.NPCSpawnPoints, {Position = Spawn.Position, Angle = Spawn.Angle, NPC = Spawn.NPC, Level = Spawn.Level, SpawnTime = Spawn.SpawnTime, Radius = Spawn.Radius, Count = Spawn.Count})
		end
		for _, Prop in ipairs(GAMEMODE.MapEntities.WorldProps) do
			table.insert(tblSaveTable.WorldProps, {Model = Prop.Model, Position = Prop.Position, Angle = Prop.Angle})
		end
		file.Write(strFileName, util.TableToJSON(tblSaveTable))
		local ply = EditorPlayer()
		if ply then ply:CreateNotification("Map layout saved to data/" .. strFileName) end
	end

	local function FindSpawnPosition(Spawn)
		local Lift = Vector(0, 0, 8)
		local Radius = Spawn.Radius or 0
		if Radius <= 0 then return Spawn.Position + Lift end
		local Theta = math.Rand(0, math.pi * 2)
		local Distance = math.sqrt(math.Rand(0, 1)) * Radius
		local Candidate = Spawn.Position + Vector(math.cos(Theta) * Distance, math.sin(Theta) * Distance, 0)
		local Trace = util.TraceLine({start = Candidate + Vector(0, 0, 64), endpos = Candidate - Vector(0, 0, 256), mask = MASK_NPCSOLID_BRUSHONLY})
		if Trace.Hit and not Trace.StartSolid then return Trace.HitPos + Lift end
		return Spawn.Position + Lift
	end

	function GM:SpawnMapEntities()
		if GAMEMODE.EventHasStarted then return end
		local NPCCount = #ents.FindByClass("npc_*")
		for _, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
			if (Spawn.SpawnTime or 0) <= 0 then continue end
			for Slot = 1, Spawn.Count or 1 do
				if NPCCount >= MaxNPCs then return end
				local Monster = Spawn.Monsters[Slot]
				if not IsValid(Monster) then
					if not Spawn.NextSpawns[Slot] then
						Spawn.NextSpawns[Slot] = Monster == nil and CurTime() or CurTime() + Spawn.SpawnTime
					end
					if CurTime() >= Spawn.NextSpawns[Slot] then
						local NewMonster = GAMEMODE:CreateNPC(Spawn.NPC, {Position = FindSpawnPosition(Spawn), Angle = Spawn.Angle, Level = Spawn.Level})
						Spawn.Monsters[Slot] = IsValid(NewMonster) and NewMonster or NULL
						Spawn.NextSpawns[Slot] = nil
						if IsValid(NewMonster) then NPCCount = NPCCount + 1 end
					end
				end
			end
		end
	end
	timer.Create("UD_SpawnMapEntities", 1, 0, function() GAMEMODE:SpawnMapEntities() end)

	function GM:CreateNPC(strNPC, tblSpawnPoint)
		local tblNPCTable = NPCTable(strNPC)
		if not tblNPCTable then return end
		if tblNPCTable.SpawnName == "npc_turret_floor" then return end
		local entNewMonster = ents.Create(tblNPCTable.SpawnName)
		entNewMonster:SetPos(tblSpawnPoint.Position)
		entNewMonster:SetAngles(tblSpawnPoint.Angle or Angle(0, 90, 0))
		entNewMonster:SetKeyValue("spawnflags","512")
		entNewMonster:DrawShadow(false)
		for strKey, strValue in pairs(tblNPCTable.KeyValues or {}) do
			entNewMonster:SetKeyValue(strKey, tostring(strValue))
		end
		if tblNPCTable.Weapon then
			entNewMonster:SetKeyValue("additionalequipment", tblNPCTable.Weapon)
			entNewMonster:SetKeyValue("spawnflags","8192")
		end
		if tblNPCTable.Accuracy then
			entNewMonster:SetCurrentWeaponProficiency( tblNPCTable.Accuracy )
		end
		if tblNPCTable.Model then
			entNewMonster:SetModel(tblNPCTable.Model)
		end
		if tblNPCTable.Color then
			local r = tblNPCTable.Color[1]
			local g = tblNPCTable.Color[2]
			local b = tblNPCTable.Color[3]
			local a = tblNPCTable.Color[4]
			entNewMonster:SetColor(Color(r,g,b,a))
		end
		entNewMonster:Spawn()
		GAMEMODE:ApplyNPCSkin(entNewMonster, tblNPCTable)
		GAMEMODE:ApplyNPCHeldItems(entNewMonster, tblNPCTable)
		if tblNPCTable.DeathDistance then
			for _, ent in pairs(ents.FindInSphere( tblSpawnPoint.Position, tblNPCTable.DeathDistance )) do
				if IsValid(ent) and ent:IsPlayer() then
					ent:Kill()
				end
			end
		end
		if tblNPCTable.Frozen then
			entNewMonster:DropToFloor()
			local phys = entNewMonster:GetPhysicsObject()
			if IsValid( phys ) then
				phys:EnableMotion( false )
			end
		end
		if  tblNPCTable.Resistance then
			entNewMonster.Resistance = tblNPCTable.Resistance
		end
		entNewMonster.Name = tblNPCTable.Name
		entNewMonster.Position = tblSpawnPoint.Position
		entNewMonster.Race = tblNPCTable.Race
		entNewMonster.Invincible = tblNPCTable.Invincible
		entNewMonster.Shop = tblNPCTable.Shop
		entNewMonster.Bank = tblNPCTable.Bank
		entNewMonster.Quest = tblNPCTable.Quest
		entNewMonster.Auction = tblNPCTable.Auction
		entNewMonster.Appearance = tblNPCTable.Appearance
		local intTotalFlags = 1 + 8192
		if tblNPCTable.Idle then
			entNewMonster:SetNPCState(NPC_STATE_IDLE)
			intTotalFlags = intTotalFlags + 16 + 128
		end
		entNewMonster:SetKeyValue("spawnflags", intTotalFlags)
		entNewMonster:SetNWString("npc", tblNPCTable.Name)
		local intLevel = math.Clamp(tblSpawnPoint.Level + math.random(-2, 2), 1, tblSpawnPoint.Level + 2)
		entNewMonster:SetNWInt("level", intLevel)
		local intHealth = intLevel * (tblNPCTable.HealthPerLevel or 10)
		entNewMonster:SetMaxHealth(intHealth)
		entNewMonster:SetNWInt("MaxHealth", intHealth)
		entNewMonster:SetHealth(intHealth)
		entNewMonster:SetNWInt("Health", intHealth)
		timer.Simple(1, function()
			if not IsValid(entNewMonster) or entNewMonster.LastPlayerAttacker then return end
			if entNewMonster:Health() == intHealth and entNewMonster:GetMaxHealth() == intHealth then return end
			entNewMonster:SetMaxHealth(intHealth)
			entNewMonster:SetHealth(intHealth)
			entNewMonster:SetNWInt("Health", intHealth)
		end)
		for _, ent in ipairs(player.GetAll()) do GAMEMODE:SetNPCRelationship(entNewMonster, ent) end
		for _, ent in ipairs(ents.FindByClass("npc_*")) do GAMEMODE:SetNPCRelationship(entNewMonster, ent) end
		entNewMonster:Activate()
		return entNewMonster
	end

	function GM:SetNPCRelationship(entNPC, ent)
		if not IsValid(entNPC) or not IsValid(ent) or entNPC == ent then return end
		if not entNPC:IsNPC() or not entNPC.Race or not ent.Race then return end
		if not ent:IsNPC() and not ent:IsPlayer() then return end
		if ent.Race == entNPC.Race then
			entNPC:AddEntityRelationship(ent, GAMEMODE.RelationLike, 99)
			if ent:IsNPC() then ent:AddEntityRelationship(entNPC, GAMEMODE.RelationLike, 99) end
		else
			if not ent.Invincible then entNPC:AddEntityRelationship(ent, GAMEMODE.RelationHate, 99) end
			if not entNPC.Invincible and ent:IsNPC() then ent:AddEntityRelationship(entNPC, GAMEMODE.RelationHate, 99) end
			if ent:IsPlayer() and not GAMEMODE.EventHasStarted and entNPC:GetNWInt("level") < ent:GetLevel() then
				entNPC:AddEntityRelationship(ent, GAMEMODE.RelationNeutral, 99)
			end
		end
	end

	hook.Add("UD_Hook_PlayerLoad", "UD_NPCRelationships", function(ply)
		for _, entNPC in ipairs(ents.FindByClass("npc_*")) do
			GAMEMODE:SetNPCRelationship(entNPC, ply)
		end
	end)

	if game.SinglePlayer() then
		hook.Add("UD_Hook_PlayerLoad", "UD_SendMapEditorData", function(ply)
			for intKey in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do SendSpawnPoint(intKey) end
			for intKey in ipairs(GAMEMODE.MapEntities.WorldProps) do SendWorldProp(intKey) end
			for intKey in ipairs(GAMEMODE.MapEntities.PlayerSpawns) do SendPlayerSpawn(intKey) end
			for intKey in ipairs(GAMEMODE.MapEntities.OreVeins) do SendOreVein(intKey) end
		end)

		local function IsEditor(ply)
			return IsValid(ply) and ply:IsAdmin()
		end

		local function VectorFromArgs(args, intStart)
			local x, y, z = tonumber(args[intStart]), tonumber(args[intStart + 1]), tonumber(args[intStart + 2])
			if x and y and z then return Vector(x, y, z) end
		end

		local function ClampArg(Value, Min, Max, Default)
			return math.Clamp(math.Round(tonumber(Value) or Default), Min, Max)
		end

		local function YawAngle(Value)
			return Angle(0, tonumber(Value) or 0, 0)
		end

		local function IsKnownModel(strModel)
			return isstring(strModel) and (GAMEMODE:GetStationBuild(strModel) ~= nil or util.IsValidModel(strModel))
		end

		concommand.Add("UD_Dev_EditMap_AddSpawnPoint", function(ply, command, args)
			if not IsEditor(ply) then return end
			local Position = VectorFromArgs(args, 1)
			if not Position or not NPCTable(args[5]) then return end
			GAMEMODE:CreateSpawnPoint(Position, YawAngle(args[4]), args[5], ClampArg(args[6], 1, 100, 5), ClampArg(args[7], 1, 3600, 30), ClampArg(args[8], 0, 2000, 0), ClampArg(args[9], 1, 20, 1))
		end)

		concommand.Add("UD_Dev_EditMap_UpdateSpawnPoint", function(ply, command, args)
			if not IsEditor(ply) then return end
			local intKey = tonumber(args[1])
			if not intKey or not GAMEMODE.MapEntities.NPCSpawnPoints[intKey] or not NPCTable(args[2]) then return end
			GAMEMODE:UpdateSpawnPoint(intKey, nil, YawAngle(args[5]), args[2], ClampArg(args[3], 1, 100, 5), ClampArg(args[4], 1, 3600, 30), ClampArg(args[6], 0, 2000, 0), ClampArg(args[7], 1, 20, 1))
		end)

		concommand.Add("UD_Dev_EditMap_MoveSpawnPoint", function(ply, command, args)
			if not IsEditor(ply) then return end
			local intKey = tonumber(args[1])
			local Position = VectorFromArgs(args, 2)
			if not intKey or not Position or not GAMEMODE.MapEntities.NPCSpawnPoints[intKey] then return end
			GAMEMODE:UpdateSpawnPoint(intKey, Position)
		end)

		concommand.Add("UD_Dev_EditMap_RemoveSpawnPoint", function(ply, command, args)
			if not IsEditor(ply) then return end
			GAMEMODE:RemoveSpawnPoint(tonumber(args[1]))
		end)

		concommand.Add("UD_Dev_EditMap_AddWorldProp", function(ply, command, args)
			if not IsEditor(ply) then return end
			local Position = VectorFromArgs(args, 1)
			if not Position or not IsKnownModel(args[5]) then return end
			GAMEMODE:CreateWorldProp(args[5], Position + Vector(0, 0, 16), YawAngle(args[4]))
		end)

		concommand.Add("UD_Dev_EditMap_SetWorldProp", function(ply, command, args)
			if not IsEditor(ply) then return end
			local intKey = tonumber(args[1])
			if not intKey or not GAMEMODE.MapEntities.WorldProps[intKey] or not IsKnownModel(args[2]) then return end
			GAMEMODE:UpdateWorldProp(intKey, args[2], nil, YawAngle(args[3]))
		end)

		concommand.Add("UD_Dev_EditMap_MoveWorldProp", function(ply, command, args)
			if not IsEditor(ply) then return end
			local intKey = tonumber(args[1])
			local Position = VectorFromArgs(args, 2)
			if not intKey or not Position or not GAMEMODE.MapEntities.WorldProps[intKey] then return end
			GAMEMODE:UpdateWorldProp(intKey, nil, Position + Vector(0, 0, 16), nil, nil, nil, true)
		end)

		concommand.Add("UD_Dev_EditMap_RemoveWorldProp", function(ply, command, args)
			if not IsEditor(ply) then return end
			GAMEMODE:RemoveWorldProp(tonumber(args[1]))
		end)

		concommand.Add("UD_Dev_EditMap_AddPlayerSpawn", function(ply, command, args)
			if not IsEditor(ply) then return end
			local Position = VectorFromArgs(args, 1)
			if not Position then return end
			GAMEMODE:CreatePlayerSpawn(Position, YawAngle(args[4]))
		end)

		concommand.Add("UD_Dev_EditMap_UpdatePlayerSpawn", function(ply, command, args)
			if not IsEditor(ply) then return end
			GAMEMODE:UpdatePlayerSpawn(tonumber(args[1]), nil, YawAngle(args[2]))
		end)

		concommand.Add("UD_Dev_EditMap_MovePlayerSpawn", function(ply, command, args)
			if not IsEditor(ply) then return end
			local Position = VectorFromArgs(args, 2)
			if not Position then return end
			GAMEMODE:UpdatePlayerSpawn(tonumber(args[1]), Position)
		end)

		concommand.Add("UD_Dev_EditMap_RemovePlayerSpawn", function(ply, command, args)
			if not IsEditor(ply) then return end
			GAMEMODE:RemovePlayerSpawn(tonumber(args[1]))
		end)

		concommand.Add("UD_Dev_EditMap_AddOreVein", function(ply, command, args)
			if not IsEditor(ply) then return end
			local Position = VectorFromArgs(args, 1)
			if not Position then return end
			local strModel = GAMEMODE:IsOreVeinModel(args[7]) and args[7] or nil
			GAMEMODE:CreateOreVein(Position, YawAngle(args[4]), args[5], ClampArg(args[6], 10, 3600, GAMEMODE.OreVeinRespawn), strModel)
		end)

		concommand.Add("UD_Dev_EditMap_UpdateOreVein", function(ply, command, args)
			if not IsEditor(ply) then return end
			GAMEMODE:UpdateOreVein(tonumber(args[1]), nil, YawAngle(args[4]), args[2], ClampArg(args[3], 10, 3600, GAMEMODE.OreVeinRespawn), args[5])
		end)

		concommand.Add("UD_Dev_EditMap_MoveOreVein", function(ply, command, args)
			if not IsEditor(ply) then return end
			local Position = VectorFromArgs(args, 2)
			if not Position then return end
			GAMEMODE:UpdateOreVein(tonumber(args[1]), Position)
		end)

		concommand.Add("UD_Dev_EditMap_RemoveOreVein", function(ply, command, args)
			if not IsEditor(ply) then return end
			GAMEMODE:RemoveOreVein(tonumber(args[1]))
		end)

		concommand.Add("UD_Dev_EditMap_SaveMap", function(ply, command, args)
			if not IsEditor(ply) then return end
			GAMEMODE:SaveMapObjects()
		end)
	end
end

if CLIENT then
	net.Receive("UD_UpdateSpawnPoint", function()
		local intKey = net.ReadDouble()
		local Position = net.ReadVector()
		local Ang = net.ReadAngle()
		local NPC = net.ReadString()
		local Level = net.ReadDouble()
		local SpawnTime = net.ReadDouble()
		local Radius = net.ReadDouble()
		local Count = net.ReadDouble()
		GAMEMODE.MapEntities.NPCSpawnPoints[intKey] = {Position = Position, Angle = Ang, NPC = NPC, Level = Level, SpawnTime = SpawnTime, Radius = Radius, Count = Count}
		hook.Run("UD_MapObjectsChanged")
	end)

	net.Receive("UD_RemoveSpawnPoint", function()
		table.remove(GAMEMODE.MapEntities.NPCSpawnPoints, net.ReadDouble())
		hook.Run("UD_MapObjectsChanged")
	end)

	net.Receive("UD_UpdateWorldProp", function()
		local intKey = net.ReadDouble()
		local Model = net.ReadString()
		local Position = net.ReadVector()
		local Ang = net.ReadAngle()
		local EntIndex = net.ReadDouble()
		GAMEMODE.MapEntities.WorldProps[intKey] = {Model = Model, Position = Position, Angle = Ang, EntIndex = EntIndex}
		hook.Run("UD_MapObjectsChanged")
	end)

	net.Receive("UD_RemoveWorldProp", function()
		table.remove(GAMEMODE.MapEntities.WorldProps, net.ReadDouble())
		hook.Run("UD_MapObjectsChanged")
	end)

	net.Receive("UD_UpdatePlayerSpawn", function()
		local intKey = net.ReadDouble()
		local Position = net.ReadVector()
		local Ang = net.ReadAngle()
		GAMEMODE.MapEntities.PlayerSpawns[intKey] = {Position = Position, Angle = Ang}
		hook.Run("UD_MapObjectsChanged")
	end)

	net.Receive("UD_RemovePlayerSpawn", function()
		table.remove(GAMEMODE.MapEntities.PlayerSpawns, net.ReadDouble())
		hook.Run("UD_MapObjectsChanged")
	end)

	net.Receive("UD_UpdateOreVein", function()
		local intKey = net.ReadDouble()
		local Position = net.ReadVector()
		local Ang = net.ReadAngle()
		local Ore = net.ReadString()
		local SpawnTime = net.ReadDouble()
		local Model = net.ReadString()
		GAMEMODE.MapEntities.OreVeins[intKey] = {Position = Position, Angle = Ang, Ore = Ore, SpawnTime = SpawnTime, Model = Model}
		hook.Run("UD_MapObjectsChanged")
	end)

	net.Receive("UD_RemoveOreVein", function()
		table.remove(GAMEMODE.MapEntities.OreVeins, net.ReadDouble())
		hook.Run("UD_MapObjectsChanged")
	end)
end
