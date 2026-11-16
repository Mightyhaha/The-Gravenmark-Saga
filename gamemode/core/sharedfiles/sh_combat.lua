local Player = FindMetaTable("Player")

GM.Combat = {
	ReferenceHealthPerLevel = 20,
	ReferenceDamagePerLevel = 3,
	HitsToKillAtLevel1 = 4,
	HitsToKillAtMaxLevel = 6,
	HitsToDieUnarmored = 12,
	WeaponPowerBase = 8,
	WeaponPowerPerLevel = 0.55,
	ExpectedStatPerLevel = 0.58,
	StatDamageDivisor = 10,
	ExpectedArmorBase = 10,
	ExpectedArmorPerLevel = 3,
	LevelDifferenceStep = 0.03,
	LevelDifferenceMin = 0.25,
	LevelDifferenceMax = 1.5,
	AgilityMoveSpeed = 4,
	AgilityFireRateDivisor = 40,
	WeaponTierHalfGap = 5,
	ArmorTierHalfGap = 6,
	ReferenceFireRate = 1.5,
	BaseCritChance = 0.05,
	PriceBase = 16,
	PriceExponent = 1.5,
	ArmorPriceFactor = 0.6,
	CraftValueShare = 0.5,
	CraftUnitsAtBandTop = 10,
	MaxTradeTier = 15,
}

GM.WeaponClasses = {
	sword = {PrintName = "Sword", FireRate = 1.7, Output = 1, HoldType = "melee"},
	axe = {PrintName = "Axe", FireRate = 1.4, Output = 1, CritBonus = 0.1, HoldType = "melee"},
	spear = {PrintName = "Spear", FireRate = 1.2, Output = 0.95, Range = 95, HoldType = "melee2"},
	hammer = {PrintName = "Hammer", FireRate = 0.9, Output = 1.05, HoldType = "melee"},
}

GM.SlotUnlockLevel = {
	slot_primaryweapon = 1,
	slot_chest = 1,
	slot_offhand = 1,
	slot_waist = 10,
	slot_helm = 15,
	slot_shoulder = 20,
	slot_neck = 30,
	slot_ring_1 = 15,
	slot_ring_2 = 15,
}

GM.ArmorSlotShare = {
	slot_chest = 1.5,
	slot_offhand = 1.2,
	slot_helm = 1,
	slot_shoulder = 1,
	slot_waist = 1,
}

GM.LevelGrowth = {
	stat_maxhealth = 6,
	stat_strength = 1 / 3,
	stat_dexterity = 1 / 3,
}

function GM:GetStatDamageMultiplier(intStat)
	return 1 + (math.max(tonumber(intStat) or 1, 1) - 1) / self.Combat.StatDamageDivisor
end

function GM:GetExpectedWeaponPower(intLevel)
	return self.Combat.WeaponPowerBase + self.Combat.WeaponPowerPerLevel * intLevel
end

function GM:GetExpectedPlayerDamage(intLevel)
	local intStat = 1 + self.Combat.ExpectedStatPerLevel * (intLevel - 1)
	return self:GetExpectedWeaponPower(intLevel) * self:GetStatDamageMultiplier(intStat)
end

function GM:GetExpectedPlayerHealth(intLevel)
	local tblStat = StatTable("stat_maxhealth")
	return (tblStat and tblStat.Default or 100) + self.LevelGrowth.stat_maxhealth * (intLevel - 1)
end

function GM:GetHitsToKill(intLevel)
	local Fraction = (math.Clamp(intLevel, 1, self.MaxLevel) - 1) / math.max(self.MaxLevel - 1, 1)
	return self.Combat.HitsToKillAtLevel1 + (self.Combat.HitsToKillAtMaxLevel - self.Combat.HitsToKillAtLevel1) * Fraction
end

function GM:GetLevelDifferenceFactor(intDifference)
	local Factor = 1 + self.Combat.LevelDifferenceStep * (intDifference or 0)
	return math.Clamp(Factor, self.Combat.LevelDifferenceMin, self.Combat.LevelDifferenceMax)
end

function GM:GetOutgoingDamageScale(intNPCLevel, intPlayerLevel)
	intNPCLevel = math.max(tonumber(intNPCLevel) or 1, 1)
	local Health = intNPCLevel * self.Combat.ReferenceHealthPerLevel
	local Scale = Health / (self:GetHitsToKill(intNPCLevel) * self:GetExpectedPlayerDamage(intNPCLevel))
	return Scale * self:GetLevelDifferenceFactor((intPlayerLevel or intNPCLevel) - intNPCLevel)
end

