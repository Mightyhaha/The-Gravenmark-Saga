GM.IconRenderer = {}
local Renderer = GM.IconRenderer

Renderer.Size = 128
Renderer.Folder = GM.GeneratedIconFolder or "gravenmark_icons"
Renderer.Margin = 1.12
Renderer.FOV = 20
Renderer.Background = Color(196, 182, 152)
Renderer.SlotViews = {
	slot_helm = Angle(8, 215, 0),
	slot_chest = Angle(4, 180, 0),
	slot_shoulder = Angle(4, 180, 0),
	slot_waist = Angle(35, 200, 0),
}
Renderer.DefaultView = Angle(25, 215, 0)
Renderer.Queue = {}
Renderer.Current = nil

local function NormalizeModel(Model)
	if isstring(Model) then return {{Model = Model, Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0)}} end
	if istable(Model) then return Model end
	return {}
end

local function ScaleVector(Scale)
	if isnumber(Scale) then return Vector(Scale, Scale, Scale) end
	if isvector(Scale) then return Vector(Scale) end
	return nil
end

local function ModelExists(strModel)
	if not isstring(strModel) or strModel == "" then return false end
	return util.IsValidModel(strModel) or file.Exists(strModel, "GAME")
end

local function PartTransforms(tblItem)
	local tblModel = NormalizeModel(tblItem.Model)
	local tblSlot = tblItem.Slot and GAMEMODE.DataBase.Slots[tblItem.Slot]
	local angBody = tblSlot and tblSlot.BodyAngle
	local tblOut = {}
	local vecRoot, angRoot
	for Index, Info in ipairs(tblModel) do
		local vecLocal = Info.Position and Vector(Info.Position) or Vector(0, 0, 0)
		local angLocal = Info.Angle and Angle(Info.Angle.p, Info.Angle.y, Info.Angle.r) or Angle(0, 0, 0)
		if Index == 1 and Info.BoneMerge then
			vecLocal, angLocal = Vector(0, 0, 0), Angle(0, 0, 0)
		end
		local vecPart, angPart
		if Index == 1 then
			angPart = angLocal
			vecPart = LocalToWorld(vecLocal, Angle(0, 0, 0), vector_origin, angPart)
			vecRoot, angRoot = vecPart, angPart
		else
			local _, angWorld = LocalToWorld(vector_origin, angLocal, vector_origin, angRoot)
			angPart = angWorld
			vecPart = LocalToWorld(vecLocal, Angle(0, 0, 0), vecRoot, angPart)
		end
		if angBody then vecPart, angPart = LocalToWorld(vecPart, angPart, vector_origin, angBody) end
		table.insert(tblOut, {Model = Info.Model, Pos = vecPart, Ang = angPart, Scale = ScaleVector(Info.Scale), Color = Info.Color, Material = Info.Material})
	end
	return tblOut
end

local function BuildParts(tblItem)
	local tblParts = {}
	for _, Part in ipairs(PartTransforms(tblItem)) do
		if ModelExists(Part.Model) then
			local entPart = ClientsideModel(Part.Model, RENDERGROUP_OPAQUE)
			if IsValid(entPart) then
				entPart:SetNoDraw(true)
				entPart:SetPos(Part.Pos)
				entPart:SetAngles(Part.Ang)
				entPart:SetMaterial(Part.Material or "")
				if Part.Scale then
					local matScale = Matrix()
					matScale:Scale(Part.Scale)
					entPart:EnableMatrix("RenderMultiply", matScale)
				end
				Part.Entity = entPart
				table.insert(tblParts, Part)
			end
		end
	end
	return tblParts
end

local function FreeParts(tblParts)
	for _, Part in ipairs(tblParts or {}) do
		if IsValid(Part.Entity) then Part.Entity:Remove() end
	end
end

local function PartCorners(Part)
	local vecMin, vecMax = Part.Entity:GetRenderBounds()
	if Part.Scale then
		vecMin = Vector(vecMin.x * Part.Scale.x, vecMin.y * Part.Scale.y, vecMin.z * Part.Scale.z)
		vecMax = Vector(vecMax.x * Part.Scale.x, vecMax.y * Part.Scale.y, vecMax.z * Part.Scale.z)
	end
	local tblCorners = {}
	for _, x in ipairs({vecMin.x, vecMax.x}) do
		for _, y in ipairs({vecMin.y, vecMax.y}) do
			for _, z in ipairs({vecMin.z, vecMax.z}) do
				local vecCorner = LocalToWorld(Vector(x, y, z), Angle(0, 0, 0), Part.Pos, Part.Ang)
				table.insert(tblCorners, vecCorner)
			end
		end
	end
	return tblCorners
