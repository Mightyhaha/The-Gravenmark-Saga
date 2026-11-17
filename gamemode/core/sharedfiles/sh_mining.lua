local Player = FindMetaTable("Player")

GM.MiningTime = 3
GM.MiningReach = 110
GM.OreVeinRespawn = 180
GM.OreVeinSink = 0.3
GM.OreVeinModels = {
	"models/z-o-m-b-i-e/st/stone/st_stone_02.mdl",
	"models/z-o-m-b-i-e/st/stone/st_stone_03.mdl",
	"models/z-o-m-b-i-e/st/stone/st_stone_07.mdl",
	"models/z-o-m-b-i-e/st/stone/st_stone_08.mdl",
	"models/z-o-m-b-i-e/st/stone/st_stone_11.mdl",
	"models/z-o-m-b-i-e/st/stone/st_stone_13.mdl",
	"models/z-o-m-b-i-e/st/stone/st_stone_14.mdl",
	"models/z-o-m-b-i-e/st/stone/st_stone_15.mdl",
	"models/z-o-m-b-i-e/st/cover/st_cover_stone_11.mdl",
	"models/z-o-m-b-i-e/st/cover/st_cover_stone_12.mdl",
	"models/z-o-m-b-i-e/st/cover/st_cover_stone_14.mdl",
	"models/z-o-m-b-i-e/st/cover/st_cover_stone_15.mdl",
	"models/cliffs/rockcluster01.mdl",
	"models/props_wasteland/rockgranite03a.mdl",
	"models/props_wasteland/rockgranite03b.mdl",
}

function GM:GetOreType(strKey)
	return self.OreTypesByKey and self.OreTypesByKey[strKey or ""]
end

function GM:IsOreVeinModel(strModel)
	strModel = string.lower(strModel or "")
	for _, Model in ipairs(self.OreVeinModels) do
		if string.lower(Model) == strModel then return util.IsValidModel(Model) end
	end
	return false
end

function GM:DefaultOreVeinModel()
	for _, Model in ipairs(self.OreVeinModels) do
		if util.IsValidModel(Model) then return Model end
	end
	return self.OreVeinModels[#self.OreVeinModels]
end

if SERVER then
	local function MiningSound(ply)
		ply:EmitSound("physics/concrete/concrete_impact_hard" .. math.random(1, 3) .. ".wav", 70, math.random(90, 110))
	end

	function GM:DepleteOreVein(entVein)
		if not IsValid(entVein) or entVein.UD_Depleted then return end
		local Vein = self.MapEntities.OreVeins[entVein.UD_OreVeinKey or 0]
		entVein.UD_Depleted = true
		entVein:SetNoDraw(true)
		entVein:SetNotSolid(true)
		timer.Simple(Vein and Vein.SpawnTime or self.OreVeinRespawn, function()
			if not IsValid(entVein) then return end
			entVein.UD_Depleted = nil
			entVein:SetNoDraw(false)
			entVein:SetNotSolid(false)
		end)
	end

	function Player:MineVein(entVein)
		if not IsValid(entVein) or not entVein.UD_OreVeinKey or entVein.UD_Depleted then return false end
		if self.UD_Mining or not self:Alive() then return false end
		if entVein:GetPos():DistToSqr(self:GetPos()) > (GAMEMODE.MiningReach + entVein:BoundingRadius()) ^ 2 then return false end
		local Ore = GAMEMODE:GetOreType(entVein:GetNWString("UD_Ore"))
		if not Ore then return false end
		if self:GetMasterLevel("master_mining") < Ore.MiningTier then
			self:ChatPrint("You need Mining tier " .. Ore.MiningTier .. " to mine " .. Ore.PrintName .. ".")
			return false
		end
		if not self:HasRoomFor({[Ore.Item] = 3}) then
			self:ChatPrint("You are carrying too much to mine.")
			return false
		end

		self.UD_Mining = true
		self:Freeze(true)
		self:CreateProgressBar("Mining " .. Ore.PrintName, GAMEMODE.MiningTime)
		MiningSound(self)
		timer.Create("UD_MiningSound_" .. self:EntIndex(), 0.75, math.floor(GAMEMODE.MiningTime / 0.75) - 1, function()
			if IsValid(self) then MiningSound(self) end
		end)
		timer.Simple(GAMEMODE.MiningTime, function()
			if not IsValid(self) then return end
			self.UD_Mining = nil
			self:Freeze(false)
			if not self:Alive() or not IsValid(entVein) or entVein.UD_Depleted then return end
			local intAmount = math.random(2, 3)
			if math.random(100) <= math.min(self:GetStat("stat_luck") or 0, 50) then intAmount = intAmount + 1 end
			self:AddItem(Ore.Item, intAmount)
			self:CreateIndicator("+" .. intAmount .. "_" .. string.gsub(Ore.ItemName, " ", "_"), entVein:GetPos() + Vector(0, 0, 30), "green")
			local intTier = math.max(self:GetMasterLevel("master_mining"), 1)
			self:AddMaster("master_mining", math.max(math.Round((20 + 10 * Ore.MiningTier) * Ore.MiningTier / intTier), 1), true)
			GAMEMODE:DepleteOreVein(entVein)
		end)
		return true
	end
else
	local ColorOk = Color(120, 210, 90, 255)
	local ColorBad = Color(235, 90, 70, 255)
	local ColorShadow = Color(0, 0, 0, 255)

	hook.Add("HUDPaint", "UD_OreVeinLabel", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		local entVein = ply:GetEyeTrace().Entity
		if not IsValid(entVein) or entVein:GetNoDraw() then return end
		local Ore = GAMEMODE:GetOreType(entVein:GetNWString("UD_Ore", ""))
		if not Ore then return end
		if entVein:GetPos():DistToSqr(ply:GetPos()) > 400 ^ 2 then return end
		local Screen = (entVein:GetPos() + Vector(0, 0, 36)):ToScreen()
		if not Screen.visible then return end
		local boolCan = ply:GetMasterLevel("master_mining") >= Ore.MiningTier
		local clrName = Color(math.max(Ore.Tint.r, 150), math.max(Ore.Tint.g, 150), math.max(Ore.Tint.b, 150), 255)
		draw.SimpleTextOutlined(Ore.PrintName .. " vein", "UiBold", Screen.x, Screen.y, clrName, 1, 1, 1, ColorShadow)
		draw.SimpleTextOutlined(boolCan and "Press E to mine" or ("Needs Mining tier " .. Ore.MiningTier), "UiBold", Screen.x, Screen.y + 14, boolCan and ColorOk or ColorBad, 1, 1, 1, ColorShadow)
	end)
end
