local Player = FindMetaTable("Player")

GM.Rest = {
	Duration = 1800,
	BedMultiplier = 1.5,
	SleepTime = 6,
	CombatTimeout = 10,
	NotTiredAbove = 300,
	EnemyRadius = 700,
	UseDistance = 110,
	ExpBonus = 25,
	RegenPercent = 1,
	RegenInterval = 3,
}

GM.RestBeds = {
	["models/skyrimznalecc/bedroll01.mdl"] = true,
	["models/props/tools/humans/campbed01.mdl"] = true,
	["models/props/furnitures/l10/l10_bed_01.mdl"] = true,
	["models/props/archi/l02/l02_bed.mdl"] = true,
	["models/props/furnitures/gob/l6_mattress/l6_mattress.mdl"] = true,
}

RegisterBuff({
	Name = "buff_rested",
	PrintName = "Rested",
	Icon = "icon16/house.png",
	Category = "rest",
	Duration = GM.Rest.Duration,
	KeepOnDeath = true,
	Desc = function(Power) return math.Round(GAMEMODE.Rest.ExpBonus * Power) .. "% more experience and slow healing out of combat" end,
	Hooks = {
		exp_mod = function(ply, Power, Amount)
			return Amount * (1 + GAMEMODE.Rest.ExpBonus * Power / 100)
		end,
	},
	Think = function(self, ply, Power)
		if not ply:IsOutOfCombat(8) or ply:Health() >= ply:GetMaximumHealth() then return end
		if (ply.UD_NextRestedRegen or 0) > CurTime() then return end
		ply.UD_NextRestedRegen = CurTime() + GAMEMODE.Rest.RegenInterval
		ply:HealPercent(GAMEMODE.Rest.RegenPercent)
	end,
})

if SERVER then
	function Player:IsOutOfCombat(flSeconds)
		return CurTime() - (self.UD_LastDamaged or -1000) >= (flSeconds or GAMEMODE.Rest.CombatTimeout)
	end

	function Player:HealPercent(flPercent)
		if not self:Alive() then return end
		local intMax = self:GetMaximumHealth()
		if self:Health() >= intMax then return end
		local intAmount = math.max(math.Round(intMax * flPercent / 100), 1)
		self:SetHealth(math.min(self:Health() + intAmount, intMax))
	end

	function Player:IsInCombat()
		if not self:IsOutOfCombat(GAMEMODE.Rest.CombatTimeout) then return true end
		for _, ent in ipairs(ents.FindInSphere(self:GetPos(), GAMEMODE.Rest.EnemyRadius)) do
			if ent:IsNPC() and ent:GetEnemy() == self then return true end
		end
		return false
	end

	local function RestTimerName(ply)
		return "UD_Rest_" .. ply:EntIndex()
	end

	function Player:StartRest(flMultiplier)
		if self.UD_Resting or not self:Alive() or not self.Loaded then return false end
		if self:IsInCombat() then
			self:CreateNotification("You cannot rest with enemies nearby")
			return false
		end
		if self:GetBuffTimeLeft("buff_rested") > GAMEMODE.Rest.NotTiredAbove then
			self:CreateNotification("You are not tired yet")
			return false
		end
		self.UD_Resting = true
		self.UD_RestMultiplier = flMultiplier or 1
		self:Freeze(true)
		self:ScreenFade(bit.bor(SCREENFADE.OUT, SCREENFADE.STAYOUT), Color(0, 0, 0, 255), 1.5, 0)
		self:CreateNotification("You lie down and close your eyes...")
		timer.Create(RestTimerName(self), GAMEMODE.Rest.SleepTime, 1, function()
			if IsValid(self) then self:FinishRest() end
		end)
		return true
	end

	function Player:FinishRest()
		if not self.UD_Resting then return end
		self.UD_Resting = false
		self:Freeze(false)
		self:ScreenFade(bit.bor(SCREENFADE.IN, SCREENFADE.PURGE), Color(0, 0, 0, 255), 2, 0)
		self:AddBuff("buff_rested", GAMEMODE.Rest.Duration * (self.UD_RestMultiplier or 1), 1)
		self:SetHealth(self:GetMaximumHealth())
		if (self.UD_RestMultiplier or 1) > 1 then
			self:CreateNotification("You wake up well rested")
		else
			self:CreateNotification("You wake up rested")
		end
	end

	function Player:InterruptRest()
		if not self.UD_Resting then return end
		timer.Remove(RestTimerName(self))
		self.UD_Resting = false
		self:Freeze(false)
		self:ScreenFade(bit.bor(SCREENFADE.IN, SCREENFADE.PURGE), Color(80, 0, 0, 255), 0.6, 0)
		self:CreateNotification("Your rest was interrupted!")
	end

	hook.Add("PlayerDeath", "UD_InterruptRestOnDeath", function(ply)
		if ply.UD_Resting then
			timer.Remove(RestTimerName(ply))
			ply.UD_Resting = false
			ply:ScreenFade(bit.bor(SCREENFADE.IN, SCREENFADE.PURGE), Color(0, 0, 0, 255), 0.5, 0)
		end
	end)

	hook.Add("PlayerDisconnected", "UD_ClearRestTimer", function(ply)
		timer.Remove(RestTimerName(ply))
	end)

	hook.Add("KeyPress", "UD_RestInBed", function(ply, intKey)
		if intKey ~= IN_USE or ply.UD_Resting then return end
		local trace = ply:GetEyeTrace()
		local ent = trace.Entity
		if not IsValid(ent) or not GAMEMODE.RestBeds[string.lower(ent:GetModel() or "")] then return end
		if trace.HitPos:DistToSqr(ply:EyePos()) > GAMEMODE.Rest.UseDistance ^ 2 then return end
		ply:StartRest(GAMEMODE.Rest.BedMultiplier)
	end)
end
