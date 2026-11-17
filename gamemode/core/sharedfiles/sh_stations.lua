local Fabric = "models/props_c17/furniturefabric003a"
local Wood = "nayrbarr/round shield/oldwood"
local Leather = "nayrbarr/round shield/leather-dark brown"
local Drum = "models/props_c17/oildrum001.mdl"
local Plate = "models/hunter/plates/plate05x05.mdl"

local function Part(strModel, vecPosition, angAngle, vecScale, strMaterial, clrColor)
	return {Model = strModel, Position = vecPosition, Angle = angAngle or Angle(0, 0, 0), Scale = vecScale, Material = strMaterial, Color = clrColor}
end

GM.StationBuilds = {
	forge = {
		PrintName = "Forge",
		Station = "smithing",
		Model = "models/props/de_inferno/fireplace.mdl",
		Parts = {
			Part("models/props/tools/humans/firecamp01/brazier.mdl", Vector(4, 0, 0), Angle(0, 0, 0), Vector(0.8, 0.8, 0.8)),
			Part("models/nayrbarr/anvil/anvil.mdl", Vector(78, 0, 0), Angle(0, 90, 0)),
			Part("models/nayrbarr/tongs/tongs.mdl", Vector(76, -6, 24.8), Angle(0, 70, 0)),
			Part("models/nayrbarr/hammer/hammer.mdl", Vector(82, 10, 25.5), Angle(0, -40, 0)),
			Part("models/nayrbarr/iron/iron.mdl", Vector(48, 46, 0), Angle(0, 20, 0)),
			Part("models/nayrbarr/iron/iron.mdl", Vector(50, 44, 2.9), Angle(0, 35, 0)),
			Part("models/props/furnitures/humans/abreuvoirs/abreuvoir01.mdl", Vector(42, -64, 0), Angle(0, 90, 0), Vector(0.55, 0.55, 0.9)),
			Part("models/props/cs_militia/logpile2.mdl", Vector(-24, 70, 0), Angle(0, 0, 0), Vector(0.45, 0.45, 0.45)),
		},
	},
	tailoring = {
		PrintName = "Tailoring table",
		Station = "tailoring",
		Model = "models/props/furnitures/humans/table01.mdl",
		Parts = {
			Part("models/props/furnitures/humans/basket_cloth.mdl", Vector(2, -28, 33.9), Angle(0, 90, 0)),
			Part("models/items/magic/scrolls/scroll_l01_open.mdl", Vector(4, 12, 34.1), Angle(0, 80, 0), Vector(1.6, 1.6, 1.6)),
			Part(Drum, Vector(-14, 22, 37), Angle(90, 0, 0), Vector(0.22, 0.22, 0.45), Fabric, Color(150, 50, 45)),
			Part(Drum, Vector(-14, 30, 37), Angle(90, 0, 0), Vector(0.22, 0.22, 0.45), Fabric, Color(60, 80, 140)),
			Part(Drum, Vector(-14, 26, 42.5), Angle(90, 0, 0), Vector(0.22, 0.22, 0.45), Fabric, Color(190, 170, 120)),
			Part("models/props/tools/humans/training_dummy/training_dummy.mdl", Vector(10, 88, 10), Angle(0, 0, 0)),
			Part(Drum, Vector(10, 88, 38), Angle(0, 0, 0), Vector(0.62, 0.42, 0.62), Fabric, Color(150, 124, 92)),
			Part("models/props/furnitures/humans/stool02.mdl", Vector(-42, -16, 0), Angle(0, 30, 0)),
		},
	},
	leatherwork = {
		PrintName = "Leatherworking bench",
		Station = "leatherwork",
		Model = "models/props/cs_militia/wood_table.mdl",
		Parts = {
			Part(Plate, Vector(-10, 0, 30), Angle(0, 8, 0), Vector(1.1, 0.9, 0.15), Leather),
			Part("models/nayrbarr/hammer/hammer.mdl", Vector(18, 4, 30.6), Angle(0, 60, 0)),
			Part(Drum, Vector(0, 45, 0), Angle(0, 0, 0), Vector(0.09, 0.09, 1.4), Wood),
			Part(Drum, Vector(0, 95, 0), Angle(0, 0, 0), Vector(0.09, 0.09, 1.4), Wood),
			Part(Drum, Vector(0, 45, 60), Angle(90, 90, 0), Vector(0.08, 0.08, 1.1), Wood),
			Part(Drum, Vector(0, 45, 8), Angle(90, 90, 0), Vector(0.08, 0.08, 1.1), Wood),
			Part(Plate, Vector(0, 70, 34), Angle(90, 0, 0), Vector(2.1, 1.9, 0.1), Leather),
			Part("models/props/furnitures/humans/barrel_large/barrel_large.mdl", Vector(0, -72, 0), Angle(0, 0, 0), Vector(0.32, 0.32, 0.32)),
			Part("models/props/furnitures/humans/stool02.mdl", Vector(-58, 0, 0), Angle(0, -20, 0)),
		},
	},
}

