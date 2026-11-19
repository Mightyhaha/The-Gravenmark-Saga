local Shares = {
	sword = {metal = 0.85, leather = 0.15},
	axe = {metal = 0.85, leather = 0.15},
	spear = {metal = 0.8, leather = 0.2},
	hammer = {metal = 0.85, leather = 0.15},
	bow = {leather = 0.65, metal = 0.35},
	crossbow = {metal = 0.7, leather = 0.3},
	slot_helm = {metal = 0.9, cloth = 0.1},
	slot_shoulder = {metal = 0.7, leather = 0.3},
	slot_chest = {metal = 0.75, cloth = 0.25},
	slot_waist = {metal = 0.2, leather = 0.8},
	slot_boots = {leather = 0.65, metal = 0.35},
	slot_offhand = {metal = 0.7, leather = 0.3},
	slot_neck = {metal = 0.75, leather = 0.25},
	slot_ring_1 = {metal = 1},
}

local SoftShares = {
	slot_helm = {cloth = 0.8, leather = 0.2},
	slot_chest = {cloth = 0.8, leather = 0.2},
	slot_waist = {cloth = 0.75, leather = 0.25},
}

local function GroupOf(strSlot)
	if strSlot == "slot_primaryweapon" then return "Weapons" end
	if strSlot == "slot_neck" or strSlot == "slot_ring_1" then return "Jewelry" end
	return "Armor"
end

for _, Item in pairs(GM.DataBase.Items) do
	local tblTrades, boolSoft = GM:GetGearTrades(Item)
	if tblTrades then
		local intLevel = Item.Level or 1
		local tblShares = boolSoft and SoftShares[Item.Slot] or Shares[Item.WeaponClass or Item.Slot]
		local intBand = GM:GetCraftBand(intLevel)
		local intTier = GM:GetTradeTier(intLevel)

		local Recipe = {}
		Recipe.Name = "recipe_" .. Item.Name
		Recipe.PrintName = Item.PrintName
		Recipe.Group = GroupOf(Item.Slot)
		Recipe.ItemLevel = intLevel
		Recipe.Trade = tblTrades[1]
		Recipe.Station = GM.TradeStations[tblTrades[1]] or "workbench"
		Recipe.Hidden = true
		Recipe.MakeTime = 2 + intTier * 0.6
		Recipe.GainExp = 25 + 12 * intTier
		Recipe.Ingredients = {}
		local intBudget = Item.SellPrice * GM.Combat.CraftValueShare
		for strKind, flShare in pairs(tblShares) do
			local strMaterial = GM.CraftMaterials[strKind][intBand]
			local intUnit = GM.DataBase.Items[strMaterial].SellPrice
			Recipe.Ingredients[strMaterial] = math.max(math.ceil(intBudget * flShare / intUnit), 1)
		end
		Recipe.Products = {[Item.Name] = 1}
		Recipe.RequiredMasters = {}
		for _, strMaster in ipairs(tblTrades) do
			Recipe.RequiredMasters[strMaster] = intTier
		end
		Item.RecipeName = Recipe.Name
		Register.Recipe(Recipe)
	end
end