function GM:GetExpectedArmor(intLevel)
	return self.Combat.ExpectedArmorBase + self.Combat.ExpectedArmorPerLevel * intLevel
end

function GM:GetArmorDamageFactor(intArmor, intLevel)
	local Expected = self:GetExpectedArmor(math.max(intLevel or 1, 1))
	return Expected / (Expected + math.max(intArmor or 0, 0))
end

function GM:GetNPCHitDamage(tblNPCTable, intNPCLevel, plyVictim)
	intNPCLevel = math.max(tonumber(intNPCLevel) or 1, 1)
	local Strength = (tblNPCTable.DamagePerLevel or 0) / self.Combat.ReferenceDamagePerLevel
	local Damage = Strength * self:GetExpectedPlayerHealth(intNPCLevel) / self.Combat.HitsToDieUnarmored
	if IsValid(plyVictim) and plyVictim:IsPlayer() then
		Damage = Damage * self:GetArmorDamageFactor((plyVictim:GetArmorRating() or 1) - 1, intNPCLevel)
		Damage = Damage * self:GetLevelDifferenceFactor(intNPCLevel - plyVictim:GetLevel())
	end
	return Damage
end

GM.CraftBands = {"scrap", "iron", "steel", "silver", "glass", "ebony", "graven", "dread"}

function GM:GetCraftBand(intLevel)
	return math.Clamp(math.floor(intLevel / 20) + 1, 1, #self.CraftBands)
end

function GM:GetCritChance(plyAttacker, tblWeapon)
	local intLuck = IsValid(plyAttacker) and plyAttacker:GetStat("stat_luck") or 1
	local Chance = 1 / math.max(math.Round(1 / self.Combat.BaseCritChance / (1 + intLuck / 50)), 1)
	return Chance + ((tblWeapon and tblWeapon.CritBonus) or 0)
end

function GM:GetWeaponTierPower(strClass, intLevel)
	local Class = self.WeaponClasses[strClass]
	local Offset = math.min(self.Combat.WeaponTierHalfGap, intLevel)
	local Crit = 1 + self.Combat.BaseCritChance
	local Reference = self:GetExpectedWeaponPower(intLevel + Offset) * self.Combat.ReferenceFireRate * Crit
	return math.max(math.Round(Reference * Class.Output / (Class.FireRate * (Crit + (Class.CritBonus or 0)))), 1)
end

function GM:GetRawArmorTierValue(strSlot, intLevel)
	local Share = self.ArmorSlotShare[strSlot]
	if not Share then return 0 end
	local Available = 0
	for strOther, Weight in pairs(self.ArmorSlotShare) do
		if (self.SlotUnlockLevel[strOther] or 1) <= intLevel then Available = Available + Weight end
	end
	local Offset = math.min(self.Combat.ArmorTierHalfGap, intLevel)
	return math.max(math.Round(self:GetExpectedArmor(intLevel + Offset) * Share / math.max(Available, Share)), 1)
end

function GM:GetArmorTierValue(strSlot, intLevel)
	local Value = self:GetRawArmorTierValue(strSlot, intLevel)
	local intUnlock = self.SlotUnlockLevel[strSlot] or 1
	for _, intBoundary in pairs(self.SlotUnlockLevel) do
		if intBoundary >= intUnlock and intBoundary < intLevel then
			Value = math.max(Value, self:GetRawArmorTierValue(strSlot, intBoundary))
		end
	end
	return Value
end

function GM:GetGearPrice(intLevel, flFactor)
	return math.max(math.Round(self.Combat.PriceBase * intLevel ^ self.Combat.PriceExponent * (flFactor or 1)), 1)
end

function GM:GetArmorPrice(strSlot, intLevel)
	return self:GetGearPrice(intLevel, self.Combat.ArmorPriceFactor * (self.ArmorSlotShare[strSlot] or 1))
end

function GM:GetTradeTier(intLevel)
	return math.Clamp(math.ceil(intLevel / 10), 1, self.Combat.MaxTradeTier)
end

function GM:GetLevelGrowthTotal(strStat, intLevel)
	local Rate = self.LevelGrowth[strStat] or 0
	return math.floor((math.max(intLevel, 1) - 1) * Rate + 0.0001)
end

if SERVER then
	function Player:ApplyLevelGrowth(intFromLevel, intToLevel)
		for strStat in pairs(GAMEMODE.LevelGrowth) do
			local intDelta = GAMEMODE:GetLevelGrowthTotal(strStat, intToLevel) - GAMEMODE:GetLevelGrowthTotal(strStat, intFromLevel)
			if intDelta ~= 0 then self:AddStat(strStat, intDelta) end
		end
	end
end
