
local Player = FindMetaTable("Player")

GM.RarityOrder = {"common", "uncommon", "rare", "epic", "legendary"}

GM.Rarities = {
	common = {PrintName = "Common", Color = Color(255, 255, 255), PowerMult = 1, Budget = 0, SellShare = 1},
	uncommon = {PrintName = "Uncommon", Color = Color(30, 255, 0), PowerMult = 1.05, Budget = 0.08, SellShare = 0.4},
	rare = {PrintName = "Rare", Color = Color(0, 112, 221), PowerMult = 1.10, Budget = 0.16, SellShare = 0.6},
	epic = {PrintName = "Epic", Color = Color(163, 53, 238), PowerMult = 1.15, Budget = 0.16, SellShare = 0.8},
	legendary = {PrintName = "Legendary", Color = Color(255, 128, 0), PowerMult = 1.20, Budget = 0.20, SellShare = 0},
}

GM.RarityTuning = {
	StatScale = {stat_strength = 1, stat_dexterity = 1, stat_luck = 1, stat_agility = 0.5},
	PowerStatShare = 0.5,
	EliteWeights = {uncommon = 70, rare = 25, epic = 5},
	EliteLevelRange = 10,
	AnnounceFrom = "rare",
}

local function IgniteOnHit(ply, Rank, entVictim, intDamage)
	if SERVER and IsValid(entVictim) and entVictim.IgniteFor and math.random() < 0.1 then
		entVictim:IgniteFor(3, math.max(math.Round((intDamage or 0) * 0.15), 1), ply)
	end
	return entVictim, intDamage
end

local function HealOnKill(ply, Rank, entNPC)
	if SERVER and ply:Alive() then
		local intMax = ply:GetStat("stat_maxhealth")
		ply:SetHealth(math.min(ply:Health() + math.max(math.Round(intMax * 0.04), 1), intMax))
	end
	return entNPC
end

GM.LootSuffixes = {
	{Key = "bear", Suffix = "of the Bear", Rarity = "uncommon", For = {melee = true, armor = true}, Stats = {stat_strength = 0.6, stat_maxhealth = 0.4}},
	{Key = "fox", Suffix = "of the Fox", Rarity = "uncommon", For = {ranged = true, armor = true}, Stats = {stat_dexterity = 0.6, stat_agility = 0.4}},
	{Key = "boar", Suffix = "of the Boar", Rarity = "uncommon", For = {armor = true}, Stats = {stat_maxhealth = 1}},
	{Key = "wolf", Suffix = "of the Wolf", Rarity = "uncommon", For = {melee = true, armor = true}, Stats = {stat_strength = 0.5, stat_luck = 0.5}},
	{Key = "hawk", Suffix = "of the Hawk", Rarity = "uncommon", For = {ranged = true, armor = true}, Stats = {stat_dexterity = 0.5, stat_luck = 0.5}},

	{Key = "warlord", Suffix = "of the Warlord", Rarity = "rare", For = {melee = true, armor = true}, Stats = {stat_strength = 0.7, stat_maxhealth = 0.3}},
	{Key = "ranger", Suffix = "of the Ranger", Rarity = "rare", For = {ranged = true, armor = true}, Stats = {stat_dexterity = 0.7, stat_agility = 0.3}},
	{Key = "bulwark", Suffix = "of the Bulwark", Rarity = "rare", For = {armor = true}, Stats = {stat_maxhealth = 1}},
	{Key = "embers", Suffix = "of Embers", Rarity = "rare", For = {melee = true, ranged = true}, Stats = {stat_strength = 0.5, stat_dexterity = 0.5},
		Hooks = {on_hit = IgniteOnHit}, PowerDesc = "Hits have a 10% chance to set the target alight."},
	{Key = "leech", Suffix = "of the Leech", Rarity = "rare", For = {melee = true, ranged = true}, Stats = {stat_strength = 0.5, stat_dexterity = 0.5},
		Hooks = {on_kill = HealOnKill}, PowerDesc = "Each kill restores 4% of your health."},
}

