local Player = FindMetaTable("Player")

--The Quests from this point down have not been added to any npc yet, and probolly are under cunstruction
local Quest = {}
Quest.Name = "quest_gatherantlionshell"
Quest.PrintName = "The Legendary Beast!"
Quest.Story = "Hey! You! Yeah, you! I can help you. Have you ever heard of a beast called, the Antlion Guard!? I hear it has a shell as hard as rock! Bring me its shell, and i can make you a shield. It wont be free tho. I'll need some cash too!"
Quest.Level = 40
Quest.ObtainItems = {}
Quest.ObtainItems["antlion_shell"] = 1
Quest.ObtainItems["money"] = 500
Quest.GainedExp = 600
Quest.GainedItems = {}
Quest.GainedItems["armor_shield_antlionshell"] = 1
Register.Quest(Quest)

function Player:AddQuest(strQuest, tblInfo)
	if not IsValid(self) then return end
	local tblQuestTable = QuestTable(strQuest)
	if not self:GetQuest(strQuest) and tblQuestTable then
		self.Data.Quests[strQuest] = {}
		local tblNewQuestTable = {}
		tblNewQuestTable.Done = false
		for strNPC, intToKill in pairs(tblQuestTable.Kill or {}) do
			tblNewQuestTable.Kills = tblNewQuestTable.Kills or {}
			tblNewQuestTable.Kills[strNPC] = 0
		end
		self:UpdateQuest(strQuest, tblInfo or tblNewQuestTable)
	end
end

function Player:QuestItem(strItem)
	local tblItemTable = ItemTable(strItem)
	if not tblItemTable.QuestItem or self:GetQuest(tblItemTable.QuestItem) then
		if not self:HasCompletedQuest(tblItemTable.QuestItem) then
			return true
		end
		return false
	end
	return false
end

function Player:HasCompletedQuest(strQuest)
	if self:GetQuest(strQuest) and self:GetQuest(strQuest).Done then
		return true
	end
	return false
end

function Player:GetQuest(strQuest)
	if not IsValid(self) then return end
	self.Data.Quests = self.Data.Quests or {}
	return self.Data.Quests[strQuest]
end

function Player:UpdateQuest(strQuest, tblInfo)
	if not IsValid(self) then return end
	if self:GetQuest(strQuest) then
		table.Merge(self.Data.Quests[strQuest], tblInfo or self.Data.Quests[strQuest] or {})
		if SERVER then
			SendNetworkMessage("UD_UpdateQuest", self, {strQuest, tblInfo or self.Data.Quests[strQuest]})
			self:SaveGame()
		end
		if CLIENT and GAMEMODE.QuestMenu then
			GAMEMODE.QuestMenu:LoadQuests()
		end
		return true
	end
	self:AddQuest(strQuest, tblInfo)
end

function Player:AddQuestKill(strNPC)
	if not IsValid(self) then return end
	local tblGivePlayers = {self}
	if #(self.Squad or {}) > 1 then tblGivePlayers = self.Squad end
	for _, ply in pairs(tblGivePlayers) do
		if IsValid(ply) then
			for strQuest, tblInfo in pairs(ply.Data.Quests or {}) do
				local tblQuestTable = QuestTable(strQuest)
				if tblInfo.Kills and tblInfo.Kills[strNPC] and tblInfo.Kills[strNPC] + 1 <= tblQuestTable.Kill[strNPC] then
					tblInfo.Kills[strNPC] = tblInfo.Kills[strNPC] + 1
					ply:UpdateQuest(strQuest, tblInfo)
				end
			end
		end
	end
end

function Player:CanAcceptQuest(strQuest)
	if not IsValid(self) then return false end
	local tblQuestTable = QuestTable(strQuest)
	if tblQuestTable and self:GetLevel() >= tblQuestTable.Level and not self:GetQuest(strQuest) then
		if tblQuestTable.QuestNeeded and not self:HasCompletedQuest(tblQuestTable.QuestNeeded) then return false end
		return true
	end
	return false
end

function Player:CanTurnInQuest(strQuest)
	if not IsValid(self) then return false end
	local tblQuestTable = QuestTable(strQuest)
	local tblPlayerQuestTable = self:GetQuest(strQuest)
	if tblQuestTable and not tblPlayerQuestTable.Done and tblPlayerQuestTable then
		for strNPC, intKillAmount in pairs(tblQuestTable.Kill or {}) do
			if tblPlayerQuestTable.Kills[strNPC] < intKillAmount then return false end
		end
		for strItem, intAmountNeeded in pairs(tblQuestTable.ObtainItems or {}) do
			if not self:HasItem(strItem, intAmountNeeded) then return false end
		end
		if self:HasRoomFor(tblQuestTable.GainedItems, -self:TotalWeightOf(tblQuestTable.ObtainItems or {})) then
			return true
		end
	end
