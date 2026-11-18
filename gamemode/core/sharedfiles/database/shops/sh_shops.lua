local Shop = {}
Shop.Name = "shop_general"
Shop.PrintName = "General Store"
Shop.Inventory = {}
Shop.Inventory["item_canspoilingmeat"] = {}
Shop.Inventory["item_orange"] = {}
Shop.Inventory["item_banannabunch"] = {}
Shop.Inventory["item_bananna"] = {}
Shop.Inventory["item_healthkit"] = {}
Shop.Inventory["item_arrows"] = {}
Shop.Inventory["item_bolts"] = {}
Shop.Inventory["item_pumpkin"] = {}
Shop.Inventory["item_coffee"] = {}
Shop.Inventory["item_milk"] = {}
Shop.Inventory["item_milk_small"] = {}
Shop.Inventory["item_beer"] = {}
Shop.Inventory["item_vodka"] = {}
Shop.Inventory["item_leftovers"] = {}
Shop.Inventory["item_melon"] = {}
Shop.Inventory["item_firestarting_kit"] = {}
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_books"
Shop.PrintName = "Book Store"
Shop.Inventory = {}
Shop.Inventory["book_of_beginning"] = {}
Shop.Inventory["book_polkmstail_ep1"] = {}
for _, strScroll in ipairs(GM.RecipeScrolls or {}) do
	if GM.DataBase.Items[strScroll].RecipeStarter then Shop.Inventory[strScroll] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_scribe"
Shop.PrintName = "Scribe's Satchel"
Shop.Inventory = {}
for _, strScroll in ipairs(GM.RecipeScrolls or {}) do
	if GM.DataBase.Items[strScroll].RecipeStarter then Shop.Inventory[strScroll] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_armor"
Shop.PrintName = "Armor Store"
Shop.Inventory = {}
for strName, Item in pairs(GM.DataBase.Items) do
	if Item.Crafted and Item.Slot and Item.Slot ~= "slot_primaryweapon" and Item.Slot ~= "slot_ring_1" and (Item.Level or 1) <= GM.Combat.ShopGearMaxLevel then Shop.Inventory[strName] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_melee"
Shop.PrintName = "Blacksmith"
Shop.Inventory = {}
for strName, Item in pairs(GM.DataBase.Items) do
	if Item.Crafted and Item.Slot == "slot_primaryweapon" and Item.Melee and (Item.Level or 1) <= GM.Combat.ShopGearMaxLevel then Shop.Inventory[strName] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_craftsupplies"
Shop.PrintName = "Smith's Supplies"
Shop.Inventory = {}
for strName, Item in pairs(GM.DataBase.Items) do
	if Item.CraftMaterial and Item.CraftBand <= GM.Combat.ShopMaterialMaxBand then Shop.Inventory[strName] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_ranged"
Shop.PrintName = "Bowyer and Fletcher"
Shop.Inventory = {}
Shop.Inventory["item_arrows"] = {}
Shop.Inventory["item_bolts"] = {}
for strName, Item in pairs(GM.DataBase.Items) do
	if Item.Crafted and Item.Slot == "slot_primaryweapon" and not Item.Melee and (Item.Level or 1) <= GM.Combat.ShopGearMaxLevel then Shop.Inventory[strName] = {} end
end
Register.Shop(Shop)
