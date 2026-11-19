local Player = FindMetaTable("Player")
local GMTable = GM

GM.GemKinds = {
	{Key = "ruby", PrintName = "Ruby", Stat = "stat_strength", StatName = "Strength", Color = Color(220, 40, 50, 255)},
	{Key = "emerald", PrintName = "Emerald", Stat = "stat_dexterity", StatName = "Dexterity", Color = Color(40, 200, 90, 255)},
	{Key = "sapphire", PrintName = "Sapphire", Stat = "stat_maxhealth", StatName = "Max Health", Color = Color(50, 90, 230, 255)},
	{Key = "topaz", PrintName = "Topaz", Stat = "stat_agility", StatName = "Agility", Color = Color(240, 190, 40, 255)},
	{Key = "amethyst", PrintName = "Amethyst", Stat = "stat_luck", StatName = "Luck", Color = Color(170, 70, 220, 255)},
}

GM.GemGrades = {"Chipped", "Rough", "Flawed", "Cut", "Clear", "Bright", "Flawless", "Perfect"}

GM.Gems = {
	Budget = 0.05,
	MiningChance = 4,
	EliteChance = 25,
	BossChance = 50,
	RemoveFeeShare = 0.5,
	ArmorSlots = {slot_helm = true, slot_chest = true, slot_shoulder = true, slot_waist = true, slot_offhand = true, slot_boots = true},
}

GM.GemSeparator = "__gem_"

function GM:GetGemName(strKind, intGrade)
	return "gem_" .. strKind .. "_" .. intGrade
end

function GM:GetGemLevel(intGrade)
	return math.max((intGrade - 1) * 20, 1)
end

function GM:IsGem(tblItem)
	return tblItem ~= nil and tblItem.GemKind ~= nil
end

function GM:GetSocketParent(tblItem)
	if not tblItem then return nil end
	return tblItem.SocketParent and ItemTable(tblItem.SocketParent) or tblItem
end

function GM:GetSocketCount(tblItem)
	tblItem = self:GetSocketParent(tblItem)
	if not tblItem or not tblItem.Slot or self:IsGem(tblItem) then return 0 end
	if tblItem.Slot == "slot_primaryweapon" then
		if tblItem.Unique or self:GetRarityRank(self:GetRarity(tblItem)) >= self:GetRarityRank("epic") then return 2 end
		return 1
	end
	if self.Gems.ArmorSlots[tblItem.Slot] then return 1 end
	return 0
end

function GM:GetFreeSockets(tblItem)
	if not tblItem then return 0 end
	return self:GetSocketCount(tblItem) - #(tblItem.Gems or {})
end

function GM:GetSocketedName(strItem, strGem)
	return strItem .. "__" .. strGem
end

local function BuildSocketedItem(strName)
	local intStart = string.find(strName, GMTable.GemSeparator, 1, true)
	if not intStart then return nil end
	local strBase = string.sub(strName, 1, intStart - 1)
	local tblBase = rawget(GMTable.DataBase.Items, strBase)
	if not tblBase then return nil end
	local tblGems = {}
	for strPart in string.gmatch(string.sub(strName, intStart), "__(gem_[%w]+_%d+)") do
		local tblGem = rawget(GMTable.DataBase.Items, strPart)
		if not GMTable:IsGem(tblGem) then return nil end
		table.insert(tblGems, strPart)
	end
	if #tblGems == 0 or strBase .. "__" .. table.concat(tblGems, "__") ~= strName then return nil end
	if #tblGems > GMTable:GetSocketCount(tblBase) then return nil end
	local Item = DeriveTable(tblBase)
	Item.Name = strName
	Item.SocketParent = strBase
	Item.BaseItem = tblBase.BaseItem or tblBase.Name
	Item.Gems = tblGems
	Item.SocketBaseBuffs = table.Copy(tblBase.Buffs or {})
	Item.Buffs = table.Copy(tblBase.Buffs or {})
	local intGemValue = 0
	for _, strGem in ipairs(tblGems) do
		local tblGem = rawget(GMTable.DataBase.Items, strGem)
		for strStat, intAmount in pairs(tblGem.GemBuffs or {}) do
			Item.Buffs[strStat] = (Item.Buffs[strStat] or 0) + intAmount
		end
		intGemValue = intGemValue + (tblGem.SellPrice or 0)
	end
	Item.SellPrice = (tblBase.SellPrice or 0) + math.Round(intGemValue * 0.5)
	return Item
end

