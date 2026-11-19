GM.DayNight = {
	CycleMinutes = 48,
	StartHour = 9,
	DawnStart = 5,
	DawnEnd = 7,
	DuskStart = 19,
	DuskEnd = 21,
	DayStyle = "m",
	NightStyle = "c",
	NightSkyAlpha = 225,
	LanternSize = 340,
	NightFogEnd = 2200,
	NightFogDensity = 0.96,
	NightUndeadDamage = 1.25,
}

function GM:GetTimeOfDay()
	local DN = self.DayNight
	return (DN.StartHour + GetGlobalFloat("UD_DayOffset", 0) + CurTime() / (DN.CycleMinutes * 60) * 24) % 24
end

function GM:GetNightFactor(flHour)
	local DN = self.DayNight
	flHour = flHour or self:GetTimeOfDay()
	if flHour >= DN.DawnEnd and flHour < DN.DuskStart then return 0 end
	if flHour >= DN.DuskEnd or flHour < DN.DawnStart then return 1 end
	if flHour >= DN.DuskStart then return (flHour - DN.DuskStart) / (DN.DuskEnd - DN.DuskStart) end
	return 1 - (flHour - DN.DawnStart) / (DN.DawnEnd - DN.DawnStart)
end

function GM:IsNight()
	return self:GetNightFactor() >= 0.5
end

function GM:FormatTimeOfDay(flHour)
	flHour = flHour or self:GetTimeOfDay()
	return string.format("%02d:%02d", math.floor(flHour), math.floor((flHour % 1) * 60))
end

if SERVER then
	util.AddNetworkString("UD_DayNightLight")
	util.AddNetworkString("UD_Announce")

	function GM:Announce(strText, clrColor, strSound, Target)
		net.Start("UD_Announce")
		net.WriteString(strText)
		net.WriteColor(clrColor or Color(230, 210, 160))
		net.WriteString(strSound or "")
		if Target then net.Send(Target) else net.Broadcast() end
	end

	function GM:SetTimeOfDay(flHour)
		local DN = self.DayNight
		SetGlobalFloat("UD_DayOffset", flHour - DN.StartHour - CurTime() / (DN.CycleMinutes * 60) * 24)
	end

	local strLastStyle
	local boolWasNight

	local function StyleFor(flNight)
		local DN = GAMEMODE.DayNight
		local intDay, intNight = string.byte(DN.DayStyle), string.byte(DN.NightStyle)
		return string.char(math.Round(intDay + (intNight - intDay) * flNight))
	end

	timer.Create("UD_DayNight", 2, 0, function()
		if not GAMEMODE then return end
		local strStyle = StyleFor(GAMEMODE:GetNightFactor())
		if strStyle ~= strLastStyle then
			strLastStyle = strStyle
			engine.LightStyle(0, strStyle)
			net.Start("UD_DayNightLight")
			net.Broadcast()
		end
		local boolNight = GAMEMODE:IsNight()
		if boolWasNight ~= nil and boolNight ~= boolWasNight then
			if boolNight then
				GAMEMODE:Announce("Night falls over the Gravenmark. The dead grow bolder.", Color(150, 170, 230), "ambient/wind/wind_hit2.wav")
			else
				GAMEMODE:Announce("Dawn breaks. The dead return to their graves.", Color(240, 200, 120), "ambient/levels/forest/dist_birds1.wav")
			end
			hook.Run("UD_NightChanged", boolNight)
		end
		boolWasNight = boolNight
	end)

	concommand.Add("UD_Dev_SetTime", function(ply, cmd, args)
		if IsValid(ply) and not ply:IsAdmin() then return end
		local flHour = tonumber(args[1])
		if not flHour then
			print("[Gravenmark] Time is " .. GAMEMODE:FormatTimeOfDay() .. ". Usage: UD_Dev_SetTime <hour 0-24>")
			return
		end
		GAMEMODE:SetTimeOfDay(math.Clamp(flHour, 0, 23.99))
		print("[Gravenmark] Time set to " .. GAMEMODE:FormatTimeOfDay())
	end)
end