end

local function AllCorners(tblParts)
	local tblCorners = {}
	for _, Part in ipairs(tblParts) do
		for _, vecCorner in ipairs(PartCorners(Part)) do table.insert(tblCorners, vecCorner) end
	end
	return tblCorners
end

local function AutoView(tblCorners, boolDiagonal)
	local vecMin, vecMax = Vector(math.huge, math.huge, math.huge), Vector(-math.huge, -math.huge, -math.huge)
	for _, vec in ipairs(tblCorners) do
		vecMin = Vector(math.min(vecMin.x, vec.x), math.min(vecMin.y, vec.y), math.min(vecMin.z, vec.z))
		vecMax = Vector(math.max(vecMax.x, vec.x), math.max(vecMax.y, vec.y), math.max(vecMax.z, vec.z))
	end
	local vecSize = vecMax - vecMin
	local tblAxes = {{Vector(1, 0, 0), vecSize.x}, {Vector(0, 1, 0), vecSize.y}, {Vector(0, 0, 1), vecSize.z}}
	table.sort(tblAxes, function(a, b) return a[2] < b[2] end)
	local vecThin, vecMid, vecLong = tblAxes[1][1], tblAxes[2][1], tblAxes[3][1]
	local vecForward = -vecThin
	if vecThin.z == 0 then vecForward = vecThin end
	if not boolDiagonal then
		local numSide = ((vecMin + vecMax) / 2):Dot(vecThin)
		if math.abs(numSide) > 0.1 then vecForward = vecThin * (numSide > 0 and -1 or 1) end
	end
	local vecUp
	if boolDiagonal then
		vecUp = (vecLong + vecMid):GetNormalized()
	else
		vecUp = math.abs(vecLong.z) > 0.5 and vecLong or (math.abs(vecMid.z) > 0.5 and vecMid or vecLong)
	end
	local angView = vecForward:AngleEx(vecUp)
	if boolDiagonal then
		local vecGrip = -(vecMin + vecMax) / 2
		if vecGrip:Length() < 1 then return angView end
		local function GripAngle(ang)
			return math.deg(math.atan2(vecGrip:Dot(ang:Up()), vecGrip:Dot(ang:Right())))
		end
		local numTurn = math.NormalizeAngle(-135 - GripAngle(angView))
		local angBest, numBest = angView, math.huge
		for _, numSign in ipairs({1, -1}) do
			local angTry = Angle(angView.p, angView.y, angView.r)
			angTry:RotateAroundAxis(angTry:Forward(), numTurn * numSign)
			local numMiss = math.abs(math.NormalizeAngle(GripAngle(angTry) + 135))
			if numMiss < numBest then angBest, numBest = angTry, numMiss end
		end
		return angBest
	end
	angView:RotateAroundAxis(angView:Up(), 20)
	angView:RotateAroundAxis(angView:Right(), -10)
	return angView
end

local function ViewAngle(tblItem, tblCorners)
	if tblItem.IconView and tblItem.IconView.Angle then return Angle(tblItem.IconView.Angle.p, tblItem.IconView.Angle.y, tblItem.IconView.Angle.r) end
	if tblItem.Slot and Renderer.SlotViews[tblItem.Slot] then return Angle(Renderer.SlotViews[tblItem.Slot]) end
	if tblItem.Slot == "slot_primaryweapon" then return AutoView(tblCorners, true) end
	if tblItem.Slot == "slot_offhand" then return AutoView(tblCorners, false) end
	return Angle(Renderer.DefaultView)
end

