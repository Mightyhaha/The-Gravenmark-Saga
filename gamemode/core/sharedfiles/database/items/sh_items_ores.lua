GM.OreTypes = {
	{Key = "bogiron", PrintName = "Bog Iron", ItemName = "Bog Iron Ore", Desc = "Rust-red lumps dug from marsh and riverbank. Smelts into scrap iron.", Tint = Color(160, 95, 65, 255), Band = 1},
	{Key = "iron", PrintName = "Iron", ItemName = "Iron Ore", Desc = "Grey ore streaked with rust. Smelts into iron ingots.", Tint = Color(135, 115, 105, 255), Band = 2},
	{Key = "blackiron", PrintName = "Blackiron", ItemName = "Blackiron Ore", Desc = "Dense dark ore. Smelted hot, it comes out as steel.", Tint = Color(75, 78, 88, 255), Band = 3},
	{Key = "silver", PrintName = "Silver", ItemName = "Silver Ore", Desc = "Pale veins of silver in white quartz.", Tint = Color(225, 230, 240, 255), Band = 4},
	{Key = "glass", PrintName = "Glass Crystal", ItemName = "Glass Crystal", Desc = "Green crystal that grows in the rock like ice. The smith melts it into glass ingots.", Tint = Color(110, 230, 160, 255), Band = 5},
	{Key = "ebony", PrintName = "Ebony", ItemName = "Ebony Ore", Desc = "Black ore from deep seams, heavy as lead and cold to hold.", Tint = Color(45, 40, 52, 255), Band = 6},
	{Key = "graven", PrintName = "Gravenstone", ItemName = "Gravenstone", Desc = "Violet-grey stone from the old wall's quarries. It smelts into Gravensteel.", Tint = Color(140, 115, 180, 255), Band = 7},
	{Key = "dread", PrintName = "Dreadstone", ItemName = "Dreadstone", Desc = "Red-black stone that is warm in the hand. Nobody likes to mine it.", Tint = Color(190, 50, 45, 255), Band = 8},
}

GM.OreTypesByKey = {}

for _, Ore in ipairs(GM.OreTypes) do
	Ore.Item = "mat_ore_" .. Ore.Key
	Ore.Ingot = GM.CraftMaterials.metal[Ore.Band]
	Ore.Level = math.max((Ore.Band - 1) * 20, 1)
	Ore.MiningTier = GM:GetTradeTier(Ore.Level)
	GM.OreTypesByKey[Ore.Key] = Ore

	local tblIngot = GM.DataBase.Items[Ore.Ingot]
	local Item = QuickCreateItemTable(BaseItem, Ore.Item, Ore.ItemName, Ore.Desc, "icons/junk_metalcan1")
	Item.Model = {{Model = "models/props_junk/rock001a.mdl", Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0), Color = Ore.Tint}}
	Item.Stackable = true
	Item.Weight = 0.4
	Item.SellPrice = math.max(math.Round((tblIngot and tblIngot.SellPrice or 4) * 0.35), 1)
	Item.OreBand = Ore.Band
	Register.Item(Item)
end