setmetatable(GM.DataBase.Items, {__index = function(tbl, strName)
	if not isstring(strName) then return nil end
	local Item = BuildSocketedItem(strName)
	if Item then rawset(tbl, strName, Item) end
	return Item
end})

function GM:GetSocketTargets(ply)
	local tblTargets = {}
	local tblSeen = {}
	for strSlot, strItem in pairs(ply.Data and ply.Data.Paperdoll or {}) do
		local tblItem = ItemTable(strItem)
		if tblItem and self:GetFreeSockets(tblItem) > 0 and not tblSeen[strItem] then
			tblSeen[strItem] = true
			table.insert(tblTargets, {Item = strItem, Worn = true})
		end
	end
	for strItem, intAmount in pairs(ply.Data and ply.Data.Inventory or {}) do
		local tblItem = intAmount > 0 and ItemTable(strItem)
		if tblItem and self:GetFreeSockets(tblItem) > 0 and not tblSeen[strItem] then
			tblSeen[strItem] = true
			table.insert(tblTargets, {Item = strItem, Worn = false})
		end
	end
	table.sort(tblTargets, function(a, b)
		if a.Worn ~= b.Worn then return a.Worn end
		return (ItemTable(a.Item).PrintName or a.Item) < (ItemTable(b.Item).PrintName or b.Item)
	end)
	return tblTargets
end

function GM:GetGemRemoveFee(tblItem)
	local intFee = 0
	for _, strGem in ipairs(tblItem and tblItem.Gems or {}) do
		local tblGem = ItemTable(strGem)
		intFee = intFee + (tblGem and tblGem.SellPrice or 0)
	end
	return math.max(math.Round(intFee * self.Gems.RemoveFeeShare), 1)
end

