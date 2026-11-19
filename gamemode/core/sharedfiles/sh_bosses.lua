GM.BossBarRange = 1200

function GM:GetNPCDamageMod(entNPC, tblNPC)
	local flMod = 1
	if tblNPC and tblNPC.Race == "undead" and self:IsNight() then flMod = flMod * self.DayNight.NightUndeadDamage end
	if not IsValid(entNPC) then return flMod end
	flMod = flMod * (entNPC.UD_DamageMod or 1) * (entNPC.UD_AbilityDamageMod or 1)
	if (entNPC.UD_WarcryUntil or 0) > CurTime() then flMod = flMod * (entNPC.UD_WarcryMod or 1) end
	return flMod
end

function GM:GetNPCDamageTakenMod(entNPC)
	if IsValid(entNPC) and (entNPC.UD_GuardUntil or 0) > CurTime() then return 1 - (entNPC.UD_GuardReduction or 0) end
	return 1
end

if SERVER then
	util.AddNetworkString("UD_BossTelegraph")

	local function Telegraph(vecPos, flRadius, flTime, clrColor)
		net.Start("UD_BossTelegraph")
		net.WriteVector(vecPos)
		net.WriteFloat(flRadius)
		net.WriteFloat(flTime)
		net.WriteColor(clrColor or Color(220, 40, 30))
		net.Broadcast()
	end

	local function TellNearby(entNPC, strText, clrColor)
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetPos():DistToSqr(entNPC:GetPos()) < GAMEMODE.BossBarRange ^ 2 then
				GAMEMODE:Announce(strText, clrColor or Color(255, 120, 90), nil, ply)
			end
		end
	end

	local function NPCName(entNPC)
		local tblNPC = NPCTable(entNPC:GetNWString("npc", ""))
		return tblNPC and tblNPC.PrintName or "The enemy"
	end

	local function GroundAt(vecPos)
		local trc = util.TraceLine({start = vecPos + Vector(0, 0, 64), endpos = vecPos - Vector(0, 0, 200), mask = MASK_NPCSOLID_BRUSHONLY})
		if trc.Hit and not trc.StartSolid then return trc.HitPos + Vector(0, 0, 4) end
	end

	local function Dust(vecPos, flScale)
		local Effect = EffectData()
		Effect:SetOrigin(vecPos)
		Effect:SetScale(flScale or 60)
		Effect:SetMagnitude(flScale or 60)
		util.Effect("ThumperDust", Effect, true, true)
	end

	local Abilities = {}

	Abilities.slam = function(entNPC, Ability, entEnemy)
		if entNPC:GetPos():Distance(entEnemy:GetPos()) > (Ability.Range or 220) then return false end
		local vecPos = entNPC:GetPos()
		local flRadius = Ability.Radius or 180
		local flWindup = Ability.Windup or 1.2
		Telegraph(vecPos, flRadius, flWindup)
		entNPC:EmitSound(Ability.Sound or "weapons/iceaxe/iceaxe_swing1.wav", 85, 65)
		entNPC:StopMoving()
		entNPC.UD_HoldUntil = CurTime() + flWindup
		timer.Simple(flWindup, function()
			if not IsValid(entNPC) or entNPC:Health() <= 0 then return end
			Dust(vecPos, flRadius / 3)
			sound.Play("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav", vecPos, 90, 80, 1)
			util.ScreenShake(vecPos, 8, 40, 0.8, flRadius * 2)
			entNPC.UD_AbilityDamageMod = Ability.Damage or 1.6
			for _, ply in ipairs(player.GetAll()) do
				if ply:Alive() and ply:GetPos():Distance(vecPos) <= flRadius then
					local Damage = DamageInfo()
					Damage:SetAttacker(entNPC)
					Damage:SetInflictor(entNPC)
					Damage:SetDamage(1)
					Damage:SetDamageType(DMG_CLUB)
					Damage:SetDamagePosition(ply:GetPos() + Vector(0, 0, 40))
					ply:TakeDamageInfo(Damage)
					ply:SetVelocity((ply:GetPos() - vecPos):GetNormalized() * 250 + Vector(0, 0, 180))
				end
			end
			entNPC.UD_AbilityDamageMod = nil
		end)
		return true
	end

	Abilities.enrage = function(entNPC, Ability)
		entNPC.UD_DamageMod = (entNPC.UD_DamageMod or 1) * (Ability.Damage or 1.5)
		entNPC:SetNWBool("UD_Enraged", true)
		entNPC:EmitSound(Ability.Sound or "npc/antlion_guard/angry1.wav", 90, 90)
		TellNearby(entNPC, Ability.Line or (NPCName(entNPC) .. " flies into a rage!"))
		return true
	end

	Abilities.warcry = function(entNPC, Ability)
		local flRadius = Ability.Radius or 600
		local intRallied = 0
		for _, entAlly in ipairs(ents.FindInSphere(entNPC:GetPos(), flRadius)) do
			if entAlly:IsNPC() and entAlly.Race == entNPC.Race and entAlly:Health() > 0 then
				entAlly.UD_WarcryUntil = CurTime() + (Ability.Duration or 10)
				entAlly.UD_WarcryMod = Ability.Damage or 1.3
				entAlly:SetNWFloat("UD_WarcryUntil", entAlly.UD_WarcryUntil)
				intRallied = intRallied + 1
			end
		end
		entNPC:EmitSound(Ability.Sound or "ambient/alarms/warningbell1.wav", 90, 85)
		TellNearby(entNPC, Ability.Line or (NPCName(entNPC) .. " rallies his men!"), Color(255, 190, 90))
		return true
	end

	Abilities.guard = function(entNPC, Ability)
		entNPC.UD_GuardUntil = CurTime() + (Ability.Duration or 4)
		entNPC.UD_GuardReduction = Ability.Reduction or 0.7
		entNPC:SetNWFloat("UD_GuardUntil", entNPC.UD_GuardUntil)
		entNPC:EmitSound(Ability.Sound or "physics/metal/metal_solid_impact_hard1.wav", 85, 80)
		TellNearby(entNPC, Ability.Line or (NPCName(entNPC) .. " raises a guard. Wait it out!"), Color(140, 180, 255))
		return true
	end

	Abilities.blink = function(entNPC, Ability, entEnemy)
		local flDistance = entNPC:GetPos():Distance(entEnemy:GetPos())
		local vecTarget
		if Ability.Behind then
			if flDistance > (Ability.Range or 700) then return false end
			vecTarget = GroundAt(entEnemy:GetPos() - entEnemy:GetForward() * 70)
		else
			if flDistance > (Ability.Range or 220) then return false end
			for _ = 1, 6 do
				local vecTry = GroundAt(entNPC:GetPos() + Angle(0, math.random(0, 359), 0):Forward() * math.random(320, 520))
				if vecTry and vecTry:Distance(entEnemy:GetPos()) > 280 then
					vecTarget = vecTry
					break
				end
			end
		end
		if not vecTarget then return false end
		Dust(entNPC:GetPos(), 30)
		entNPC:EmitSound(Ability.Sound or "ambient/wind/wind_snippet2.wav", 85, 120)
		entNPC:SetPos(vecTarget)
		Dust(vecTarget, 30)
		if Ability.Behind then entNPC:SetAngles(Angle(0, (entEnemy:GetPos() - vecTarget):Angle().y, 0)) end
		return true
	end

	Abilities.summon = function(entNPC, Ability)
		GAMEMODE:SummonForNPC(entNPC, {NPC = Ability.NPC, Max = Ability.Max or Ability.Count or 2, PerCast = Ability.Count or 2, LevelOffset = Ability.LevelOffset or -3, Rise = Ability.Rise, Bound = Ability.Bound})
		if Ability.Sound then entNPC:EmitSound(Ability.Sound, 90, 100) end
		TellNearby(entNPC, Ability.Line or (NPCName(entNPC) .. " calls for aid!"))
		return true
	end

	local function RunAbilities(entNPC, tblAbilities)
		local entEnemy = entNPC:GetEnemy()
		if not IsValid(entEnemy) then return end
		local flHealth = entNPC:Health() / math.max(entNPC:GetMaxHealth(), 1)
		entNPC.UD_AbilityNext = entNPC.UD_AbilityNext or {}
		entNPC.UD_AbilityDone = entNPC.UD_AbilityDone or {}
		if (entNPC.UD_AbilityBusy or 0) > CurTime() then return end
		for intIndex, Ability in ipairs(tblAbilities) do
			local Run = Abilities[Ability.Type]
			if Run then
				if Ability.Health then
					if not entNPC.UD_AbilityDone[intIndex] and flHealth <= Ability.Health then
						entNPC.UD_AbilityDone[intIndex] = true
						Run(entNPC, Ability, entEnemy)
						entNPC.UD_AbilityBusy = CurTime() + 1.5
						return
					end
				else
					local flNext = entNPC.UD_AbilityNext[intIndex]
					if not flNext then
						entNPC.UD_AbilityNext[intIndex] = CurTime() + (Ability.FirstDelay or 4)
					elseif CurTime() >= flNext and Run(entNPC, Ability, entEnemy) then
						entNPC.UD_AbilityNext[intIndex] = CurTime() + (Ability.Interval or 12) * math.Rand(0.85, 1.15)
						entNPC.UD_AbilityBusy = CurTime() + (Ability.Windup or 1.2) + 0.3
						return
					end
				end
			end
		end
	end

	function GM:ApplyNPCBoss(entNPC, tblNPCTable)
		if not IsValid(entNPC) or not tblNPCTable then return end
		if tblNPCTable.Boss then entNPC:SetNWBool("UD_Boss", true) end
		local tblAbilities = tblNPCTable.Abilities
		if not tblAbilities then return end
		local strTimer = "UD_Boss_" .. entNPC:EntIndex()
		timer.Create(strTimer, 0.5, 0, function()
			if not IsValid(entNPC) or entNPC:Health() <= 0 then timer.Remove(strTimer) return end
			RunAbilities(entNPC, tblAbilities)
		end)
	end