end

if SERVER then
	function KillNPC(npcTarget, plyKiller, weapon)
		if npcTarget:GetNWInt("level") > 0 and plyKiller:IsPlayer() then
			local tblNPCTable = NPCTable(npcTarget:GetNWString("npc"))
			if not tblNPCTable then return end
			plyKiller:AddQuestKill(npcTarget:GetNWString("npc"))
		end
	end
	hook.Add("OnNPCKilled", "KillNPC", KillNPC)

	function Player:TurnInQuest(strQuest)
		if not IsValid(self) then return end
		if not IsValid(self.UseTarget) or not self.UseTarget.Quest or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
		local tblQuestTable = QuestTable(strQuest)
		if not tblQuestTable then return end
		if tblQuestTable.TurnInNPC and self.UseTarget:GetNWString("npc") ~= tblQuestTable.TurnInNPC then return end
		if self:CanTurnInQuest(strQuest) then
			self:TakeItems(tblQuestTable.ObtainItems)
			self:GiveItems(tblQuestTable.GainedItems)
			if tblQuestTable.GainedExp and tblQuestTable.GainedExp > 0 then
				self:GiveExp(tblQuestTable.GainedExp, true)
			end
			self.Data.Quests[strQuest].Done = true
			self:UpdateQuest(strQuest)
		end
	end
	concommand.Add("UD_TurnInQuest", function(ply, command, args) ply:TurnInQuest(args[1]) end)

	function Player:AcceptQuest(strQuest)
		if not IsValid(self) then return end
		if not IsValid(self.UseTarget) or not self.UseTarget.Quest or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
		if self:CanAcceptQuest(strQuest) then
			if QuestTable(strQuest).StartingItems then
				if self:HasRoomFor(QuestTable(strQuest).StartingItems) then
					self:GiveItems(QuestTable(strQuest).StartingItems)
					self:AddQuest(strQuest)
				end
			else
				self:AddQuest(strQuest)
			end
		end
	end
	concommand.Add("UD_AcceptQuest", function(ply, command, args) ply:AcceptQuest(args[1]) end)

	local SearchReachSqr = 150 ^ 2

	local function IsSearchableProp(entTarget)
		local strModel = string.lower(entTarget:GetModel() or "")
		for _, tblSearchable in ipairs(GAMEMODE.SearchableProps or {}) do
			if string.lower(tblSearchable.Model) == strModel then return true end
		end
		return false
	end

	local function NextSearchQuestItem(ply)
		for strQuest, tblInfo in pairs(ply.Data.Quests or {}) do
			local tblQuestTable = QuestTable(strQuest)
			if tblQuestTable and not tblInfo.Done then
				for strItem, intNeeded in pairs(tblQuestTable.ObtainItems or {}) do
					local tblItemTable = ItemTable(strItem)
					if tblItemTable and tblItemTable.FoundBySearching and ply:GetItem(strItem) < intNeeded then
						return strItem
					end
				end
			end
		end
	end

	hook.Add("KeyPress", "UD_QuestChestSearch", function(ply, intKey)
		if intKey ~= IN_USE or not ply.Data or not ply:Alive() then return end
		local entTarget = ply:GetEyeTrace().Entity
		if not IsValid(entTarget) or entTarget.IsBeingSearched or not IsSearchableProp(entTarget) then return end
		if entTarget:GetPos():DistToSqr(ply:GetPos()) > SearchReachSqr then return end
		local strItem = NextSearchQuestItem(ply)
		if not strItem then return end
		ply.UD_QuestSearched = ply.UD_QuestSearched or {}
		local strKey = strItem .. ":" .. entTarget:EntIndex()
		if ply.UD_QuestSearched[strKey] then return end
		ply.UD_QuestSearched[strKey] = true
		timer.Simple(3, function()
			if not IsValid(ply) then return end
			if not ply:QuestItem(strItem) or not ply:AddItem(strItem, 1) then
				ply.UD_QuestSearched[strKey] = nil
				return
			end
			ply:CreateNotification("Found " .. ItemTable(strItem).PrintName)
		end)
	end)
end

if CLIENT then
	net.Receive("UD_UpdateQuest", function()
		local strQuest = net.ReadString()
		local strIncomingInfo = net.ReadString()
		--print(string.len(strQuest .. strIncomingInfo))
		--print(strQuest .. strIncomingInfo)
		LocalPlayer():UpdateQuest(strQuest, util.JSONToTable(strIncomingInfo))
	end)
end
