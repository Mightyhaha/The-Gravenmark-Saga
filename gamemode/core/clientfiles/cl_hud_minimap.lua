local MPositionX = ScrW() - 200
local MPositionY = 15
local MSizeW = 160
local MSizeH = 160
local IconSize = 8
local CameraHeight = 900

local RenderInterval = 1 / 15

local ConVarShowMiniMap = CreateClientConVar("ud_showminimap", 1, true, false)

local MiniMapRT = GetRenderTarget("UD_MiniMapRT", 256, 256)
local MiniMapMat = CreateMaterial("UD_MiniMapMat", "UnlitGeneric", {
	["$basetexture"] = MiniMapRT:GetName(),
	["$ignorez"] = 1,
})

local mat_cache = {}
local NextRender = 0
local RenderOrigin = nil
local IsRendering = false
local MapBorder = nil

local function GetIconMaterial(Path)
	local mat = mat_cache[Path]
	if not mat then
		mat = Material(Path)
		mat_cache[Path] = mat
	end
	return mat
end

local function GetNPCIconPath(NPCTable)
	if NPCTable.Appearance then return "icon16/palette.png" end
	if NPCTable.Bank then return "icon16/box.png" end
	if NPCTable.Auction then return "icon16/world.png" end
	if NPCTable.Quest then return "icon16/group.png" end
	if NPCTable.Shop then return "icon16/emoticon_smile.png" end
	return "icon16/exclamation.png"
end

hook.Add("RenderScene", "UD_RenderMiniMap", function()
	if IsRendering or not ConVarShowMiniMap:GetBool() or RealTime() < NextRender then return end
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	NextRender = RealTime() + RenderInterval
	RenderOrigin = ply:GetPos()

	IsRendering = true
	render.PushRenderTarget(MiniMapRT)
	render.Clear(0, 0, 0, 255, true, true)
	render.RenderView({
		origin = RenderOrigin + Vector(0, 0, CameraHeight),
		angles = Angle(90, 0, 0),
		x = 0,
		y = 0,
		w = MiniMapRT:Width(),
		h = MiniMapRT:Height(),
		drawhud = false,
		drawviewmodel = false,
		dopostprocess = false,
		drawmonitors = false,
	})
	render.PopRenderTarget()
	IsRendering = false
end)

local function DrawMapIcon(ent, IconPath)
	local Distance = RenderOrigin - ent:GetPos()
	Distance:Rotate(Angle(0, 180, 0))
	local MapY = Distance.x * (MSizeW / ((CameraHeight * 1.5) + (Distance.z * 1.5)))
	local MapX = Distance.y * (MSizeH / ((CameraHeight * 1.5) + (Distance.z * 1.5)))

	if math.abs(MapX) < (MSizeH / 2.1) and math.abs(MapY) < (MSizeW / 2.1) then
		surface.SetMaterial(GetIconMaterial(IconPath))
		surface.DrawTexturedRect((MPositionX + (MSizeW / 2) - (IconSize / 2)) - MapX, (MPositionY + (MSizeH / 2 - (IconSize / 2))) - MapY, IconSize, IconSize)
	end
end

local function DrawUDMiniMap()
	if not ConVarShowMiniMap:GetBool() or not RenderOrigin then return end

	if not MapBorder then
		MapBorder = jdraw.NewPanel()
		MapBorder:SetDimensions(MPositionX - 5, MPositionY - 5, MSizeW + 10, MSizeH + 10)
		MapBorder:SetStyle(4, Tan)
		MapBorder:SetBorder(1, DrakGray)
	end
	jdraw.DrawPanel(MapBorder)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(MiniMapMat)
	surface.DrawTexturedRect(MPositionX, MPositionY, MSizeW, MSizeH)

	for _, ent in ipairs(UD_EntCache.NPCs) do
		if IsValid(ent) and ent:IsNPC() then
			local NPCTable = NPCTable(ent:GetNWString("npc"))
			if NPCTable then DrawMapIcon(ent, GetNPCIconPath(NPCTable)) end
		end
	end
	for _, ply in ipairs(player.GetAll()) do
		DrawMapIcon(ply, "gui/player")
	end
end
hook.Add("HUDPaint", "DrawUDMiniMap", DrawUDMiniMap)
