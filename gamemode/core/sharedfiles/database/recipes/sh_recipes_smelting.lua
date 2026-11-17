local Batches = {
	{Suffix = "", Ore = 2, Ingots = 1, Time = 2, Label = ""},
	{Suffix = "_batch", Ore = 10, Ingots = 5, Time = 7, Label = " (x5)"},
}

for _, Ore in ipairs(GM.OreTypes) do
	local tblIngot = GM.DataBase.Items[Ore.Ingot]
	if tblIngot then
		for _, Batch in ipairs(Batches) do
			local Recipe = {}
			Recipe.Name = "recipe_smelt_" .. Ore.Key .. Batch.Suffix
			Recipe.PrintName = "Smelt " .. tblIngot.PrintName .. Batch.Label
			Recipe.Group = "Smelting"
			Recipe.ItemLevel = Ore.Level
			Recipe.Trade = "master_blacksmithing"
			Recipe.Station = "smithing"
			Recipe.MakeTime = Batch.Time
			Recipe.GainExp = (8 + 3 * Ore.MiningTier) * Batch.Ingots
			Recipe.Ingredients = {[Ore.Item] = Batch.Ore}
			Recipe.Products = {[Ore.Ingot] = Batch.Ingots}
			Recipe.RequiredMasters = {master_blacksmithing = Ore.MiningTier}
			Register.Recipe(Recipe)
		end
	end
end
