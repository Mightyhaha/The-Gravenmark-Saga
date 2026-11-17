local Player = FindMetaTable("Player")

function Player:NewGame()
	-- TODO: config?
	self:SetNWInt("exp", 0)
	self:AddItem("money", 100)
	self:AddItem("item_healthkit", 2)
	self:AddItem("weapon_melee_rustysword", 1)
	self:AddItem("item_bedroll", 1)
	self:AddItem("food_ryebread", 3)
	self:AddItem("weapon_ranged_huntingbow", 1)
	self:AddItem("item_arrows", 2)
	self:SaveGame()
end

function Player:LoadGame()
	self.Data = {}
	self.Race = "human"
	-- local Data = {}

	-- Set the player's stats to the default.
	for name, stat in pairs(GAMEMODE.DataBase.Stats) do
		self:SetStat(name, stat.Default)
	end

	-- Load the player's game
	local steamID = string.Replace(self:SteamID(), ":", "!")
	if game.SinglePlayer() or steamID ~= "STEAM_ID_PENDING" then
		local FileName = self:GetSaveFileName()
		local savedGameData = file.Exists(FileName, "DATA") and UD_ReadSaveFile(FileName)

		if file.Exists(FileName, "DATA") and not savedGameData then
			local BrokenCopy = string.gsub(FileName, "%.txt$", "_unreadable.txt")
			file.Write(BrokenCopy, file.Read(FileName, "DATA") or "")
			ErrorNoHalt("[Gravenmark] Could not read save " .. FileName .. ", kept a copy as " .. BrokenCopy .. "\n")
		end

		if savedGameData then
			local intExp = tonumber(savedGameData.Exp) or 0
			if (tonumber(savedGameData.ExpCurve) or 1) < GAMEMODE.ExpCurveVersion then
				intExp = LegacyExpToExp(intExp)
			end
			self:SetNWInt("exp", math.Clamp(intExp, 0, toExp(GAMEMODE.MaxLevel)))
			self:ApplyLevelGrowth(1, self:GetLevel())
			self:SetNWInt("SkillPoints", self:GetDeservedSkillPoints())

			if savedGameData.Skills then
				local AllSkillsTable = table.ClearKeys(table.Copy(GAMEMODE.DataBase.Skills))
				table.sort(AllSkillsTable, function(SkillA, SkillB)
					if SkillA.Tier ~= SkillB.Tier then return SkillA.Tier < SkillB.Tier end
					return SkillA.Name < SkillB.Name
				end)

				for _, Skill in ipairs(AllSkillsTable) do
					local intRank = tonumber(savedGameData.Skills[Skill.Name]) or 0
					if intRank > 0 then self:BuySkill(Skill.Name, intRank, true) end
				end
			end

			self.Data.Model = savedGameData.Model or "models/player/Group01/male_02.mdl"
			self:SetModel(savedGameData.Model or "models/player/Group01/male_02.mdl")

			local intRefund = UD_CleanRemovedItems(savedGameData.Inventory) + UD_CleanRemovedItems(savedGameData.Bank)
			self:GiveItems(savedGameData.Inventory)
			if intRefund > 0 then
				self:AddItem("money", intRefund)
				self:ChatPrint("Some of your old gear no longer exists in this world. You were paid " .. intRefund .. " denars for it.")
			end

			for Item, Amount in pairs(savedGameData.Bank or {}) do self:AddItemToBank(Item, Amount) end
			for slot, item in pairs(savedGameData.Paperdoll or {}) do
				if ItemTable(item) then self:UseItem(item, slot) end
			end
			for Quest, Info in pairs(savedGameData.Quests or {}) do
				if QuestTable(Quest) then self:UpdateQuest(Quest, Info) end
			end
			for Book, boolRead in pairs(savedGameData.Library or {}) do
				if ItemTable(Book) then self:AddBookToLibrary(Book) end
			end
			for Master, intExp in pairs(savedGameData.Masters or {}) do self:SetMaster(Master, intExp) end
		else
			self:NewGame()
		end
	end
	self:SetNWInt("SkillPoints", self:GetDeservedSkillPoints())

	-- Finish loading
	self.Loaded = true
	self:SetNWBool("Loaded", true)
	self:SaveGame()

	hook.Run("UD_Hook_PlayerLoad", self)
	for _, ply in pairs(player.GetAll()) do
		if ply ~= self and ply.Data and ply.Data.Paperdoll then
			for slot, item in pairs(ply.Data.Paperdoll) do
				SendNetworkMessage("UD_UpdatePaperDoll", self, {ply, slot, item})
			end
		end
	end
end

function UD_CleanRemovedItems(tblItems)
	local intRefund = 0
	for strItem, intAmount in pairs(tblItems or {}) do
		if not ItemTable(strItem) then
			intRefund = intRefund + (GAMEMODE.RemovedItemValues[strItem] or 0) * math.max(tonumber(intAmount) or 0, 0)
			tblItems[strItem] = nil
		end
	end
	return math.Round(intRefund)
end

function Player:GetSaveFileName(SubFolder)
	local SteamID = string.Replace(self:SteamID(), ":", "!")
	return GAMEMODE.DataFolder .. "/" .. (SubFolder and SubFolder .. "/" or "") .. SteamID .. ".txt"
end

function UD_ReadSaveFile(FileName)
	local Raw = file.Read(FileName, "DATA")
	if not Raw or Raw == "" then return nil end
	return util.JSONToTable(util.Decompress(Raw) or Raw)
end

local AutoSaveInterval = 30

function Player:SaveGame()
	if not self.Loaded or GAMEMODE.StopSaving or not self.Data then return end
	self.UD_NeedsSave = true
end

function Player:SaveGameNow(SubFolder)
	if not self.Loaded or GAMEMODE.StopSaving or not self.Data then return end

	local SaveTable = table.Copy(self.Data)
	SaveTable.Inventory = {}
	
	for Item, Amount in pairs(self.Data.Inventory or {}) do
		if Amount > 0 then SaveTable.Inventory[Item] = Amount end
	end

	SaveTable.Bank = {}
	for Item, Amount in pairs(self.Data.Bank or {}) do
		if Amount > 0 then SaveTable.Bank[Item] = Amount end
	end

	SaveTable.Quests = {}
	for Quest, Info in pairs(self.Data.Quests or {}) do
		if Info.Done then
			SaveTable.Quests[Quest] = {Done = true}
		else
			SaveTable.Quests[Quest] = Info
		end
	end

	if self:SteamID() ~= "STEAM_ID_PENDING" then
		SaveTable.Exp = self:GetNWInt("exp")
		SaveTable.ExpCurve = GAMEMODE.ExpCurveVersion
		file.Write(self:GetSaveFileName(SubFolder), util.Compress(util.TableToJSON(SaveTable)))
	end
	if not SubFolder then self.UD_NeedsSave = false end
end

local function PlayerSaveNow(ply) ply:SaveGameNow() end
hook.Add("PlayerDisconnected", "PlayerSavePlayerDisconnected", PlayerSaveNow)
hook.Add("UD_Hook_PlayerLevelUp", "PlayerSaveUD_Hook_PlayerLevelUp", PlayerSaveNow)
hook.Add("ShutDown", "PlayerSaveShutDown", function() for _, ply in ipairs(player.GetAll()) do PlayerSaveNow(ply) end end)

timer.Create("UD_AutoSave", AutoSaveInterval, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		if ply.UD_NeedsSave then ply:SaveGameNow() end
	end
end)