if SERVER then
	local function SwapItem(ply, strOld, strNew)
		local tblWorn = ply:GetWornSlots(strOld)
		local strSlot = nil
		if ply:GetItem(strOld) - 1 < #tblWorn then strSlot = tblWorn[#tblWorn] end
		ply.NextSwitch = 0
		if not ply:RemoveItem(strOld, 1) then return false end
		if not ply:AddItem(strNew, 1) then
			ply:AddItem(strOld, 1)
			return false
		end
		if strSlot then
			ply.NextSwitch = 0
			ply:UseItem(strNew, strSlot)
		end
		return true
	end

	function Player:SocketGem(strGem, strTarget)
		local tblGem = ItemTable(strGem)
		local tblTarget = ItemTable(strTarget)
		if not GAMEMODE:IsGem(tblGem) or not tblTarget then return false end
		if not self:HasItem(strGem, 1) or not self:HasItem(strTarget, 1) then return false end
		if GAMEMODE:GetFreeSockets(tblTarget) <= 0 then
			self:ChatPrint((tblTarget.PrintName or strTarget) .. " has no free socket.")
			return false
		end
		local strNew = GAMEMODE:GetSocketedName(strTarget, strGem)
		if not ItemTable(strNew) then return false end
		if not self:RemoveItem(strGem, 1) then return false end
		if not SwapItem(self, strTarget, strNew) then
			self:AddItem(strGem, 1)
			return false
		end
		self:ChatPrint("You set the " .. tblGem.PrintName .. " into " .. (tblTarget.PrintName or strTarget) .. ".")
		self:EmitSound("physics/glass/glass_impact_soft" .. math.random(1, 3) .. ".wav", 60, 110)
		return true
	end

	function Player:RemoveGems(strItem)
		local tblItem = ItemTable(strItem)
		if not tblItem or not tblItem.Gems or not self:HasItem(strItem, 1) then return false end
		local intFee = GAMEMODE:GetGemRemoveFee(tblItem)
		if not self:HasItem("money", intFee) then
			self:ChatPrint("Prising the gems out costs " .. intFee .. " denars.")
			return false
		end
		if not self:HasRoomFor({}, 0.1 * #tblItem.Gems) then
			self:ChatPrint("You are carrying too much.")
			return false
		end
		if not SwapItem(self, strItem, tblItem.SocketParent) then return false end
		self:RemoveItem("money", intFee)
		for _, strGem in ipairs(tblItem.Gems) do self:AddItem(strGem, 1) end
		self:ChatPrint("You prise the gems out of " .. (tblItem.PrintName or strItem) .. " for " .. intFee .. " denars.")
		return true
	end

	concommand.Add("UD_SocketGem", function(ply, command, args)
		if not IsValid(ply) or not args[1] or not args[2] then return end
		ply:SocketGem(tostring(args[1]), tostring(args[2]))
	end)

	concommand.Add("UD_RemoveGems", function(ply, command, args)
		if not IsValid(ply) or not args[1] then return end
		ply:RemoveGems(tostring(args[1]))
	end)

	function GM:RollGem(intGrade)
		local Kind = self.GemKinds[math.random(#self.GemKinds)]
		return self:GetGemName(Kind.Key, math.Clamp(intGrade, 1, #self.GemGrades))
	end

	function GM:RollMiningGem(ply, Ore, vecPos)
		if not IsValid(ply) or not Ore then return end
		local flChance = self.Gems.MiningChance * (1 + (ply:GetStat("stat_luck") or 0) / 45)
		if math.Rand(0, 100) > flChance then return end
		local strGem = self:RollGem(Ore.Band or 1)
		if ply:AddItem(strGem, 1) then
			ply:ChatPrint("You find a gem in the rock: " .. ItemTable(strGem).PrintName .. "!")
			if vecPos then ply:CreateIndicator("+1_" .. string.gsub(ItemTable(strGem).PrintName, " ", "_"), vecPos + Vector(0, 0, 45), "purple") end
		end
	end

	hook.Add("OnNPCKilled", "UD_GemDrops", function(entNPC, entKiller)
		if not IsValid(entNPC) or not IsValid(entKiller) or not entKiller:IsPlayer() or entNPC.UD_Summoned then return end
		local tblNPC = NPCTable(entNPC:GetNWString("npc", ""))
		if not tblNPC or not tblNPC.EliteLoot then return end
		local flChance = (tblNPC.EliteLoot.Rolls or 1) >= 2 and GAMEMODE.Gems.BossChance or GAMEMODE.Gems.EliteChance
		if math.Rand(0, 100) > flChance then return end
		local strGem = GAMEMODE:RollGem(GAMEMODE:GetCraftBand(entNPC:GetNWInt("level", 1)))
		local entLoot = CreateWorldItem(strGem, 1, entNPC:GetPos() + Vector(0, 0, 30))
		if IsValid(entLoot) then entLoot:SetOwner(entKiller) end
	end)

	concommand.Add("UD_Dev_GiveGems", function(ply, command, args)
		if not IsValid(ply) or not (ply:IsAdmin() or game.SinglePlayer()) then return end
		local intGrade = math.Clamp(math.floor(tonumber(args[1]) or 1), 1, #GAMEMODE.GemGrades)
		for _, Kind in ipairs(GAMEMODE.GemKinds) do ply:AddItem(GAMEMODE:GetGemName(Kind.Key, intGrade), 1) end
	end)
end

if CLIENT then
	function GM:AddSocketTooltip(strTooltip, tblItem)
		local intSockets = self:GetSocketCount(tblItem)
		if intSockets <= 0 then return strTooltip end
		local tblGems = tblItem.Gems or {}
		for intSocket = 1, intSockets do
			local tblGem = tblGems[intSocket] and ItemTable(tblGems[intSocket])
			if tblGem then
				local tblParts = {}
				for strStat, intAmount in pairs(tblGem.GemBuffs or {}) do
					local tblStat = StatTable(strStat)
					table.insert(tblParts, "+" .. intAmount .. " " .. (tblStat and tblStat.PrintName or strStat))
				end
				strTooltip = strTooltip .. "\nSocket: " .. tblGem.PrintName .. " (" .. table.concat(tblParts, ", ") .. ")"
			else
				strTooltip = strTooltip .. "\nEmpty socket"
			end
		end
		return strTooltip
	end

	function GM:AddSocketMenu(Menu, tblItem)
		if not Menu or not tblItem then return end
		if self:IsGem(tblItem) then
			local tblTargets = self:GetSocketTargets(LocalPlayer())
			if #tblTargets == 0 then
				Menu:AddOption("No item with a free socket"):SetEnabled(false)
				return
			end
			local SubMenu = Menu:AddSubMenu("Socket into ...")
			for _, Target in ipairs(tblTargets) do
				local tblTarget = ItemTable(Target.Item)
				SubMenu:AddOption((tblTarget.PrintName or Target.Item) .. (Target.Worn and " (worn)" or ""), function()
					RunConsoleCommand("UD_SocketGem", tblItem.Name, Target.Item)
				end)
			end
		elseif tblItem.Gems and #tblItem.Gems > 0 then
			Menu:AddOption("Remove gems (" .. self:GetGemRemoveFee(tblItem) .. " denars)", function()
				RunConsoleCommand("UD_RemoveGems", tblItem.Name)
			end)
		end
	end
end