if CLIENT then
	local ConVarLantern = CreateClientConVar("ud_lantern", 1, true, false)
	local flNextRedownload = 0
	local boolPending = false
	local boolRelit = false

	local function QueueRedownload()
		boolPending = true
	end

	net.Receive("UD_DayNightLight", QueueRedownload)
	hook.Add("InitPostEntity", "UD_DayNightFirstLight", function() timer.Simple(2, QueueRedownload) end)

	hook.Add("Think", "UD_DayNightRedownload", function()
		if not boolPending or RealTime() < flNextRedownload then return end
		boolPending = false
		flNextRedownload = RealTime() + 1
		if GAMEMODE:GetNightFactor() <= 0 and not boolRelit then return end
		boolRelit = true
		render.RedownloadAllLightmaps(false)
	end)

	local MapFog = {Start = 0, End = 6000, Color = Color(60, 60, 65), Density = 1}
	local NightFogColor = Color(5, 7, 13)

	hook.Add("PreDrawOpaqueRenderables", "UD_CaptureMapFog", function(bDepth, bSkybox)
		if bDepth or bSkybox or GAMEMODE:GetNightFactor() > 0 then return end
		local flStart, flEnd = render.GetFogDistances()
		local r, g, b = render.GetFogColor()
		if flEnd and flEnd > 0 then
			MapFog.Start, MapFog.End = flStart, flEnd
			MapFog.Color = Color(r, g, b)
		end
	end)

	local function NightFog(flScale)
		local flNight = GAMEMODE:GetNightFactor()
		if flNight <= 0 then return end
		local DN = GAMEMODE.DayNight
		flScale = flScale or 1
		render.FogMode(MATERIAL_FOG_LINEAR)
		render.FogStart(Lerp(flNight, MapFog.Start, 0) * flScale)
		render.FogEnd(Lerp(flNight, MapFog.End, DN.NightFogEnd) * flScale)
		render.FogMaxDensity(Lerp(flNight, MapFog.Density, DN.NightFogDensity))
		render.FogColor(Lerp(flNight, MapFog.Color.r, NightFogColor.r), Lerp(flNight, MapFog.Color.g, NightFogColor.g), Lerp(flNight, MapFog.Color.b, NightFogColor.b))
		return true
	end
	hook.Add("SetupWorldFog", "UD_NightFog", function() return NightFog(1) end)
	hook.Add("SetupSkyboxFog", "UD_NightFog", function(flScale) return NightFog(flScale) end)

	local function DarkenSky()
		local flNight = GAMEMODE:GetNightFactor()
		if flNight <= 0 then return end
		render.OverrideDepthEnable(true, false)
		cam.Start2D()
		surface.SetDrawColor(4, 6, 16, flNight * GAMEMODE.DayNight.NightSkyAlpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()
		render.OverrideDepthEnable(false, false)
	end
	hook.Add("PostDraw2DSkyBox", "UD_NightSky", DarkenSky)

	hook.Add("Think", "UD_NightLantern", function()
		if not ConVarLantern:GetBool() then return end
		local flNight = GAMEMODE:GetNightFactor()
		if flNight <= 0.05 then return end
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() and not ply:IsDormant() then
				local Light = DynamicLight(ply:EntIndex())
				if Light then
					Light.pos = ply:GetPos() + Vector(0, 0, 60)
					Light.r = 255
					Light.g = 190
					Light.b = 120
					Light.brightness = 0.6 * flNight
					Light.Decay = 1000
					Light.Size = GAMEMODE.DayNight.LanternSize
					Light.DieTime = CurTime() + 0.2
				end
			end
		end
	end)

	local Announcement

	net.Receive("UD_Announce", function()
		local strText = net.ReadString()
		local clrColor = net.ReadColor()
		local strSound = net.ReadString()
		Announcement = {Text = strText, Color = clrColor, Start = RealTime()}
		chat.AddText(clrColor, strText)
		if strSound ~= "" then surface.PlaySound(strSound) end
	end)

	hook.Add("HUDPaint", "UD_Announcement", function()
		if not Announcement then return end
		local flAge = RealTime() - Announcement.Start
		if flAge > 7 then
			Announcement = nil
			return
		end
		local flAlpha = math.Clamp(math.min(flAge / 0.6, (7 - flAge) / 1.5), 0, 1) * 255
		local Col = Color(Announcement.Color.r, Announcement.Color.g, Announcement.Color.b, flAlpha)
		draw.SimpleTextOutlined(Announcement.Text, "UiBold", ScrW() / 2, ScrH() * 0.22, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, flAlpha))
	end)

	hook.Add("HUDPaint", "UD_DayNightClock", function()
		if not GetConVar("ud_showminimap") or not GetConVar("ud_showminimap"):GetBool() then return end
		local flHour = GAMEMODE:GetTimeOfDay()
		local strText = (GAMEMODE:IsNight() and "Night  " or "Day  ") .. GAMEMODE:FormatTimeOfDay(flHour)
		draw.SimpleTextOutlined(strText, "UiBold", ScrW() - 196, 18, Color(235, 225, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 200))
	end)
end
