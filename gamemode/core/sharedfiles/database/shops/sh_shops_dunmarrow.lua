local Shop = {}
Shop.Name = "shop_dunmarrow_quartermaster"
Shop.PrintName = "Dunmarrow Quartermaster"
Shop.Inventory = {}
for strName, Item in pairs(GM.DataBase.Items) do
	local boolGear = Item.Crafted and (Item.Level or 1) <= 20 and Item.Slot ~= "slot_ring_1"
	if boolGear or (Item.CraftMaterial and Item.CraftBand == 1) then Shop.Inventory[strName] = {} end
end
Shop.Inventory["item_healthkit"] = {}
Shop.Inventory["item_canspoilingmeat"] = {}
Register.Shop(Shop)
