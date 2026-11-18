GM.RecipeScrolls = {}
GM.RecipeFolios = {}

GM.RecipeDrops = {
	Chance = 1.5,
	EliteChance = 12,
	EliteFolioShare = 0.4,
	LuckDivisor = 45,
	LevelBelow = 15,
	LevelAbove = 3,
	StarterMaxLevel = 12,
	StarterPriceShare = 0.15,
	ScrollPriceShare = 0.3,
	FolioPriceShare = 0.6,
	FactionTrades = {
		combine = {master_blacksmithing = 2},
		bandit = {master_leatherworking = 2, master_tailoring = 2},
	},
}

local ScrollModel = "models/items/magic/scrolls/scroll_rolled.mdl"
local FolioModel = "models/props_lab/bindergreenlabel.mdl"

local function ScrollTitle(tblItem, strTrade)
	if tblItem.WeaponClass == "bow" or tblItem.WeaponClass == "crossbow" then return "Bowyer's Notes" end
	if strTrade == "master_leatherworking" then return "Tanner's Pattern" end
	if strTrade == "master_tailoring" then return "Tailor's Pattern" end
	if tblItem.Slot == "slot_neck" or tblItem.Slot == "slot_ring_1" then return "Jeweller's Sketch" end
	return "Smith's Notes"
end

local TradeWords = {
	master_blacksmithing = {"forge", "hammer", "temper"},
	master_leatherworking = {"cut", "stitch", "oil"},
	master_tailoring = {"cut", "pad", "sew"},
}

local TradeNames = {master_blacksmithing = "Blacksmithing", master_leatherworking = "Leatherworking", master_tailoring = "Tailoring"}

local function ScrollStory(tblItem, strTrade, intTier)
	local tblWords = TradeWords[strTrade] or TradeWords.master_blacksmithing
	local strTradeName = TradeNames[strTrade] or strTrade
	local strStation = GM.CraftingStationNames[GM.TradeStations[strTrade] or ""] or "the right station"
	return "How to " .. tblWords[1] .. ", " .. tblWords[2] .. " and " .. tblWords[3] .. " a " .. tblItem.PrintName .. ", written in a cramped and impatient hand. /n /n Needs " .. strTradeName .. " tier " .. intTier .. " and " .. strStation .. ". Read it to learn the recipe for good."
end

