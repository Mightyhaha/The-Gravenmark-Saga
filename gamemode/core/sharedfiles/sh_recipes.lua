local Player = FindMetaTable("Player")

GM.CraftingStationRange = 200

GM.CraftingStations = {
	smithing = {
		"models/nayrbarr/anvil/anvil.mdl",
		"models/props/tools/humans/firecamp01/brazier.mdl",
	},
	workbench = {
		"models/props/furnitures/humans/table01.mdl",
		"models/props/furnitures/humans/l02_tablebench.mdl",
		"models/props/cs_militia/wood_table.mdl",
		"models/props/furnitures/gob/l6_table_01/l6_table_01.mdl",
		"models/pg_props/pg_furniture/pg_captains_table.mdl",
		"models/props/cs_italy/it_mkt_table1.mdl",
		"models/props/cs_italy/it_mkt_table3.mdl",
	},
	tailoring = {},
	leatherwork = {},
}

GM.CraftingStationNames = {smithing = "an anvil or forge", workbench = "a workbench", tailoring = "a tailoring table", leatherwork = "a leatherworking bench"}

GM.GearTrades = {
	slot_primaryweapon = {"master_blacksmithing"},
	slot_helm = {"master_blacksmithing"},
	slot_shoulder = {"master_blacksmithing", "master_leatherworking"},
	slot_chest = {"master_blacksmithing", "master_tailoring"},
	slot_waist = {"master_leatherworking"},
	slot_boots = {"master_leatherworking", "master_blacksmithing"},
	slot_offhand = {"master_blacksmithing", "master_leatherworking"},
	slot_neck = {"master_blacksmithing"},
	slot_ring_1 = {"master_blacksmithing"},
}

GM.GearClassTrades = {
	bow = {"master_leatherworking"},
	crossbow = {"master_blacksmithing", "master_leatherworking"},
}

GM.GearSoftTrades = {
	slot_helm = {"master_tailoring"},
	slot_chest = {"master_tailoring"},
	slot_waist = {"master_tailoring"},
}

GM.TradeStations = {
	master_blacksmithing = "smithing",
	master_leatherworking = "leatherwork",
	master_tailoring = "tailoring",
}

function GM:GetGearTrades(tblItem)
	if not tblItem or not tblItem.Crafted or not tblItem.Slot or not self.GearTrades[tblItem.Slot] then return nil end
	local boolSoft = (tblItem.Level or 1) < 20 and self.GearSoftTrades[tblItem.Slot] ~= nil
	return self.GearClassTrades[tblItem.WeaponClass or ""] or (boolSoft and self.GearSoftTrades[tblItem.Slot]) or self.GearTrades[tblItem.Slot], boolSoft
end

function GM:GetStationOf(strModel, entStation)
	if IsValid(entStation) then
		local strTagged = entStation:GetNWString("UD_Station", "")
		if strTagged ~= "" then return strTagged end
	end
	strModel = string.lower(strModel or "")
	for strStation, tblModels in pairs(self.CraftingStations) do
		if table.HasValue(tblModels, strModel) then return strStation end
	end
end

function Player:AddRecipe(strRecipe)
	if not IsValid(self) then return false end
	self.Recipes = self.Recipes or {}
	self.Recipes[strRecipe] = true
end

function Player:HasRecipe(strRecipe)
	if not IsValid(self) then return false end
	local tblRecipeTable = RecipeTable(strRecipe)
	if not tblRecipeTable then return false end
	return not tblRecipeTable.Hidden or (self.Recipes or {})[strRecipe] == true
end

function Player:IsNearStation(strStation)
	local tblModels = GAMEMODE.CraftingStations[strStation]
	if not tblModels then return true end
	self.UD_StationCache = self.UD_StationCache or {}
	local tblCached = self.UD_StationCache[strStation]
	if tblCached and tblCached.Time > CurTime() - 0.5 then return tblCached.Near end
	local boolNear = false
	for _, entNear in ipairs(ents.FindInSphere(self:GetPos(), GAMEMODE.CraftingStationRange)) do
		if entNear:GetNWString("UD_Station", "") == strStation or table.HasValue(tblModels, string.lower(entNear:GetModel() or "")) then
			boolNear = true
			break
		end
	end
	self.UD_StationCache[strStation] = {Time = CurTime(), Near = boolNear}
	return boolNear
end

function Player:MeetsCraftRequirements(strRecipe)
	local tblRecipeTable = RecipeTable(strRecipe)
	if not IsValid(self) or not tblRecipeTable or not self:HasRecipe(strRecipe) then return false end
	for strMaster, intLevel in pairs(tblRecipeTable.RequiredMasters) do if self:GetMasterLevel(strMaster) < intLevel then return false end end
	for strItem, intAmount in pairs(tblRecipeTable.Ingredients) do if not self:HasItem(strItem, intAmount) then return false end end
	local intFreedWeight = 0
	for strItem, intAmount in pairs(tblRecipeTable.Ingredients) do intFreedWeight = intFreedWeight + ItemTable(strItem).Weight * intAmount end
	if not self:HasRoomFor(tblRecipeTable.Products, -intFreedWeight) then return false end
	if tblRecipeTable.Station and not self:IsNearStation(tblRecipeTable.Station) then return false end
	return true
end

function Player:CanMake(strRecipe)
	if CurTime() < (self.NextCraft or 0) then return false end
	return self:MeetsCraftRequirements(strRecipe)
end

if SERVER then
	function Player:CraftRecipe(strRecipe)
		if not self:CanMake(strRecipe) then return false end
		local tblRecipeTable = RecipeTable(strRecipe)
		self:Freeze(true)
		self.NextCraft = (tblRecipeTable.MakeTime or 0) + CurTime()
		if tblRecipeTable.MakeTime then
			self:CreateProgressBar(tblRecipeTable.PrintName, tblRecipeTable.MakeTime)
		end
		timer.Simple(tblRecipeTable.MakeTime or 0, function()
			if not IsValid(self) then return false end
			self:Freeze(false)
			if not self:MeetsCraftRequirements(strRecipe) then return false end
			local intChance = tblRecipeTable.Chance or 100
			local intTotalRequiredMasterLevel = 0
			local intTotalMasterLevel = 0
			for strMaster, intLevel in pairs(tblRecipeTable.RequiredMasters) do
				intTotalRequiredMasterLevel = intTotalRequiredMasterLevel + intLevel
				intTotalMasterLevel = intTotalMasterLevel + self:GetMasterLevel(strMaster)
			end
			if intTotalRequiredMasterLevel > 0 then
				intChance = math.Clamp(intChance * (intTotalMasterLevel / intTotalRequiredMasterLevel), 0, 100)
			end
			self:TakeItems(tblRecipeTable.Ingredients)
			if math.random(100) <= intChance then
				self:GiveItems(tblRecipeTable.Products)
				if tblRecipeTable.GainExp then
					for strMaster, intLevel in pairs(tblRecipeTable.RequiredMasters or {}) do
						self:AddMaster(strMaster, math.Round(tblRecipeTable.GainExp * (intLevel / self:GetMasterLevel(strMaster))), true)
					end
				end
			elseif tblRecipeTable.BadProducts then
				self:GiveItems(tblRecipeTable.BadProducts)
			end
			local fxdSparks = EffectData()
			fxdSparks:SetOrigin(self:GetPos() + Vector(0,0,70))
			util.Effect("cball_explode", fxdSparks)
			return true
		end)
	end
	concommand.Add("UD_CraftRecipe", function(ply, command, args) ply:CraftRecipe(args[1]) end)
end
