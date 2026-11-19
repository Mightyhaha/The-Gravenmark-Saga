
local VariantSlots = {
	slot_primaryweapon = true,
	slot_offhand = true,
	slot_helm = true,
	slot_chest = true,
	slot_shoulder = true,
	slot_waist = true,
	slot_boots = true,
}

local function ItemKind(tblItem)
	if tblItem.Slot == "slot_primaryweapon" then return tblItem.Melee and "melee" or "ranged" end
	return "armor"
end

function GM:MakeRarityItem(tblBase, strName, strPrintName, strRarity)
	local tblRarity = self.Rarities[strRarity]
	local Item = DeriveTable(tblBase)
	Item.Name = strName
	Item.PrintName = strPrintName
	Item.BaseItem = tblBase.BaseItem or tblBase.Name
	Item.Generated = true
	Item.Crafted = nil
	Item.Rarity = strRarity
	if Item.Power then Item.Power = math.max(math.Round(Item.Power * tblRarity.PowerMult), 1) end
	if Item.Armor and Item.Armor > 0 then Item.Armor = math.max(math.Round(Item.Armor * tblRarity.PowerMult), 1) end
	Item.SellPrice = math.max(math.Round((tblBase.SellPrice or 0) * tblRarity.SellShare), 1)
	Item.Buffs = table.Copy(tblBase.Buffs or {})
	return Item
end

function GM:AddRarityStats(Item, tblStats, flBudget)
	local intLevel = math.max(Item.Level or 1, self.SlotUnlockLevel[Item.Slot] or 1)
	for strStat, flShare in pairs(tblStats or {}) do
		Item.Buffs[strStat] = (Item.Buffs[strStat] or 0) + self:GetAffixStat(strStat, intLevel, flBudget * flShare)
	end
end

local function RegisterLoot(Item)
	GM.LootPool[Item.Rarity] = GM.LootPool[Item.Rarity] or {}
	table.insert(GM.LootPool[Item.Rarity], Item.Name)
	Register.Item(Item)
end

GM.LootPool = {}

local tblBases = {}
for strName, tblItem in pairs(GM.DataBase.Items) do
	if tblItem.Crafted and not tblItem.Generated and VariantSlots[tblItem.Slot] then table.insert(tblBases, strName) end
end
table.sort(tblBases)

for _, strBase in ipairs(tblBases) do
	local tblBase = GM.DataBase.Items[strBase]
	local strKind = ItemKind(tblBase)
	for _, tblSuffix in ipairs(GM.LootSuffixes) do
		if tblSuffix.For[strKind] then
			local Item = GM:MakeRarityItem(tblBase, strBase .. "_" .. tblSuffix.Key, tblBase.PrintName .. " " .. tblSuffix.Suffix, tblSuffix.Rarity)
			local flBudget = GM.Rarities[tblSuffix.Rarity].Budget
			if tblSuffix.Hooks then flBudget = flBudget * GM.RarityTuning.PowerStatShare end
			GM:AddRarityStats(Item, tblSuffix.Stats, flBudget)
			Item.Hooks = tblSuffix.Hooks
			Item.PowerDesc = tblSuffix.PowerDesc
			RegisterLoot(Item)
		end
	end
end

local function Unique(strBase, strName, strPrintName, tblInfo)
	local tblBase = GM.DataBase.Items[strBase]
	if not tblBase then return end
	local Item = GM:MakeRarityItem(tblBase, strName, strPrintName, "epic")
	local flBudget = GM.Rarities.epic.Budget
	if tblInfo.Hooks then flBudget = flBudget * GM.RarityTuning.PowerStatShare end
	GM:AddRarityStats(Item, tblInfo.Stats, flBudget)
	Item.Desc = tblInfo.Desc or Item.Desc
	Item.Lore = tblInfo.Lore
	Item.Hooks = tblInfo.Hooks
	Item.PowerDesc = tblInfo.PowerDesc
	Item.Unique = true
	RegisterLoot(Item)
end

function GM:MakeLegendaryItem(tblBase, strName, strPrintName, tblInfo)
	local Item = self:MakeRarityItem(tblBase, strName, strPrintName, "legendary")
	Item.Generated = nil
	Item.BaseItem = tblInfo.BaseItem
	Item.SellPrice = 0
	Item.Dropable = false
	Item.Giveable = false
	Item.Unique = true
	Item.Set = tblInfo.Set
	if tblInfo.Level then Item.Level = tblInfo.Level end
	if tblInfo.Model then Item.Model = table.Copy(tblInfo.Model) end
	Item.Effects = tblInfo.Effects
	local flBudget = self.Rarities.legendary.Budget
	if tblInfo.Hooks then flBudget = flBudget * self.RarityTuning.PowerStatShare end
	self:AddRarityStats(Item, tblInfo.Stats, flBudget)
	Item.Desc = tblInfo.Desc or Item.Desc
	Item.Lore = tblInfo.Lore
	Item.Hooks = tblInfo.Hooks
	Item.PowerDesc = tblInfo.PowerDesc
	Register.Item(Item)
	return Item
end

Unique("weapon_melee_longsword", "unique_thornes_oath", "Thorne's Oath", {
	Desc = "Sir Gaspard's own blade, its crossguard bent from a joust he did not lose.",
	Lore = "He swore to protect the road. He never said from whom.",
	Stats = {stat_strength = 0.7, stat_maxhealth = 0.3},
	Hooks = {on_kill = function(ply, Rank, entNPC)
		if SERVER and ply:Alive() then
			local intMax = ply:GetStat("stat_maxhealth")
			ply:SetHealth(math.min(ply:Health() + math.max(math.Round(intMax * 0.05), 1), intMax))
		end
		return entNPC
	end},
	PowerDesc = "Each kill restores 5% of your health.",
})
