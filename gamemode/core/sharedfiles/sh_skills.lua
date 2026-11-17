local Player = FindMetaTable("Player")

GM.SkillPointsPerLevel = 1
GM.SkillPointBonusEvery = 10
GM.SkillTierLevels = {1, 5, 12, 20, 30, 45, 60, 80, 105, 130, 150}
GM.SkillBranches = {
	{Name = "blade", PrintName = "The Sword-Arm", Desc = "Melee and Strength. Aldric's lessons: footwork first, then the blade."},
	{Name = "marksman", PrintName = "The Fletcher's Eye", Desc = "Ranged weapons and Dexterity. The hunters of the Dunmarrow woods."},
	{Name = "bulwark", PrintName = "The Bulwark", Desc = "Health, armor and staying alive. Hold the line like the Gravenmark itself."},
	{Name = "wayfarer", PrintName = "The Wayfarer", Desc = "Food, rest, carrying and coin. The rebellion lives off the land."},
	{Name = "banner", PrintName = "The Banner", Desc = "Luck, experience and your squad. Ulric's call to the Threefold Crowns."},
}

function GM:GetSkillTierLevel(intTier)
	return self.SkillTierLevels[intTier] or self.MaxLevel or 150
end

function GM:GetTotalSkillPoints(intLevel)
	intLevel = math.max(intLevel or 1, 1)
	return intLevel * self.SkillPointsPerLevel + math.floor(intLevel / self.SkillPointBonusEvery)
end

function GM:GetSkillResetCost(intLevel)
	return math.max(100, (intLevel or 1) * 20)
end

