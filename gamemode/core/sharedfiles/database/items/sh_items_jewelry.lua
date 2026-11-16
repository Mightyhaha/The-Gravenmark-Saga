local function AddStats(AddTable, Slot)
	AddTable.Slot = Slot
	AddTable.Armor = 0
	AddTable.Buffs = {}
	return AddTable
end
local function AddRing(AddTable)
	AddTable = AddStats(AddTable, "slot_ring_1")
	AddTable.SlotGroup = "ring"
	return AddTable
end
local function AddBuff(AddTable, Buff, Amount)
	AddTable.Buffs[Buff] = Amount
	return AddTable
end

local RingLevels = {15, 35, 55, 75, 95, 115, 135}
local NeckLevels = {30, 50, 70, 90, 110, 130, 150}
local Metals = {"Iron", "Iron", "Steel", "Silver", "Glass", "Ebony", "Gravensteel", "Dreadforged"}

local function RingMetal(intLevel)
	return Metals[GM:GetCraftBand(intLevel)]
end

local function JewelPrice(intLevel, flFactor)
	return GM:GetGearPrice(intLevel, flFactor)
end

local RingFamilies = {
	{Key = "strength", Name = "Might", Desc = "Heavy and plain. It makes the sword arm sure.", Icon = "icons/junk_sawblade", Stat = "stat_strength", Amount = function(intLevel) return math.max(math.Round(intLevel / 45), 1) end},
	{Key = "dexterity", Name = "Finesse", Desc = "Thin and bright. It steadies the aim.", Icon = "icons/junk_sawblade", Stat = "stat_dexterity", Amount = function(intLevel) return math.max(math.Round(intLevel / 45), 1) end},
	{Key = "vigor", Name = "Vigor", Desc = "Warm to the touch. Wounds seem to close a little faster.", Icon = "icons/junk_sawblade", Stat = "stat_maxhealth", Amount = function(intLevel) return math.max(math.Round(intLevel * 0.35), 1) end},
	{Key = "fortune", Name = "Fortune", Desc = "Engraved with a crooked coin. Things tend to go your way.", Icon = "icons/junk_sawblade", Stat = "stat_luck", Amount = function(intLevel) return math.max(math.Round(intLevel / 8), 1) end},
}

local NeckFamilies = {
	{Key = "pendant", Name = "Pendant", Desc = "A pendant on a leather cord. It sits warm against the chest.", Icon = "icons/junk_cog", Stat = "stat_maxhealth", Amount = function(intLevel) return math.max(math.Round(intLevel * 0.7), 1) end},
	{Key = "talisman", Name = "Talisman", Desc = "A small charm of luck, worn under the collar.", Icon = "icons/junk_cog", Stat = "stat_luck", Amount = function(intLevel) return math.max(math.Round(intLevel / 6), 1) end},
}

for _, Family in ipairs(RingFamilies) do
	for intTier, intLevel in ipairs(RingLevels) do
		local strId = intTier == 1 and ("ring_" .. Family.Key) or ("ring_" .. Family.Key .. "_" .. intTier)
		local strName = intTier == 1 and ("Band of " .. Family.Name) or (RingMetal(intLevel) .. " Band of " .. Family.Name)
		local Item = QuickCreateItemTable(BaseArmor, strId, strName, Family.Desc, Family.Icon)
		Item = AddRing(Item)
		Item = AddBuff(Item, Family.Stat, Family.Amount(intLevel))
		Item.Level = intLevel
		Item.Weight = 0.1
		Item.SellPrice = JewelPrice(intLevel, 0.5)
		Item.Crafted = true
		Register.Item(Item)
	end
end

for _, Family in ipairs(NeckFamilies) do
	for intTier, intLevel in ipairs(NeckLevels) do
		local strId = (intTier == 1 and Family.Key == "pendant") and "neck_iron_pendant" or ("neck_" .. Family.Key .. "_" .. intTier)
		local strName = RingMetal(intLevel) .. " " .. Family.Name
		local Item = QuickCreateItemTable(BaseArmor, strId, strName, Family.Desc, Family.Icon)
		Item = AddStats(Item, "slot_neck")
		Item = AddBuff(Item, Family.Stat, Family.Amount(intLevel))
		Item.Level = intLevel
		Item.Weight = 0.1
		Item.SellPrice = JewelPrice(intLevel, 0.6)
		Item.Crafted = true
		Register.Item(Item)
	end
end

local RewardRings = {
	{45, "ring_reward_oath", "Dunmarrow Oathring", "Worn by the levy captains who swore to Ulric before the first banner was raised.", "stat_strength", 2, "stat_maxhealth", 30},
	{65, "ring_reward_smuggler", "Kaelmoor Smuggler's Signet", "A signet that opens doors in Kaelmoor that officially do not exist.", "stat_luck", 14, "stat_strength", 2},
	{85, "ring_reward_council", "Council Seal Ring", "A ring cut for the Threefold Council's first sitting. Three seats, and no throne.", "stat_maxhealth", 55, "stat_luck", 10},
	{105, "ring_reward_wardenband", "Gravenmark Wardenband", "Taken from a warden of the wall. The wall remembers who wore it.", "stat_strength", 4, "stat_maxhealth", 60},
	{125, "ring_reward_ashenvow", "Ashen Vow", "Ash-grey and warm. Whoever made the vow it holds is long dead.", "stat_luck", 24, "stat_strength", 4},
	{145, "ring_reward_valcrest", "Valcrest Signet", "The seal of a house that ruled a continent and lost a crown.", "stat_strength", 5, "stat_maxhealth", 90},
}

for _, Reward in ipairs(RewardRings) do
	local Item = QuickCreateItemTable(BaseArmor, Reward[2], Reward[3], Reward[4], "icons/junk_sawblade")
	Item = AddRing(Item)
	Item = AddBuff(Item, Reward[5], Reward[6])
	Item = AddBuff(Item, Reward[7], Reward[8])
	Item.Level = Reward[1]
	Item.Weight = 0.1
	Item.SellPrice = JewelPrice(Reward[1], 0.9)
	Item.QuestReward = true
	Register.Item(Item)
end