local function LearnUse(self, ply, tblItem)
	if not IsValid(ply) or ply:Health() <= 0 then return end
	local tblUnknown = {}
	for _, strRecipe in ipairs(tblItem.GainRecipes or {}) do
		if not (ply.Recipes or {})[strRecipe] then table.insert(tblUnknown, strRecipe) end
	end
	if ply:HasReadBook(tblItem.Name) or #tblUnknown == 0 then
		ply:CreateNotification("You already know " .. (#(tblItem.GainRecipes or {}) > 1 and "everything in this folio" or "this recipe") .. ". Sell it or give it to a friend.")
		return
	end
	ply:AddBookToLibrary(tblItem.Name)
	ply:AddItem(tblItem.Name, -1)
	ply:EmitSound("physics/cardboard/cardboard_box_impact_soft" .. math.random(1, 7) .. ".wav", 60)
	if #tblUnknown > 1 then
		ply:CreateNotification("You learned " .. #tblUnknown .. " new recipes")
	else
		local tblRecipe = RecipeTable and RecipeTable(tblUnknown[1])
		ply:CreateNotification("You learned to craft " .. (tblRecipe and tblRecipe.PrintName or tblItem.TeachesName or "something new"))
	end
end

local tblCrafted = {}
for strName, tblItem in pairs(GM.DataBase.Items) do
	if GM:GetGearTrades(tblItem) then table.insert(tblCrafted, strName) end
end
table.sort(tblCrafted)

local tblSets = {}
for _, strName in ipairs(tblCrafted) do
	local tblItem = GM.DataBase.Items[strName]
	local tblTrades = GM:GetGearTrades(tblItem)
	local strTrade = tblTrades[1]
	local intLevel = tblItem.Level or 1
	local intTier = GM:GetTradeTier(intLevel)
	local strTitle = ScrollTitle(tblItem, strTrade)

	local Item = QuickCreateItemTable(BaseBook, "recipe_scroll_" .. strName, strTitle .. ": " .. tblItem.PrintName, "Teaches the recipe for " .. tblItem.PrintName .. " (level " .. intLevel .. "). Use it to learn it for good.", "icons/item_book2")
	Item.Model = ScrollModel
	Item.Stackable = true
	Item.Weight = 0.1
	Item.Story = ScrollStory(tblItem, strTrade, intTier)
	Item.SaveInLibrary = true
	Item.GainRecipes = {"recipe_" .. strName}
	Item.TeachesItem = strName
	Item.TeachesName = tblItem.PrintName
	Item.RecipeTrade = strTrade
	Item.RecipeLevel = intLevel
	Item.RecipeStarter = intLevel <= GM.RecipeDrops.StarterMaxLevel
	Item.SellPrice = math.max(math.Round((tblItem.SellPrice or 1) * (Item.RecipeStarter and GM.RecipeDrops.StarterPriceShare or GM.RecipeDrops.ScrollPriceShare)), 2)
	Item.Use = LearnUse
	Register.Item(Item)
	table.insert(GM.RecipeScrolls, Item.Name)

	if tblItem.Set then
		tblSets[tblItem.Set] = tblSets[tblItem.Set] or {Items = {}, Level = intLevel, Value = 0}
		table.insert(tblSets[tblItem.Set].Items, strName)
		tblSets[tblItem.Set].Level = math.min(tblSets[tblItem.Set].Level, intLevel)
		tblSets[tblItem.Set].Value = tblSets[tblItem.Set].Value + (tblItem.SellPrice or 0)
	end
end

for strSet, Info in SortedPairs(tblSets) do
	if #Info.Items >= 2 then
		local tblSet = GM.DataBase.EquipmentSets and GM.DataBase.EquipmentSets[strSet]
		local strSetName = tblSet and tblSet.PrintName or strSet
		local Item = QuickCreateItemTable(BaseBook, "recipe_folio_" .. strSet, "Folio: " .. strSetName, "A bound folio of patterns for every piece of " .. strSetName .. ". Use it to learn them all.", "icons/item_book1")
		Item.Model = FolioModel
		Item.Weight = 0.5
		Item.Story = "A master's folio, the pages stitched into oiled leather. Every piece of " .. strSetName .. " is drawn here from three sides, with the measurements in the margins. /n /n Read it to learn all " .. #Info.Items .. " recipes for good."
		Item.SaveInLibrary = true
		Item.GainRecipes = {}
		for _, strName in ipairs(Info.Items) do table.insert(Item.GainRecipes, "recipe_" .. strName) end
		Item.RecipeLevel = Info.Level
		Item.SellPrice = math.max(math.Round(Info.Value * GM.RecipeDrops.FolioPriceShare / #Info.Items), 5)
		Item.Use = LearnUse
		Register.Item(Item)
		table.insert(GM.RecipeFolios, Item.Name)
	end
end

if CLIENT then return end

local function PickWeighted(tblCandidates)
	local flTotal = 0
	for _, Candidate in ipairs(tblCandidates) do flTotal = flTotal + Candidate.Weight end
	local flRoll = math.Rand(0, flTotal)
	for _, Candidate in ipairs(tblCandidates) do
		if flRoll <= Candidate.Weight then return Candidate.Name end
		flRoll = flRoll - Candidate.Weight
	end
	return tblCandidates[#tblCandidates] and tblCandidates[#tblCandidates].Name
end

local function KnowsAll(ply, tblItem)
	for _, strRecipe in ipairs(tblItem.GainRecipes or {}) do
		if not (ply.Recipes or {})[strRecipe] then return false end
	end
	return true
end

function GM:PickRecipeDrop(intLevel, ply, strRace, boolFolio)
	local Drops = self.RecipeDrops
	local tblFaction = Drops.FactionTrades[strRace or ""] or {}
	local tblFresh, tblAll = {}, {}
	for _, strName in ipairs(boolFolio and self.RecipeFolios or self.RecipeScrolls) do
		local tblItem = ItemTable(strName)
		local intItemLevel = tblItem.RecipeLevel or 1
		if intItemLevel >= intLevel - Drops.LevelBelow and intItemLevel <= intLevel + Drops.LevelAbove then
			local Candidate = {Name = strName, Weight = tblFaction[tblItem.RecipeTrade or ""] or 1}
			table.insert(tblAll, Candidate)
			if not IsValid(ply) or not KnowsAll(ply, tblItem) then table.insert(tblFresh, Candidate) end
		end
	end
	if #tblFresh > 0 then return PickWeighted(tblFresh) end
	if #tblAll > 0 then return PickWeighted(tblAll) end
end

function GM:RollRecipeDrop(entNPC, ply, tblNPCTable)
	if not tblNPCTable or tblNPCTable.NoRecipeDrops or not IsValid(ply) then return nil end
	local Drops = self.RecipeDrops
	local boolElite = tblNPCTable.EliteLoot ~= nil
	local flChance = (boolElite and Drops.EliteChance or Drops.Chance) * (1 + (ply:GetStat("stat_luck") or 0) / Drops.LuckDivisor)
	if math.Rand(0, 100) > flChance then return nil end
	local intLevel = entNPC:GetLevel()
	local strRace = tblNPCTable.Race
	if boolElite and math.random() < Drops.EliteFolioShare then
		local strFolio = self:PickRecipeDrop(intLevel, ply, strRace, true)
		if strFolio then return strFolio end
	end
	return self:PickRecipeDrop(intLevel, ply, strRace, false)
end
