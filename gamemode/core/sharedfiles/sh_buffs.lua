local Player = FindMetaTable("Player")

GM.DataBase.Buffs = GM.DataBase.Buffs or {}
GM.MaxFoodBuffs = 1

function RegisterBuff(tblBuff)
	tblBuff.Category = tblBuff.Category or "combat"
	tblBuff.Duration = tblBuff.Duration or 10
	GM.DataBase.Buffs[tblBuff.Name] = tblBuff
end

function BuffTable(strBuff)
	return GAMEMODE.DataBase.Buffs[strBuff]
end

function Player:GetActiveBuffs()
	local tblActive = {}
	for strBuff, tblInfo in pairs(self.UD_Buffs or {}) do
		if (tblInfo.Expires or 0) > CurTime() then tblActive[strBuff] = tblInfo end
	end
	return tblActive
end

function Player:HasBuff(strBuff)
	local tblInfo = self.UD_Buffs and self.UD_Buffs[strBuff]
	return tblInfo ~= nil and (tblInfo.Expires or 0) > CurTime()
end

function Player:GetBuffPower(strBuff)
	if not self:HasBuff(strBuff) then return 0 end
	return self.UD_Buffs[strBuff].Power or 0
end

function Player:GetBuffTimeLeft(strBuff)
	if not self:HasBuff(strBuff) then return 0 end
	return math.max(self.UD_Buffs[strBuff].Expires - CurTime(), 0)
end

function GetBuffDescription(tblBuff, flPower)
	if isfunction(tblBuff.Desc) then return tblBuff.Desc(flPower or 1) end
	return tblBuff.Desc or ""
end