end

if CLIENT then
	local tblTelegraphs = {}

	net.Receive("UD_BossTelegraph", function()
		table.insert(tblTelegraphs, {Pos = net.ReadVector(), Radius = net.ReadFloat(), Duration = net.ReadFloat(), Color = net.ReadColor(), Start = CurTime()})
	end)

	local function Disc(vecCenter, flRadius, clr)
		local intSegments = 40
		render.SetColorMaterial()
		mesh.Begin(MATERIAL_POLYGON, intSegments)
		for i = intSegments, 1, -1 do
			local flTheta = (i / intSegments) * math.pi * 2
			mesh.Position(vecCenter + Vector(math.cos(flTheta) * flRadius, math.sin(flTheta) * flRadius, 0))
			mesh.Color(clr.r, clr.g, clr.b, clr.a)
			mesh.AdvanceVertex()
		end
		mesh.End()
	end

	local function Ring(vecCenter, flRadius, clr)
		local intSegments = 48
		local vecPrev = vecCenter + Vector(flRadius, 0, 0)
		for i = 1, intSegments do
			local flTheta = (i / intSegments) * math.pi * 2
			local vecPoint = vecCenter + Vector(math.cos(flTheta) * flRadius, math.sin(flTheta) * flRadius, 0)
			render.DrawLine(vecPrev, vecPoint, clr, true)
			render.DrawLine(vecPrev + Vector(0, 0, 1), vecPoint + Vector(0, 0, 1), clr, true)
			vecPrev = vecPoint
		end
	end

	hook.Add("PostDrawTranslucentRenderables", "UD_BossTelegraphs", function(bDepth, bSkybox)
		if bDepth or bSkybox then return end
		for intIndex = #tblTelegraphs, 1, -1 do
			local T = tblTelegraphs[intIndex]
			local flProgress = (CurTime() - T.Start) / math.max(T.Duration, 0.01)
			if flProgress >= 1 then
				table.remove(tblTelegraphs, intIndex)
			else
				local vecCenter = T.Pos + Vector(0, 0, 3)
				Disc(vecCenter, T.Radius, Color(T.Color.r, T.Color.g, T.Color.b, 40))
				Disc(vecCenter + Vector(0, 0, 0.5), T.Radius * flProgress, Color(T.Color.r, T.Color.g, T.Color.b, 90))
				Ring(vecCenter + Vector(0, 0, 1), T.Radius, Color(T.Color.r, T.Color.g, T.Color.b, 255))
			end
		end
	end)

	hook.Add("Think", "UD_BossGlow", function()
		for _, entNPC in ipairs(UD_EntCache and UD_EntCache.NPCs or {}) do
			if IsValid(entNPC) and not entNPC:IsDormant() then
				local clr
				if entNPC:GetNWFloat("UD_GuardUntil", 0) > CurTime() then
					clr = Color(110, 160, 255)
				elseif entNPC:GetNWBool("UD_Enraged", false) then
					clr = Color(255, 50, 30)
				elseif entNPC:GetNWFloat("UD_WarcryUntil", 0) > CurTime() then
					clr = Color(255, 180, 60)
				end
				if clr then
					local Light = DynamicLight(entNPC:EntIndex() + 4096)
					if Light then
						Light.pos = entNPC:GetPos() + Vector(0, 0, 40)
						Light.r, Light.g, Light.b = clr.r, clr.g, clr.b
						Light.brightness = 2
						Light.Decay = 1000
						Light.Size = 160
						Light.DieTime = CurTime() + 0.2
					end
				end
			end
		end
	end)

	local BarBack = Color(20, 16, 12, 220)
	local BarFill = Color(170, 30, 25, 255)
	local BarText = Color(240, 225, 190)

	hook.Add("HUDPaint", "UD_BossBar", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		local entBoss, flBest = nil, GAMEMODE.BossBarRange ^ 2
		for _, entNPC in ipairs(UD_EntCache and UD_EntCache.NPCs or {}) do
			if IsValid(entNPC) and entNPC:GetNWBool("UD_Boss", false) and not entNPC:IsDormant() then
				local flDist = entNPC:GetPos():DistToSqr(ply:GetPos())
				if flDist < flBest then entBoss, flBest = entNPC, flDist end
			end
		end
		if not entBoss then return end
		local tblNPC = NPCTable(entBoss:GetNWString("npc", ""))
		local intMax = math.max(entBoss:GetNWInt("MaxHealth", 1), 1)
		local intHealth = math.Clamp(entBoss:GetNWInt("Health", intMax), 0, intMax)
		local w, h = math.min(ScrW() * 0.4, 520), 16
		local x, y = ScrW() / 2 - w / 2, 54
		draw.SimpleTextOutlined((tblNPC and tblNPC.PrintName or "Boss") .. "  Lv " .. entBoss:GetNWInt("level", 1), "UiBold", ScrW() / 2, y - 4, BarText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.RoundedBox(4, x - 2, y - 2, w + 4, h + 4, BarBack)
		draw.RoundedBox(4, x, y, w * intHealth / intMax, h, entBoss:GetNWBool("UD_Enraged", false) and Color(230, 60, 20) or BarFill)
		draw.SimpleTextOutlined(intHealth .. " / " .. intMax, "UiBold", ScrW() / 2, y + h / 2, BarText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		if tblNPC and tblNPC.Title then
			draw.SimpleTextOutlined(tblNPC.Title, "UiBold", ScrW() / 2, y + h + 4, Color(200, 185, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		end
	end)
end
