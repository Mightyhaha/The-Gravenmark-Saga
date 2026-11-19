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

Register.Item(QuestItem("ud_grave_token", "Grave-Token", "A lead token pressed with a family mark. The dead of the barrow field were buried with them, and the risen ones still carry them.", "icons/junk_cog", "models/props_junk/rock001a.mdl", "quest_barrow_tokens"))
Register.Item(QuestItem("ud_ledger_page", "Necromancer's Ledger Page", "A page of names, dates and burial places in a cramped hand. Some names are crossed out. Those graves are empty.", "icons/item_book2", "models/items/magic/scrolls/scroll_rolled.mdl", "quest_barrow_ledger"))

local tblBase = GM.DataBase.Items["weapon_melee_gravensteel_spear"]
if tblBase then
	local Item = GM:MakeRarityItem(tblBase, "unique_gravecaller", "Gravecaller", "epic")
	Item.Level = 125
	Item.Unique = true
	Item.QuestReward = true
	Item.Model = table.Copy(tblBase.Model)
	Item.Model[1].Color = Color(95, 120, 95, 255)
	Item.Effects = {{Type = "glow", Color = Color(60, 200, 90), Size = 0.7, Amount = 0.8, Pulse = 0.5}, {Type = "smoke", Color = Color(40, 70, 45), Size = 0.6, Amount = 0.4, Pulse = 1}}
	GM:AddRarityStats(Item, {stat_strength = 0.5, stat_maxhealth = 0.5}, GM.Rarities.epic.Budget * GM.RarityTuning.PowerStatShare)
	Item.Desc = "The Necromancer's staff, a long black haft shod with Gravensteel. It is cold to hold and colder to be struck by."
	Item.Lore = "Every name it called answered. Yours was next."
	Item.Hooks = {on_kill = function(ply, Rank, entNPC)
		if SERVER and ply:Alive() then
			local intMax = ply:GetStat("stat_maxhealth")
			ply:SetHealth(math.min(ply:Health() + math.max(math.Round(intMax * 0.08), 1), intMax))
		end
		return entNPC
	end}
	Item.PowerDesc = "Each kill drains 8% of your health back from the dead."
	Register.Item(Item)
end