function SkillRankValue(tblValues, intRank)
	if not tblValues or intRank <= 0 then return 0 end
	return tblValues[math.min(intRank, #tblValues)] or 0
end

local function ApplySkillStatRanks(tblSkill, ply, intNew, intOld)
	for strStat, tblValues in pairs(tblSkill.StatRanks or {}) do
		local intDelta = SkillRankValue(tblValues, intNew) - SkillRankValue(tblValues, intOld)
		if intDelta ~= 0 then ply:AddStat(strStat, intDelta) end
	end
end

function CreateSkill(strName, strPrintName, strBranch, intTier, intLevels, strIcon, strStory, strSkillNeeded)
	local tblSkill = {}
	tblSkill.Name = strName
	tblSkill.PrintName = strPrintName
	tblSkill.Branch = strBranch
	tblSkill.Tier = intTier
	tblSkill.Levels = intLevels
	tblSkill.Icon = strIcon
	tblSkill.Cost = 1
	tblSkill.Hooks = {}
	tblSkill.Desc = {story = strStory}
	if strSkillNeeded then tblSkill.SkillNeeded = strSkillNeeded end
	return tblSkill
end

function AddSkillStat(tblSkill, strStat, tblValues)
	tblSkill.StatRanks = tblSkill.StatRanks or {}
	tblSkill.StatRanks[strStat] = tblValues
	tblSkill.OnSet = tblSkill.OnSet or ApplySkillStatRanks
end

function SetSkillDesc(tblSkill, fncDesc)
	for intRank = 1, tblSkill.Levels do
		tblSkill.Desc[intRank] = fncDesc(intRank)
	end
end

function AddSkillStatDesc(tblSkill, strStat, strLabel, tblValues)
	AddSkillStat(tblSkill, strStat, tblValues)
	SetSkillDesc(tblSkill, function(intRank) return "+" .. SkillRankValue(tblValues, intRank) .. " " .. strLabel end)
end

function RegisterSkill(tblSkill)
	if tblSkill.SkillNeeded then
		local tblNeeded = GM.DataBase.Skills[tblSkill.SkillNeeded]
		tblSkill.Desc["SkillNeeded"] = tblNeeded and tblNeeded.PrintName or tblSkill.SkillNeeded
	end
	Register.Skill(tblSkill)
end

function Player:SetSkill(strSkill, intAmount)
	local tblSkillTable = SkillTable(strSkill)
	if not tblSkillTable then return end
	intAmount = math.Clamp(intAmount or 0, 0, tblSkillTable.Levels)
	self.Data = self.Data or {}
	self.Data.Skills = self.Data.Skills or {}
	local intOldSkill = self.Data.Skills[strSkill] or 0
	self.Data.Skills[strSkill] = intAmount > 0 and intAmount or nil
	if SERVER then
		if tblSkillTable.OnSet then tblSkillTable:OnSet(self, intAmount, intOldSkill) end
		SendNetworkMessage("UD_UpdateSkills", self, {strSkill, intAmount})
	end
	if CLIENT and GAMEMODE.MainMenu then
		timer.Create("UD_RefreshSkillsTab", 0.15, 1, function()
			if not GAMEMODE.MainMenu then return end
			if GAMEMODE.MainMenu.SkillsTab then GAMEMODE.MainMenu.SkillsTab:Refresh() end
			if GAMEMODE.MainMenu.CharacterTab then GAMEMODE.MainMenu.CharacterTab:LoadHeader() end
			if GAMEMODE.MainMenu.InventoryTab then GAMEMODE.MainMenu.InventoryTab:LoadInventory() end
		end)
	end
end

function Player:GetSkill(strSkill)
	if not self.Data then return 0 end
	self.Data.Skills = self.Data.Skills or {}
	return self.Data.Skills[strSkill] or 0
end

function Player:HasSkill(strSkill)
	return self:GetSkill(strSkill) > 0
end

function Player:GetSpentSkillPoints()
	local intSpent = 0
	for strSkill, intRank in pairs(self.Data and self.Data.Skills or {}) do
		local tblSkillTable = SkillTable(strSkill)
		if tblSkillTable then intSpent = intSpent + intRank * (tblSkillTable.Cost or 1) end
	end
	return intSpent
end

function Player:GetBranchSkillPoints(strBranch)
	local intSpent = 0
	for strSkill, intRank in pairs(self.Data and self.Data.Skills or {}) do
		local tblSkillTable = SkillTable(strSkill)
		if tblSkillTable and tblSkillTable.Branch == strBranch then intSpent = intSpent + intRank * (tblSkillTable.Cost or 1) end
	end
	return intSpent
end

function Player:GetDeservedSkillPoints()
	return math.max(GAMEMODE:GetTotalSkillPoints(self:GetLevel()) - self:GetSpentSkillPoints(), 0)
end

function Player:MeetsSkillLevel(strSkill)
	local tblSkillTable = SkillTable(strSkill)
	if not tblSkillTable then return false end
	return self:GetLevel() >= GAMEMODE:GetSkillTierLevel(tblSkillTable.Tier)
end

function Player:MeetsSkillPrerequisite(strSkill)
	local tblSkillTable = SkillTable(strSkill)
	if not tblSkillTable then return false end
	if not tblSkillTable.SkillNeeded then return true end
	return self:GetSkill(tblSkillTable.SkillNeeded) >= (tblSkillTable.SkillNeededRank or 1)
end

function Player:CanHaveSkill(strSkill)
	return self:MeetsSkillLevel(strSkill) and self:MeetsSkillPrerequisite(strSkill)
end

function Player:CallSkillHook(strHook, ...)
	local tblReturnTable = {...}
	for strSkill, intSkillLevel in pairs(self.Data and self.Data.Skills or {}) do
		local tblSkillTable = SkillTable(strSkill)
		if tblSkillTable and intSkillLevel > 0 and tblSkillTable.Hooks and tblSkillTable.Hooks[strHook] then
			tblReturnTable = {tblSkillTable.Hooks[strHook](self, intSkillLevel, unpack(tblReturnTable))}
		end
	end
	for strBuff, tblInfo in pairs(self.UD_Buffs or {}) do
		local tblBuff = BuffTable(strBuff)
		if tblBuff and tblBuff.Hooks and tblBuff.Hooks[strHook] and (tblInfo.Expires or 0) > CurTime() then
			tblReturnTable = {tblBuff.Hooks[strHook](self, tblInfo.Power, unpack(tblReturnTable))}
		end
	end
	return unpack(tblReturnTable)
end

function Player:GetSquadInRange(intRange)
	local tblResult = {self}
	for _, plySquad in pairs(self.Squad or {}) do
		if IsValid(plySquad) and plySquad ~= self and plySquad:Alive() and plySquad:GetPos():DistToSqr(self:GetPos()) <= intRange * intRange then
			table.insert(tblResult, plySquad)
		end
	end
	return tblResult
end

if SERVER then
	hook.Add("UD_Hook_PlayerLevelUp", "PlayerLevelUp_SkillPoints", function(plyPlayer, intLevels)
		plyPlayer:SetNWInt("SkillPoints", plyPlayer:GetDeservedSkillPoints())
	end)

	function Player:BuySkill(strSkill, intAmount, boolLoading)
		local tblSkillTable = SkillTable(strSkill)
		if not tblSkillTable or not self.Data then return false end
		if not self:CanHaveSkill(strSkill) then return false end
		local intCost = tblSkillTable.Cost or 1
		intAmount = math.Clamp(math.floor(tonumber(intAmount) or 1), 0, tblSkillTable.Levels - self:GetSkill(strSkill))
		intAmount = math.min(intAmount, math.floor(self:GetNWInt("SkillPoints") / intCost))
		if intAmount <= 0 then return false end
		self:SetSkill(strSkill, self:GetSkill(strSkill) + intAmount)
		self:SetNWInt("SkillPoints", self:GetDeservedSkillPoints())
		if not boolLoading then self:SaveGame() end
		return true
	end
	concommand.Add("UD_BuySkill", function(ply, command, args)
		if IsValid(ply) and args[1] then ply:BuySkill(args[1], 1) end
	end)

	function Player:SkillReset()
		local intCost = GAMEMODE:GetSkillResetCost(self:GetLevel())
		if not self:HasItem("money", intCost) then
			self:CreateNotification("You need " .. intCost .. " denars to forget your training")
			return false
		end
		for strSkill in pairs(table.Copy(self.Data.Skills or {})) do
			self:SetSkill(strSkill, 0)
		end
		self:RemoveItem("money", intCost)
		self:SetNWInt("SkillPoints", self:GetDeservedSkillPoints())
		self:CreateNotification("Your skill points have been returned")
		self:SaveGame()
		return true
	end
	concommand.Add("UD_ResetSkills", function(ply, command, args)
		if IsValid(ply) then ply:SkillReset() end
	end)

	local function ResolveKiller(entNPC, entAttacker)
		if IsValid(entAttacker) and entAttacker:IsPlayer() then return entAttacker end
		if IsValid(entAttacker) and IsValid(entAttacker:GetOwner()) and entAttacker:GetOwner():IsPlayer() then return entAttacker:GetOwner() end
		if IsValid(entNPC.LastPlayerAttacker) then return entNPC.LastPlayerAttacker end
	end

	hook.Add("OnNPCKilled", "UD_SkillOnKill", function(entNPC, entAttacker)
		local plyKiller = ResolveKiller(entNPC, entAttacker)
		if not IsValid(plyKiller) or not plyKiller.Data then return end
		plyKiller:CallSkillHook("on_kill", entNPC)
	end)

	timer.Create("UD_SkillThink", 1, 0, function()
		for _, ply in ipairs(player.GetAll()) do
			if ply.Loaded and ply.Data and ply:Alive() then
				for strSkill, intRank in pairs(ply.Data.Skills or {}) do
					local tblSkillTable = SkillTable(strSkill)
					if tblSkillTable and tblSkillTable.Think and intRank > 0 then tblSkillTable:Think(ply, intRank) end
				end
				ply:ThinkBuffs()
			end
		end
	end)
end

if CLIENT then
	net.Receive("UD_UpdateSkills", function()
		LocalPlayer():SetSkill(net.ReadString(), net.ReadDouble())
	end)
end
