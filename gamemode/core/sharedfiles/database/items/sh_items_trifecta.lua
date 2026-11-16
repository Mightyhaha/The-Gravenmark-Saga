local function QuestItem(Name, PrintName, Desc, Icon, Model, Quest)
	local Item = DeriveTable(BaseItem)
	Item.Name = Name
	Item.PrintName = PrintName
	Item.Desc = Desc
	Item.Icon = Icon
	Item.Model = Model
	Item.QuestItem = Quest
	Item.Stackable = true
	Item.Dropable = true
	Item.Giveable = false
	Item.Weight = 1
	return Item
end

local Purse = "models/items/jewels/purses/very_big_purse.mdl"
local Scroll = "models/items/magic/scrolls/scroll_rolled.mdl"
local Crate = "models/props_junk/cardboard_box004a.mdl"

local Item = QuestItem("trifecta_supplycrate", "Kaelmoor Supply Bundle", "Supplies smuggled out of Kaelmoor's levy wagons, seized by a Morvaine patrol.", "icons/junk_box1", Crate, "quest_trifecta_quietgift")
Register.Item(Item)

local Item = QuestItem("dm_morvaine_rations", "Morvaine Marching Rations", "Salt pork and hard bread wrapped in a red cloth. Morvaine feeds its levies well.", "icons/junk_box1", "models/props_junk/garbage_bag001a.mdl", "quest_dm_rations")
Register.Item(Item)

local Item = QuestItem("dm_levy_cache", "Dunmarrow Levy Cache", "A bundle of flints, arrowheads and coin, hidden by the old levy before Morvaine came.", "icons/junk_box1", Crate, "quest_dm_caches")
Item.FoundBySearching = true
Register.Item(Item)

local Item = QuestItem("dm_stolen_purse", "Stolen Coin Purse", "A purse of copper and a few Morvaine crowns, taken from travellers on the forest roads.", "icons/item_cash", Purse, "quest_dm_coinpurses")
Register.Item(Item)

local Item = QuestItem("dm_sealed_letter", "Varne's Sealed Letter", "A letter for Lord Ulric, sealed with the Dunmarrow levy's wax. Sergeant Varne told you not to read it.", "icons/item_book1", Scroll, "quest_dm_sealedletter")
Item.Dropable = false
Item.Weight = 0
Register.Item(Item)

local Item = QuestItem("dm_seized_cargo", "Seized Kaelmoor Cargo", "One of Maren Holt's crates, taken by Morvaine outriders on the north road. It is nailed shut.", "icons/junk_box1", Crate, "quest_maren_wagons")
Register.Item(Item)

local Item = QuestItem("dm_ashbeads", "String of Ash-Beads", "Grey prayer beads of the Ashen Creed, Ossmere's faith, taken from a Gallows Company sellsword.", "icons/junk_cog", "models/props_junk/rock001a.mdl", "quest_ulric_ashbeads")
Register.Item(Item)

local Item = QuestItem("dm_company_toll", "Gallows Toll-Silver", "A silver coin with a gallows stamped over the old face. The Gallows Company charges it on every road it holds.", "icons/item_cash", Purse, "quest_maren_tolls")
Register.Item(Item)

local Item = QuestItem("dm_morvaine_banner", "Torn Morvaine Banner", "A red banner of Morvaine, cut from a knight's lance. Lord Grell collects them.", "icons/item_book3", Scroll, "quest_halvard_proof")
Register.Item(Item)

local Item = QuestItem("dm_marshal_seal", "Seal of the Crossing", "The Lord-Marshal's seal of command over the river crossing, still on its broken chain.", "icons/junk_cog", "models/props_c17/clock01.mdl", "quest_halvard_seal")
Register.Item(Item)

local Item = QuestItem("dm_council_writ", "Writ of the Threefold Council", "Lord Ulric's writ naming the day and place of the Threefold Council's first sitting. Three seats, and no throne.", "icons/item_book2", Scroll, "quest_ulric_writ")
Item.Dropable = false
Item.Weight = 0
Register.Item(Item)
