local MaterialCache = {}
local RowHeight = 22
local IconSize = 16
local BoxWidth = 190

local function GetIconMaterial(strIcon)
	if not strIcon then return nil end
	if MaterialCache[strIcon] == nil then
		local matIcon = Material(strIcon, "smooth")
		MaterialCache[strIcon] = (matIcon and not matIcon:IsError()) and matIcon or false
	end
	return MaterialCache[strIcon] or nil
end

local function FormatTimeLeft(flSeconds)
	flSeconds = math.max(math.floor(flSeconds), 0)
	if flSeconds >= 3600 then
		return string.format("%d:%02d:%02d", math.floor(flSeconds / 3600), math.floor(flSeconds % 3600 / 60), flSeconds % 60)
	end
	return string.format("%d:%02d", math.floor(flSeconds / 60), flSeconds % 60)
end

local CategoryColors = {
	food = Color(214, 170, 90, 230),
	rest = Color(120, 160, 220, 230),
	aura = Color(150, 200, 120, 230),
	combat = Color(220, 110, 80, 230),
}

hook.Add("HUDPaint", "UD_DrawBuffs", function()
	if not GAMEMODE.ConVarShowHUD or not GAMEMODE.ConVarShowHUD:GetBool() then return end
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply.GetActiveBuffs then return end
	local tblActive = {}
	for strBuff, tblInfo in pairs(ply:GetActiveBuffs()) do
		local tblBuff = BuffTable(strBuff)
		if tblBuff then table.insert(tblActive, {Name = strBuff, Buff = tblBuff, Info = tblInfo}) end
	end
	if #tblActive == 0 then return end
	table.sort(tblActive, function(a, b) return a.Info.Expires > b.Info.Expires end)

	local intBottom = ScrH() - 60
	local wep = ply:GetActiveWeapon()
	if not ply:IsMelee() and IsValid(wep) and wep.Primary and (wep.Primary.ClipSize or 0) > 0 then intBottom = intBottom - 18 end
	if ply:GetNWInt("SkillPoints") > 0 then intBottom = intBottom - 24 end

	for intIndex, tblEntry in ipairs(tblActive) do
		local y = intBottom - intIndex * (RowHeight + 2)
		local flTimeLeft = tblEntry.Info.Expires - CurTime()
		local flFraction = math.Clamp(flTimeLeft / math.max(tblEntry.Info.Duration or flTimeLeft, 1), 0, 1)
		local clrBar = CategoryColors[tblEntry.Buff.Category] or CategoryColors.combat
		draw.RoundedBox(4, 10, y, BoxWidth, RowHeight, Color(30, 26, 22, 200))
		draw.RoundedBox(4, 10, y + RowHeight - 3, math.max(BoxWidth * flFraction, 4), 3, clrBar)
		local matIcon = GetIconMaterial(tblEntry.Buff.Icon)
		if matIcon then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(matIcon)
			surface.DrawTexturedRect(14, y + 2, IconSize, IconSize)
		end
		draw.SimpleText(tblEntry.Buff.PrintName or tblEntry.Name, "UiBold", 14 + IconSize + 5, y + 9, Color(235, 225, 205, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(FormatTimeLeft(flTimeLeft), "UiBold", 10 + BoxWidth - 5, y + 9, Color(235, 225, 205, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end)