local function Frame(tblCorners, angView, numZoom)
	local vecForward, vecRight, vecUp = angView:Forward(), angView:Right(), angView:Up()
	local numMinX, numMaxX, numMinY, numMaxY, numMinZ, numMaxZ = math.huge, -math.huge, math.huge, -math.huge, math.huge, -math.huge
	for _, vec in ipairs(tblCorners) do
		local x, y, z = vec:Dot(vecRight), vec:Dot(vecUp), vec:Dot(vecForward)
		numMinX, numMaxX = math.min(numMinX, x), math.max(numMaxX, x)
		numMinY, numMaxY = math.min(numMinY, y), math.max(numMaxY, y)
		numMinZ, numMaxZ = math.min(numMinZ, z), math.max(numMaxZ, z)
	end
	local numX, numY, numZ = (numMinX + numMaxX) / 2, (numMinY + numMaxY) / 2, (numMinZ + numMaxZ) / 2
	local numTan = math.tan(math.rad(Renderer.FOV / 2)) * (numZoom or 1) / Renderer.Margin
	local numDistance = (numZ - numMinZ) + 2
	for _, vec in ipairs(tblCorners) do
		local numSpread = math.max(math.abs(vec:Dot(vecRight) - numX), math.abs(vec:Dot(vecUp) - numY))
		numDistance = math.max(numDistance, numSpread / numTan - (vec:Dot(vecForward) - numZ))
	end
	local vecCenter = vecRight * numX + vecUp * numY + vecForward * numZ
	return vecCenter - vecForward * numDistance, numDistance + (numMaxZ - numZ) + 64
end

local function BoxLight(vecDirection, tblLights, numAmbient)
	local vecTotal = Vector(numAmbient, numAmbient, numAmbient)
	for _, Light in ipairs(tblLights) do
		local numAmount = math.max(vecDirection:Dot(Light.Dir), 0)
		vecTotal = vecTotal + Light.Color * numAmount
	end
	return vecTotal
end

local BoxDirections = {
	[BOX_FRONT] = Vector(1, 0, 0),
	[BOX_BACK] = Vector(-1, 0, 0),
	[BOX_RIGHT] = Vector(0, -1, 0),
	[BOX_LEFT] = Vector(0, 1, 0),
	[BOX_TOP] = Vector(0, 0, 1),
	[BOX_BOTTOM] = Vector(0, 0, -1),
}

local function SetStudioLighting(angView)
	local vecForward, vecRight, vecUp = angView:Forward(), angView:Right(), angView:Up()
	local tblLights = {
		{Dir = (-vecForward * 0.6 + vecUp * 0.6 - vecRight * 0.5):GetNormalized(), Color = Vector(1.25, 1.12, 0.95)},
		{Dir = (-vecForward * 0.5 + vecRight * 0.7 - vecUp * 0.2):GetNormalized(), Color = Vector(0.4, 0.45, 0.55)},
	}
	render.SuppressEngineLighting(true)
	for intBox, vecDirection in pairs(BoxDirections) do
		local vecLight = BoxLight(vecDirection, tblLights, 0.32)
		render.SetModelLighting(intBox, vecLight.x, vecLight.y, vecLight.z)
	end
end

local RenderTarget
local function GetTarget()
	RenderTarget = RenderTarget or GetRenderTarget("ud_icon_renderer_" .. Renderer.Size, Renderer.Size, Renderer.Size)
	return RenderTarget
end

local function RenderItem(tblItem, tblParts)
	local tblCorners = AllCorners(tblParts)
	if #tblCorners == 0 then return nil end
	local angView = ViewAngle(tblItem, tblCorners)
	local vecOrigin, numFar = Frame(tblCorners, angView, tblItem.IconView and tblItem.IconView.Zoom)
	local intSize = Renderer.Size
	local clrBack = Renderer.Background

	render.PushRenderTarget(GetTarget())
	render.Clear(clrBack.r, clrBack.g, clrBack.b, 255, true, true)
	cam.Start3D(vecOrigin, angView, Renderer.FOV, 0, 0, intSize, intSize, 1, numFar)
	SetStudioLighting(angView)
	for _, Part in ipairs(tblParts) do
		local Col = Part.Color or Color(255, 255, 255, 255)
		render.SetColorModulation(Col.r / 255, Col.g / 255, Col.b / 255)
		render.SetBlend(1)
		Part.Entity:SetupBones()
		Part.Entity:DrawModel()
	end
	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)
	cam.End3D()
	local strData = render.Capture({format = "png", x = 0, y = 0, w = intSize, h = intSize, alpha = false})
	render.PopRenderTarget()
	return strData
end

function Renderer.IconPath(strName)
	return Renderer.Folder .. "/" .. strName .. ".png"