if SERVER then
	util.AddNetworkString("UD_UpdateBuff")

	local function BuffTimerName(ply, strBuff)
		return "UD_Buff_" .. ply:EntIndex() .. "_" .. strBuff
	end

	local function SendBuff(ply, strBuff, flTimeLeft, flPower)
		net.Start("UD_UpdateBuff")
			net.WriteString(strBuff)
			net.WriteFloat(flTimeLeft)
			net.WriteFloat(flPower or 0)
		net.Send(ply)
	end

	local function ResolveStats(tblBuff, ply, flPower)
		local tblStats = tblBuff.Stats
		if isfunction(tblStats) then return tblStats(ply, flPower) or {} end
		local tblResult = {}
		for strStat, Amount in pairs(tblStats or {}) do
			tblResult[strStat] = Amount * flPower
		end
		return tblResult
	end

	local function UnapplyBuff(ply, strBuff)
		local tblInfo = ply.UD_Buffs and ply.UD_Buffs[strBuff]
		if not tblInfo then return end
		for strStat, intAmount in pairs(tblInfo.Stats or {}) do
			ply:AddStat(strStat, -intAmount)
		end
		if (tblInfo.MoveSpeed or 0) ~= 0 and ply.AddMoveSpeed then ply:AddMoveSpeed(-tblInfo.MoveSpeed) end
		ply.UD_Buffs[strBuff] = nil
		timer.Remove(BuffTimerName(ply, strBuff))
	end

	function Player:RemoveBuff(strBuff)
		if not self.UD_Buffs or not self.UD_Buffs[strBuff] then return end
		local tblInfo = self.UD_Buffs[strBuff]
		UnapplyBuff(self, strBuff)
		local tblBuff = BuffTable(strBuff)
		if tblBuff and tblBuff.OnExpire then tblBuff:OnExpire(self, tblInfo.Power) end
		SendBuff(self, strBuff, 0, 0)
	end

	local function MakeRoomForCategory(ply, tblBuff, strBuff)
		if tblBuff.Category ~= "food" then return end
		local intMax = GAMEMODE.MaxFoodBuffs
		if ply.CallSkillHook then intMax = ply:CallSkillHook("max_food_buffs", intMax) end
		local tblFood = {}
		for strActive, tblInfo in pairs(ply.UD_Buffs or {}) do
			local tblActiveBuff = BuffTable(strActive)
			if strActive ~= strBuff and tblActiveBuff and tblActiveBuff.Category == "food" then
				table.insert(tblFood, {Name = strActive, Expires = tblInfo.Expires})
			end
		end
		table.sort(tblFood, function(a, b) return a.Expires < b.Expires end)
		while #tblFood >= intMax and #tblFood > 0 do
			ply:RemoveBuff(table.remove(tblFood, 1).Name)
		end
	end

	function Player:AddBuff(strBuff, flDuration, flPower)
		local tblBuff = BuffTable(strBuff)
		if not tblBuff or not IsValid(self) then return false end
		flPower = flPower or 1
		flDuration = flDuration or tblBuff.Duration
		if self.CallSkillHook then flDuration = self:CallSkillHook("buff_duration_mod", flDuration, strBuff, tblBuff.Category) end
		if not flDuration or flDuration <= 0 then return false end
		self.UD_Buffs = self.UD_Buffs or {}

		local tblExisting = self.UD_Buffs[strBuff]
		if tblExisting and tblExisting.Power == flPower and not isfunction(tblBuff.Stats) then
			tblExisting.Expires = math.max(tblExisting.Expires, CurTime() + flDuration)
			tblExisting.Duration = math.max(tblExisting.Duration, flDuration)
			local flTimeLeft = tblExisting.Expires - CurTime()
			timer.Create(BuffTimerName(self, strBuff), flTimeLeft, 1, function()
				if IsValid(self) then self:RemoveBuff(strBuff) end
			end)
			SendBuff(self, strBuff, flTimeLeft, flPower)
			return true
		end

		if tblExisting then UnapplyBuff(self, strBuff) end
		MakeRoomForCategory(self, tblBuff, strBuff)

		local tblInfo = {Power = flPower, Expires = CurTime() + flDuration, Duration = flDuration, Stats = {}, MoveSpeed = 0}
		for strStat, Amount in pairs(ResolveStats(tblBuff, self, flPower)) do
			local intAmount = math.Round(Amount)
			if intAmount ~= 0 and StatTable(strStat) then
				self:AddStat(strStat, intAmount)
				tblInfo.Stats[strStat] = intAmount
			end
		end
		if tblBuff.MoveSpeed and self.AddMoveSpeed then
			tblInfo.MoveSpeed = math.Round(tblBuff.MoveSpeed * flPower)
			self:AddMoveSpeed(tblInfo.MoveSpeed)
		end
		self.UD_Buffs[strBuff] = tblInfo
		if tblBuff.OnApply then tblBuff:OnApply(self, flPower) end
		timer.Create(BuffTimerName(self, strBuff), flDuration, 1, function()
			if IsValid(self) then self:RemoveBuff(strBuff) end
		end)
		SendBuff(self, strBuff, flDuration, flPower)
		return true
	end

	function Player:ClearBuffs(boolDeath)
		for strBuff in pairs(self.UD_Buffs or {}) do
			local tblBuff = BuffTable(strBuff)
			if not boolDeath or not tblBuff or not tblBuff.KeepOnDeath then
				self:RemoveBuff(strBuff)
			end
		end
	end

	function Player:ThinkBuffs()
		for strBuff, tblInfo in pairs(self:GetActiveBuffs()) do
			local tblBuff = BuffTable(strBuff)
			if tblBuff and tblBuff.Think then tblBuff:Think(self, tblInfo.Power) end
		end
	end

	hook.Add("PlayerDeath", "UD_ClearBuffsOnDeath", function(ply)
		ply:ClearBuffs(true)
	end)

	hook.Add("PlayerDisconnected", "UD_ClearBuffTimers", function(ply)
		for strBuff in pairs(ply.UD_Buffs or {}) do
			timer.Remove(BuffTimerName(ply, strBuff))
		end
	end)
else
	net.Receive("UD_UpdateBuff", function()
		local strBuff = net.ReadString()
		local flTimeLeft = net.ReadFloat()
		local flPower = net.ReadFloat()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		ply.UD_Buffs = ply.UD_Buffs or {}
		if flTimeLeft <= 0 then
			ply.UD_Buffs[strBuff] = nil
		else
			ply.UD_Buffs[strBuff] = {Power = flPower, Expires = CurTime() + flTimeLeft, Duration = flTimeLeft}
		end
	end)
end