GM.StationPrefix = "station:"

function GM:GetStationBuild(strModel)
	if not isstring(strModel) or string.sub(strModel, 1, #self.StationPrefix) ~= self.StationPrefix then return nil end
	return self.StationBuilds[string.sub(strModel, #self.StationPrefix + 1)], string.sub(strModel, #self.StationPrefix + 1)
end

function GM:ResolvePropModel(strModel)
	local tblBuild = self:GetStationBuild(strModel)
	return tblBuild and tblBuild.Model or strModel
end

if SERVER then
	function GM:ApplyStationBuild(entProp, strModel)
		local tblBuild, strKey = self:GetStationBuild(strModel)
		entProp:SetNWString("UD_StationBuild", tblBuild and strKey or "")
		entProp:SetNWString("UD_Station", tblBuild and tblBuild.Station or "")
	end
	return
end

local Decorated = {}

local function ClearDecor(entAnchor)
	for _, entPart in ipairs(Decorated[entAnchor] and Decorated[entAnchor].Parts or {}) do
		if IsValid(entPart) then entPart:Remove() end
	end
	Decorated[entAnchor] = nil
end

local function Decorate(entAnchor, strKey)
	ClearDecor(entAnchor)
	local tblBuild = GAMEMODE.StationBuilds[strKey]
	if not tblBuild then return end
	local tblParts = {}
	for _, Info in ipairs(tblBuild.Parts) do
		local entPart = ClientsideModel(Info.Model, RENDERGROUP_OPAQUE)
		if IsValid(entPart) then
			entPart:SetParent(entAnchor)
			entPart:SetLocalPos(Info.Position)
			entPart:SetLocalAngles(Info.Angle)
			if Info.Scale then
				local matScale = Matrix()
				matScale:Scale(Info.Scale)
				entPart:EnableMatrix("RenderMultiply", matScale)
			end
			if Info.Material then entPart:SetMaterial(Info.Material) end
			if Info.Color then entPart:SetColor(Info.Color) end
			table.insert(tblParts, entPart)
		end
	end
	Decorated[entAnchor] = {Key = strKey, Parts = tblParts}
end

function GM:RefreshStationDecor()
	for entAnchor, Info in pairs(Decorated) do
		if not IsValid(entAnchor) or entAnchor:GetNWString("UD_StationBuild", "") ~= Info.Key then ClearDecor(entAnchor) end
	end
	for _, entAnchor in ipairs(ents.GetAll()) do
		local strKey = entAnchor:GetNWString("UD_StationBuild", "")
		if strKey ~= "" and not Decorated[entAnchor] then Decorate(entAnchor, strKey) end
	end
end

timer.Create("UD_StationDecor", 1, 0, function()
	if GAMEMODE then GAMEMODE:RefreshStationDecor() end
end)