function GM:GetRarity(tblItem)
	return tblItem and tblItem.Rarity or "common"
end

function GM:GetRarityRank(strRarity)
	for intRank, strKey in ipairs(self.RarityOrder) do
		if strKey == strRarity then return intRank end
	end
	return 1
end

function GM:GetExpectedStat(intLevel)
	return 1 + self.Combat.ExpectedStatPerLevel * (math.max(intLevel or 1, 1) - 1)
end

function GM:GetAffixStat(strStat, intLevel, flBudget)
	if strStat == "stat_maxhealth" then
		return math.max(math.Round(self:GetExpectedPlayerHealth(intLevel) * flBudget), 1)
	end
	local flScale = self.RarityTuning.StatScale[strStat] or 1
	return math.max(math.Round(self:GetExpectedStat(intLevel) * flBudget * flScale), 1)
end

function GetBaseItemName(strItem)
	local tblItem = ItemTable(strItem)
	return tblItem and tblItem.BaseItem or strItem
end

function Player:IsWearingPiece(strItem)
	for _, strWorn in pairs(self.Data and self.Data.Paperdoll or {}) do
		if strWorn == strItem or GetBaseItemName(strWorn) == strItem then return true end
	end
	return false
end

if SERVER then
	local function PickWeighted(tblWeights, tblOrder)
		local flTotal = 0
		for _, strKey in ipairs(tblOrder) do flTotal = flTotal + (tblWeights[strKey] or 0) end
		if flTotal <= 0 then return nil end
		local flRoll = math.Rand(0, flTotal)
		for _, strKey in ipairs(tblOrder) do
			local flWeight = tblWeights[strKey] or 0
			if flWeight > 0 then
				if flRoll <= flWeight then return strKey end
				flRoll = flRoll - flWeight
			end
		end
		return tblOrder[#tblOrder]
	end

	local function SlotAllowed(tblLoot, tblItem)
		if not tblLoot.Slots then return true end
		return table.HasValue(tblLoot.Slots, tblItem.Slot)
	end

	function GM:RollEliteLoot(intLevel, tblLoot)
		local strRarity = PickWeighted(tblLoot.Rarity or self.RarityTuning.EliteWeights, self.RarityOrder)
		if not strRarity then return nil end
		if strRarity == "epic" then
			if tblLoot.Epic and #tblLoot.Epic > 0 then
				local strItem = tblLoot.Epic[math.random(#tblLoot.Epic)]
				if ItemTable(strItem) then return strItem, "epic" end
			end
			strRarity = "rare"
		end
		local intRange = tblLoot.LevelRange or self.RarityTuning.EliteLevelRange
		for _, intWiden in ipairs({0, 10, 30, 1000}) do
			local tblCandidates = {}
			for _, strItem in ipairs(self.LootPool[strRarity] or {}) do
				local tblItem = ItemTable(strItem)
				local intItemLevel = tblItem.Level or 1
				if intItemLevel >= intLevel - intRange - intWiden and intItemLevel <= intLevel + intWiden and SlotAllowed(tblLoot, tblItem) then
					table.insert(tblCandidates, strItem)
				end
			end
			if #tblCandidates > 0 then return tblCandidates[math.random(#tblCandidates)], strRarity end
		end
		return nil
	end

	function GM:AnnounceLoot(entNPC, strItem)
		local tblItem = ItemTable(strItem)
		if not tblItem then return end
		local strRarity = self:GetRarity(tblItem)
		if self:GetRarityRank(strRarity) < self:GetRarityRank(self.RarityTuning.AnnounceFrom) then return end
		local tblNPC = IsValid(entNPC) and NPCTable(entNPC:GetNWString("npc"))
		local strFrom = tblNPC and tblNPC.PrintName or "Something"
		local strText = strFrom .. " dropped " .. (tblItem.PrintName or strItem) .. " (" .. self.Rarities[strRarity].PrintName .. ")!"
		for _, ply in ipairs(player.GetAll()) do ply:ChatPrint(strText) end
	end
end
