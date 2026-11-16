local Player = FindMetaTable("Player")

function Player:IsMelee()
	if ItemTable(self:GetSlot("slot_primaryweapon")) then
		return ItemTable(self:GetSlot("slot_primaryweapon")).Melee
	end
	return
end

function Player:GetActiveAmmoType()
	if ItemTable(self:GetSlot("slot_primaryweapon")) and ItemTable(self:GetSlot("slot_primaryweapon")).AmmoType then
		return ItemTable(self:GetSlot("slot_primaryweapon")).AmmoType
	end
	return
end

function Player:IsDonator()
	if self:IsUserGroup("donator") then
		return true
	else
		return false
	end
end

function Player:GetMaximumHealth()
	return self:GetStat("stat_maxhealth")
end

function Player:GetMaxWeight()
	return self:GetStat("stat_maxweight")
end

function Player:GetArmorRating()
	local intGearArmor = 0
	if not self.Data then return end
	for strSlot, strItem in pairs(self.Data.Paperdoll or {}) do
		local tblItemTable = ItemTable(strItem)
		if tblItemTable and tblItemTable.Armor then
			intGearArmor = intGearArmor + tblItemTable.Armor
		end
	end
	if self.CallSkillHook then intGearArmor = self:CallSkillHook("armor_mod", intGearArmor) or intGearArmor end
	return 1 + math.Round(intGearArmor)
end

if CLIENT then
	function Player:FollowPlayer(args)
		if not args then return end
		if not args[1] then return end
		LocalPlayer().SFollowing = false
		local function Follow()
			local OtherPlayer = ents.GetByIndex(args[1])
			if IsValid(OtherPlayer) then
				if LocalPlayer():GetPos():Distance(OtherPlayer:GetPos()) > 80 then
					local AimVec = OtherPlayer:GetPos() - LocalPlayer():GetPos()
					LocalPlayer():SetEyeAngles(AimVec:Angle())
					RunConsoleCommand("+forward")
				elseif LocalPlayer():GetPos():Distance(OtherPlayer:GetPos()) < 80 then
					RunConsoleCommand("-forward")
				end
				if LocalPlayer():KeyPressed( IN_FORWARD ) or LocalPlayer():KeyPressed( IN_MOVELEFT ) or LocalPlayer():KeyPressed( IN_MOVERIGHT ) or LocalPlayer():KeyPressed( IN_BACK ) then
					LocalPlayer():StopFollowing()
				end
				LocalPlayer().IsFollowingPlayer = true
				if LocalPlayer().SFollowing then return end
				timer.Simple(0.1, Follow, args[1])
			end
		end
		Follow()
	end
	concommand.Add("UD_FollowPlayer", function(ply, command, args) ply:FollowPlayer(args) end)

	function Player:StopFollowing()
		if LocalPlayer().IsFollowingPlayer then
			LocalPlayer().SFollowing = true
			RunConsoleCommand("-forward")
			LocalPlayer().IsFollowingPlayer = false
		end
	end
	concommand.Add("UD_StopFollowingPlayer", function(ply, command, args) ply:StopFollowing() end)
end

