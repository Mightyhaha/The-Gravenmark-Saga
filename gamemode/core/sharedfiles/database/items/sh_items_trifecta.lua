local Item = DeriveTable(BaseItem)
Item.Name = "trifecta_supplycrate"
Item.PrintName = "Kaelmoor Supply Bundle"
Item.Desc = "Supplies smuggled out of Kaelmoor's levy wagons, seized by a Morvaine patrol."
Item.Icon = "icons/junk_box1"
Item.Model = "models/props_junk/cardboard_box004a.mdl"
Item.QuestItem = "quest_trifecta_quietgift"
Item.Dropable = true
Item.Giveable = false
Item.Weight = 1
Register.Item(Item)