end

function Renderer.HasIcon(strName)
	return file.Exists(Renderer.IconPath(strName), "DATA") or file.Exists("materials/icons/gen/" .. strName .. ".png", "GAME")
end

function Renderer.ShouldRender(strName, tblItem, strFilter, boolForce)
	if not tblItem.Model or #NormalizeModel(tblItem.Model) == 0 then return false end
	if strFilter then
		if not string.find(strName, strFilter, 1, true) then return false end
	elseif not (tblItem.Slot or tblItem.OreBand or tblItem.CraftBand) then
		return false
	else
		local tblSlot = tblItem.Slot and GAMEMODE.DataBase.Slots[tblItem.Slot]
		if (tblSlot and tblSlot.NoModel) or tblItem.SlotGroup == "ring" then return false end
	end
	return boolForce or not Renderer.HasIcon(strName)
end

function Renderer.Start(strFilter, boolForce)
	Renderer.Queue = {}
	for strName, tblItem in pairs(GAMEMODE.DataBase.Items) do
		if Renderer.ShouldRender(strName, tblItem, strFilter, boolForce) then table.insert(Renderer.Queue, strName) end
	end
	table.sort(Renderer.Queue)
	Renderer.Total = #Renderer.Queue
	Renderer.Done = 0
	Renderer.Failed = 0
	file.CreateDir(Renderer.Folder)
	print("[Icons] Rendering " .. Renderer.Total .. " item icons into data/" .. Renderer.Folder .. "/")
end

function Renderer.Finish()
	print("[Icons] Done: " .. Renderer.Done .. " rendered, " .. Renderer.Failed .. " skipped. Copy data/" .. Renderer.Folder .. "/ to content/materials/icons/gen/ to keep them.")
	if GAMEMODE.MainMenu and GAMEMODE.MainMenu.InventoryTab then GAMEMODE.MainMenu.InventoryTab:LoadInventory() end
end

hook.Add("PostRender", "UD_IconRenderer", function()
	local Current = Renderer.Current
	if Current then
		Current.Frames = Current.Frames + 1
		if Current.Frames < 3 then return end
		Renderer.Current = nil
		local tblItem = GAMEMODE.DataBase.Items[Current.Name]
		local strData
		if tblItem and #Current.Parts > 0 then
			local boolOk, Result = pcall(RenderItem, tblItem, Current.Parts)
			if boolOk then
				strData = Result
			else
				print("[Icons] Error rendering " .. Current.Name .. ": " .. tostring(Result))
			end
		end
		FreeParts(Current.Parts)
		if isstring(strData) and #strData > 0 then
			file.Write(Renderer.IconPath(Current.Name), strData)
			tblItem.Icon = "../data/" .. Renderer.IconPath(Current.Name)
			Renderer.Done = Renderer.Done + 1
		else
			Renderer.Failed = Renderer.Failed + 1
			print("[Icons] Skipped " .. Current.Name .. " (no model could be loaded)")
		end
		if (Renderer.Done + Renderer.Failed) % 25 == 0 then print("[Icons] " .. (Renderer.Done + Renderer.Failed) .. " / " .. Renderer.Total) end
		if #Renderer.Queue == 0 then Renderer.Finish() end
		return
	end
	local strName = table.remove(Renderer.Queue, 1)
	if not strName then return end
	local tblItem = GAMEMODE.DataBase.Items[strName]
	Renderer.Current = {Name = strName, Parts = tblItem and BuildParts(tblItem) or {}, Frames = 0}
end)

concommand.Add("UD_Dev_RenderIcons", function(ply, command, args)
	if not game.SinglePlayer() and not (IsValid(ply) and ply:IsSuperAdmin()) then return end
	local strFilter = args[1]
	if strFilter == "" or strFilter == "*" or strFilter == "all" then strFilter = nil end
	local boolForce = false
	for _, strArg in ipairs(args) do
		if string.lower(strArg) == "force" then boolForce = true end
	end
	if strFilter and string.lower(strFilter) == "force" then strFilter = nil end
	if Renderer.Current then FreeParts(Renderer.Current.Parts) Renderer.Current = nil end
	Renderer.Start(strFilter, boolForce)
	if Renderer.Total == 0 then print("[Icons] Nothing to render. Add force to render existing icons again.") end
end)