if SERVER then

	function Player:SearchQuestProp(Ent, strModel, strItem, strAmount)
		if not IsValid(Ent) then return end
		if string.lower(Ent:GetModel() or "") == string.lower(strModel) then
			if self:QuestItem(strItem) then
				local tblItemTable = ItemTable(strItem)
				self:CreateNotification("Searching")
				self:Freeze( true )
				timer.Simple(5, function()
					if not IsValid(self) then return end
					self:CreateNotification("Found " .. tblItemTable.PrintName)
					self:AddItem(strItem, strAmount)
					self:Freeze( false )
				end)
			end
		end
	end

	function Player:SearchWorldProp(Ent, strModel, strItem, strAmount, strModelChanging)
		if not IsValid(Ent) then return end
		if string.lower(Ent:GetModel() or "") == string.lower(strModel) then
			if not Ent.IsBeingSearched then
				self:CreateNotification("Searching")
				Ent.IsBeingSearched = true
				self:Freeze( true )
				timer.Simple(3, function()
					if not IsValid(self) then return end
					if not IsValid(Ent) then
						self:Freeze( false )
						return
					end
					if math.random(1, 10) == 1 then
						local FoundItem = table.Random(strItem)
						local tblItemTable = ItemTable(FoundItem)
						if FoundItem == "money" then strAmount = math.random(1,20) end
						self:CreateNotification("Found x" .. strAmount .. " " .. tblItemTable.PrintName)
						self:AddItem(FoundItem, strAmount)
					else
						self:CreateNotification("Nothing is in here!")
					end
					if strModelChanging then
						Ent:EmitSound( Sound("items/ammocrate_open.wav") )
						Ent:SetModel(strModelChanging)
					else
						self:Freeze( false )
						Ent.IsBeingSearched = false
					end
				end)
				timer.Simple(8, function()
					if IsValid(self) then self:Freeze( false ) end
					if IsValid(Ent) then
						Ent.IsBeingSearched = false
						if strModelChanging then
							Ent:EmitSound( Sound("items/ammocrate_close.wav") )
							Ent:SetModel(strModel)
						end
					end
				end)
			end
		end
	end

	local Cheers = {
		"Huzzah!",
		"Well_Fought!",
		"For_Dunmarrow!",
		"The_Crowns_Rise!",
		"Onward!",
		"Glory_To_The_Trifecta!",
		"A_True_Rebel!",
	}

	local Colors = {
		"purple",
		"blue",
		"orange",
		"green",
		"white"
	}

	local function TierUnlockedBetween(intFrom, intTo)
		for intTier, intLevel in ipairs(GAMEMODE.SkillTierLevels or {}) do
			if intLevel > intFrom and intLevel <= intTo then return intTier end
		end
	end

	function Player:GiveExp(amount, boolShowExp, boolNoBonus)
		amount = tonumber(amount) or 0
		if amount > 0 and not boolNoBonus then
			amount = math.Round(self:CallSkillHook("exp_mod", amount) or amount)
		end
		local intCurrentExp = tonumber(self:GetNWInt("exp")) or 0
		local intPreExpLevel = self:GetLevel()
		local intMaxExp = toExp(GAMEMODE.MaxLevel)
		if amount > 0 and intCurrentExp >= intMaxExp then return end
		if intCurrentExp + amount < 0 then return end
		local intTotal = math.Clamp(intCurrentExp + amount, toExp(intPreExpLevel), intMaxExp)
		self:SetNWInt("exp", intTotal)
		if boolShowExp and intTotal > intCurrentExp then
			self:CreateIndicator("+_" .. (intTotal - intCurrentExp) .. "_Exp", self:GetPos() + Vector(0, 0, 70), "green")
		end
		local intPostExpLevel = self:GetLevel()
		if intPreExpLevel < intPostExpLevel then
			self:ApplyLevelGrowth(intPreExpLevel, intPostExpLevel)
			hook.Call("UD_Hook_PlayerLevelUp", GAMEMODE, self, intPostExpLevel - intPreExpLevel)
			self:SetHealth(self:GetMaximumHealth())
			self:CreateIndicator("Level_" .. intPostExpLevel, self:GetPos() + Vector(0, 0, 70), "green", true)
			for i = 1, 3 do
				self:CreateIndicator(Cheers[math.random(1, #Cheers)], self:GetPos() + Vector(0, 0, 70), Colors[math.random(1, #Colors)], true)
			end
			if intPostExpLevel >= GAMEMODE.MaxLevel then
				self:CreateNotification("You have reached the highest level, " .. GAMEMODE.MaxLevel .. "!")
			else
				self:CreateNotification("You are now level " .. intPostExpLevel .. ". Unspent skill points: " .. self:GetNWInt("SkillPoints"))
			end
			if TierUnlockedBetween(intPreExpLevel, intPostExpLevel) then
				self:CreateNotification("New skills are available to learn")
			end
		end
	end

	local function FindTarget(ply, strName)
		if not strName or strName == "" then return IsValid(ply) and ply or nil end
		strName = string.lower(strName)
		for _, plyTarget in ipairs(player.GetAll()) do
			if string.find(string.lower(plyTarget:Nick()), strName, 1, true) then return plyTarget end
		end
	end

	function Player:SetLevel(intLevel)
		intLevel = math.Clamp(math.floor(tonumber(intLevel) or 1), 1, GAMEMODE.MaxLevel)
		local intPreLevel = self:GetLevel()
		self:SetNWInt("exp", toExp(intLevel))
		self:ApplyLevelGrowth(intPreLevel, intLevel)
		self:SetNWInt("SkillPoints", self:GetDeservedSkillPoints())
		self:SetHealth(self:GetMaximumHealth())
		self:SaveGame()
	end

	concommand.Add("UD_Admin_GiveExp", function(ply, command, args)
		if IsValid(ply) and not ply:IsAdmin() then return end
		local plyTarget = FindTarget(ply, args[2])
		if not IsValid(plyTarget) or not plyTarget.Loaded then return end
		plyTarget:GiveExp(tonumber(args[1]) or 0, true, true)
	end)

	concommand.Add("UD_Admin_SetLevel", function(ply, command, args)
		if IsValid(ply) and not ply:IsAdmin() then return end
		local plyTarget = FindTarget(ply, args[2])
		if not IsValid(plyTarget) or not plyTarget.Loaded then return end
		plyTarget:SetLevel(args[1])
	end)

	function GM:PlayerDeath(victim, weapon, killer)
		victim:Freeze(true)
		timer.Simple(10, function()
			if IsValid(victim) then
				victim:Freeze(false)
				victim:ConCommand("+attack")
				timer.Simple(0.1, function() if IsValid(victim) then victim:ConCommand("-attack") end end)
			end
		end)
		if killer:IsNPC() and victim:IsPlayer() then
			if killer.Race == victim.Race then
				killer:AddEntityRelationship(victim, GAMEMODE.RelationLike, 99)
			end
		end
	end

	local function PlayerAdjustDamage(entVictim, dmg) --entInflictor, entAttacker, amount, tblDamageInfo)
		if not entVictim:IsPlayer() then return end
		local entAttacker = dmg:GetAttacker()
		if not entAttacker:IsPlayer() and entAttacker:GetOwner():IsPlayer() then
			entAttacker = entAttacker:GetOwner()
		end
		local clrDisplayColor = "red"
		local tblNPCTable = NPCTable(entAttacker:GetNWString("npc"))
		if entAttacker:IsPlayer() then
			dmg:SetDamage(0)
		end
		if tblNPCTable then
			for strNPC,_ in pairs(GAMEMODE.DataBase.NPCs or {}) do
				local tblNPCTable = NPCTable(strNPC)
				if tblNPCTable.DamageCallBack and entVictim and entAttacker.Name and entAttacker.Name ==  tblNPCTable.Name then
					tblNPCTable:DamageCallBack(entAttacker, entVictim)
				end
			end
			local Damage = GAMEMODE:GetNPCHitDamage(tblNPCTable, entAttacker:GetNWInt("level"), entVictim) * math.Rand(0.9, 1.1)
			if tblNPCTable.Race == "human" then Damage = 0 end
			entVictim.UD_BlockedHit = nil
			if Damage > 0 then
				Damage = entVictim:CallSkillHook("damage_taken_mod", Damage, entAttacker) or Damage
			end
			Damage = math.Clamp(math.floor(Damage + 0.5), 0, 999999)
			dmg:SetDamage(Damage)
			if Damage > 0 then
				entVictim.UD_LastDamaged = CurTime()
				if entVictim.UD_Resting then entVictim:InterruptRest() end
				entVictim:CreateIndicator(Damage, dmg:GetDamagePosition(), clrDisplayColor)
			elseif entVictim.UD_BlockedHit then
				entVictim:CreateIndicator("Blocked!", dmg:GetDamagePosition(), "blue")
			else
				entVictim:CreateIndicator("Miss!", dmg:GetDamagePosition(), "orange")
			end
			entVictim.UD_BlockedHit = nil
		elseif dmg:GetDamage() > 0 and not entAttacker:IsPlayer() then
			entVictim.UD_LastDamaged = CurTime()
			if entVictim.UD_Resting then entVictim:InterruptRest() end
		end
	end
	hook.Add("EntityTakeDamage", "PlayerAdjustDamage", PlayerAdjustDamage)
end
