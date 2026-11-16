local Shop = {}
Shop.Name = "shop_general"
Shop.PrintName = "General Store"
Shop.Inventory = {}
Shop.Inventory["item_canspoilingmeat"] = {}
Shop.Inventory["item_orange"] = {}
Shop.Inventory["item_antivirus"] = {}
Shop.Inventory["item_banannabunch"] = {}
Shop.Inventory["item_bananna"] = {}
Shop.Inventory["item_healthkit"] = {}
Shop.Inventory["item_smallammo_small"] = {}
Shop.Inventory["item_rifleammo_small"] = {}
Shop.Inventory["item_buckshotammo_small"] = {}
Shop.Inventory["item_sniperammo_small"] = {}
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
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_armor"
Shop.PrintName = "Armor Store"
Shop.Inventory = {}
for strName, Item in pairs(GM.DataBase.Items) do
	if Item.Crafted and Item.Slot and Item.Slot ~= "slot_primaryweapon" and Item.Slot ~= "slot_ring_1" then Shop.Inventory[strName] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_melee"
Shop.PrintName = "Blacksmith"
Shop.Inventory = {}
for strName, Item in pairs(GM.DataBase.Items) do
	if Item.Crafted and Item.Slot == "slot_primaryweapon" then Shop.Inventory[strName] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_craftsupplies"
Shop.PrintName = "Smith's Supplies"
Shop.Inventory = {}
for strName, Item in pairs(GM.DataBase.Items) do
	if Item.CraftMaterial then Shop.Inventory[strName] = {} end
end
Register.Shop(Shop)

local Shop = {}
Shop.Name = "shop_ranged"
Shop.PrintName = "Arms Store"
Shop.Inventory = {}
--[[Shop.Inventory["weapon_ranged_plasma"] = {}
Shop.Inventory["weapon_ranged_tesla"] = {}
Shop.Inventory["weapon_ranged_chaingun"] = {}]]
Shop.Inventory["weapon_ranged_junkpistol"] = {}
Shop.Inventory["weapon_ranged_junksmg"] = {}
Shop.Inventory["weapon_ranged_junkrifle"] = {}
Shop.Inventory["weapon_ranged_heavymacgun"] = {}
Shop.Inventory["weapon_ranged_drumshotgun"] = {}
Shop.Inventory["weapon_ranged_revolver"] = {}
Shop.Inventory["weapon_ranged_wornasr"] = {}
Shop.Inventory["weapon_ranged_combine_cannon"] = {}
Shop.Inventory["weapon_ranged_battlerifle"] = {}
Shop.Inventory["weapon_ranged_combinesniper"] = {}
Register.Shop(Shop)
