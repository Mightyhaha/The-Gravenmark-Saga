local PANEL = {}
local HeaderHeight = 24
local BranchHeaderHeight = 30
local TierColumnWidth = 44
local RowHeight = 62
local IconSize = 34
local MaterialCache = {}

local clrBackground = Color(46, 41, 35, 255)
local clrStripe = Color(56, 50, 43, 255)
local clrText = Color(235, 225, 205, 255)
local clrDimText = Color(150, 140, 125, 255)
local clrMaxed = Color(110, 200, 100, 255)
local clrAvailable = Color(235, 190, 70, 255)
local clrOwned = Color(200, 170, 120, 255)
local clrLocked = Color(90, 84, 76, 255)
local clrLine = Color(120, 108, 92, 255)
local clrLineActive = Color(200, 170, 110, 255)

local function GetIconMaterial(strIcon)
	if not strIcon then return nil end
	if MaterialCache[strIcon] == nil then
		local matIcon = Material(strIcon, "smooth")
		MaterialCache[strIcon] = (matIcon and not matIcon:IsError()) and matIcon or false
	end
	return MaterialCache[strIcon] or nil
end

local function GetSkillState(ply, tblSkill)
	local intRank = ply:GetSkill(tblSkill.Name)
	if intRank >= tblSkill.Levels then return "maxed", intRank end
	if not ply:MeetsSkillLevel(tblSkill.Name) then return "level", intRank end
	if not ply:MeetsSkillPrerequisite(tblSkill.Name) then return "prereq", intRank end
	if ply:GetNWInt("SkillPoints") >= (tblSkill.Cost or 1) then return "available", intRank end
	if intRank > 0 then return "owned", intRank end
	return "nopoints", intRank
end

local function BuildTooltip(ply, tblSkill)
	local intRank = ply:GetSkill(tblSkill.Name)
	local tblLines = {}
	table.insert(tblLines, tblSkill.PrintName .. "  (" .. intRank .. "/" .. tblSkill.Levels .. ")")
	if tblSkill.Desc.story then table.insert(tblLines, tblSkill.Desc.story) end
	table.insert(tblLines, "")
	if intRank > 0 and tblSkill.Desc[intRank] then table.insert(tblLines, "Now: " .. tblSkill.Desc[intRank]) end
	if intRank < tblSkill.Levels and tblSkill.Desc[intRank + 1] then
		table.insert(tblLines, (intRank > 0 and "Next: " or "Rank 1: ") .. tblSkill.Desc[intRank + 1])
	end
	table.insert(tblLines, "")
	local intCost = tblSkill.Cost or 1
	table.insert(tblLines, "Cost: " .. intCost .. (intCost == 1 and " point per rank" or " points"))
	local intTierLevel = GAMEMODE:GetSkillTierLevel(tblSkill.Tier)
	if ply:GetLevel() < intTierLevel then table.insert(tblLines, "Requires level " .. intTierLevel) end
	if tblSkill.SkillNeeded and not ply:MeetsSkillPrerequisite(tblSkill.Name) then
		table.insert(tblLines, "Requires " .. (tblSkill.Desc.SkillNeeded or tblSkill.SkillNeeded))
	end
	local strState = GetSkillState(ply, tblSkill)
	if strState == "available" then table.insert(tblLines, "Click to learn") end
	return table.concat(tblLines, "\n")
end

local NODE = {}

function NODE:Init()
	self:SetCursor("hand")
end

function NODE:SetSkill(tblSkill)
	self.Skill = tblSkill
end

function NODE:UpdateTooltip()
	if self.Skill then self:SetTooltip(BuildTooltip(LocalPlayer(), self.Skill)) end
end

function NODE:OnCursorEntered()
	self:UpdateTooltip()
end

function NODE:OnMousePressed(intCode)
	if intCode ~= MOUSE_LEFT or not self.Skill then return end
	local strState = GetSkillState(LocalPlayer(), self.Skill)
	if strState == "available" then
		RunConsoleCommand("UD_BuySkill", self.Skill.Name)
		surface.PlaySound("buttons/button14.wav")
	else
		surface.PlaySound("buttons/button10.wav")
	end
end

function NODE:Paint(w, h)
	local tblSkill = self.Skill
	if not tblSkill then return end
	local ply = LocalPlayer()
	local strState, intRank = GetSkillState(ply, tblSkill)
	local x, y = math.floor((w - IconSize) / 2), 2
	local clrBorder = clrLocked
	if strState == "maxed" then
		clrBorder = clrMaxed
	elseif strState == "available" then
		local flPulse = 0.65 + 0.35 * math.abs(math.sin(RealTime() * 3))
		clrBorder = Color(clrAvailable.r, clrAvailable.g, clrAvailable.b, 255 * flPulse)
	elseif intRank > 0 then
		clrBorder = clrOwned
	end
	draw.RoundedBox(4, x - 3, y - 2, IconSize + 6, IconSize + 6, clrBorder)
	draw.RoundedBox(4, x - 1, y, IconSize + 2, IconSize + 2, Color(30, 27, 23, 255))
	local matIcon = GetIconMaterial(tblSkill.Icon)
	local intAlpha = (strState == "level" or strState == "prereq") and 70 or 255
	if matIcon then
		surface.SetDrawColor(255, 255, 255, intAlpha)
		surface.SetMaterial(matIcon)
		surface.DrawTexturedRect(x + 1, y + 2, IconSize - 2, IconSize - 2)
	end
	if strState == "level" then
		draw.SimpleTextOutlined("Lv " .. GAMEMODE:GetSkillTierLevel(tblSkill.Tier), "UiBold", x + IconSize / 2, y + IconSize / 2, clrText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
	end
	draw.SimpleTextOutlined(intRank .. "/" .. tblSkill.Levels, "DefaultFixedOutline", x + IconSize, y + IconSize, clrText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 0, Color(0, 0, 0, 0))
	local clrName = intRank > 0 and clrText or clrDimText
	draw.SimpleText(self:GetShortName(w - 4), "DefaultSmall", w / 2, y + IconSize + 5, clrName, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

function NODE:GetShortName(intMaxWide)
	if self.ShortName and self.ShortNameWide == intMaxWide then return self.ShortName end
	local strName = self.Skill.PrintName
	surface.SetFont("DefaultSmall")
	if surface.GetTextSize(strName) > intMaxWide then
		while #strName > 1 and surface.GetTextSize(strName .. "..") > intMaxWide do
			strName = string.sub(strName, 1, -2)
		end
		strName = string.TrimRight(strName) .. ".."
	end
	self.ShortName = strName
	self.ShortNameWide = intMaxWide
	return strName
end
vgui.Register("UD_SkillNode", NODE, "Panel")

function PANEL:Init()
	self.Header = vgui.Create("DPanel", self)
	self.Header.Paint = function(pnl, w, h)
		jdraw.QuickDrawPanel(Gray, 0, 0, w, h)
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply.GetSpentSkillPoints then return end
		local strText = "Level " .. ply:GetLevel() .. "    Skill points: " .. ply:GetNWInt("SkillPoints") .. "    Spent: " .. ply:GetSpentSkillPoints()
		draw.SimpleText(strText, "UiBold", 6, h / 2, DrakGray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	self.ResetButton = CreateGenericButton(self.Header, "Forget skills")
	self.ResetButton.DoClick = function()
		local intCost = GAMEMODE:GetSkillResetCost(LocalPlayer():GetLevel())
		Derma_Query("Forget every skill and get all your points back for " .. intCost .. " denars?", "Forget skills", "Yes", function()
			RunConsoleCommand("UD_ResetSkills")
		end, "No")
	end

	self.Scroll = vgui.Create("DScrollPanel", self)
	self.Canvas = vgui.Create("DPanel")
	self.Canvas.Paint = function(pnl, w, h) self:PaintCanvas(w, h) end
	self.Scroll:AddItem(self.Canvas)
	self.Nodes = {}
	self:BuildNodes()
end

function PANEL:BuildNodes()
	for _, pnlNode in pairs(self.Nodes) do pnlNode:Remove() end
	self.Nodes = {}
	self.MaxTier = 1
	for strSkill, tblSkill in pairs(GAMEMODE.DataBase.Skills) do
		local pnlNode = vgui.Create("UD_SkillNode", self.Canvas)
		pnlNode:SetSkill(tblSkill)
		self.Nodes[strSkill] = pnlNode
		self.MaxTier = math.max(self.MaxTier, tblSkill.Tier or 1)
	end
	self:InvalidateLayout()
end

function PANEL:GetBranchIndex(strBranch)
	for intIndex, tblBranch in ipairs(GAMEMODE.SkillBranches) do
		if tblBranch.Name == strBranch then return intIndex end
	end
	return #GAMEMODE.SkillBranches
end

function PANEL:PerformLayout()
	local w, h = self:GetWide(), self:GetTall()
	self.Header:SetPos(0, 0)
	self.Header:SetSize(w, HeaderHeight)
	self.ResetButton:SetSize(100, HeaderHeight - 6)
	self.ResetButton:SetPos(w - 103, 3)
	self.Scroll:SetPos(0, HeaderHeight + 4)
	self.Scroll:SetSize(w, h - HeaderHeight - 4)

	local intCanvasWide = w - 16
	local intBranches = math.max(#GAMEMODE.SkillBranches, 1)
	self.ColumnWidth = math.floor((intCanvasWide - TierColumnWidth) / intBranches)
	self.Canvas:SetSize(intCanvasWide, BranchHeaderHeight + self.MaxTier * RowHeight + 6)

	local tblCellCounts = {}
	for strSkill, pnlNode in pairs(self.Nodes) do
		local tblSkill = pnlNode.Skill
		local intColumn = self:GetBranchIndex(tblSkill.Branch)
		local strCell = intColumn .. "_" .. tblSkill.Tier
		tblCellCounts[strCell] = (tblCellCounts[strCell] or 0) + 1
	end
	local tblCellUsed = {}
	local tblSorted = table.GetKeys(self.Nodes)
	table.sort(tblSorted)
	for _, strSkill in ipairs(tblSorted) do
		local pnlNode = self.Nodes[strSkill]
		local tblSkill = pnlNode.Skill
		local intColumn = self:GetBranchIndex(tblSkill.Branch)
		local strCell = intColumn .. "_" .. tblSkill.Tier
		local intCount = tblCellCounts[strCell]
		tblCellUsed[strCell] = (tblCellUsed[strCell] or 0) + 1
		local intNodeWide = math.floor(self.ColumnWidth / intCount)
		local x = TierColumnWidth + (intColumn - 1) * self.ColumnWidth + (tblCellUsed[strCell] - 1) * intNodeWide
		local y = BranchHeaderHeight + (tblSkill.Tier - 1) * RowHeight + 2
		pnlNode:SetPos(x, y)
		pnlNode:SetSize(intNodeWide, RowHeight - 4)
	end
end

function PANEL:GetNodeAnchor(pnlNode, boolBottom)
	local x, y = pnlNode:GetPos()
	if boolBottom then return x + pnlNode:GetWide() / 2, y + pnlNode:GetTall() - 2 end
	return x + pnlNode:GetWide() / 2, y
end

function PANEL:PaintCanvas(w, h)
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	surface.SetDrawColor(clrBackground)
	surface.DrawRect(0, 0, w, h)
	for intTier = 1, self.MaxTier do
		local y = BranchHeaderHeight + (intTier - 1) * RowHeight
		if intTier % 2 == 0 then
			surface.SetDrawColor(clrStripe)
			surface.DrawRect(0, y, w, RowHeight)
		end
		local intLevel = GAMEMODE:GetSkillTierLevel(intTier)
		local clrTier = ply:GetLevel() >= intLevel and clrText or clrDimText
		draw.SimpleText("Lv", "DefaultSmall", TierColumnWidth / 2, y + RowHeight / 2 - 7, clrTier, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(tostring(intLevel), "UiBold", TierColumnWidth / 2, y + RowHeight / 2 + 6, clrTier, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	for intIndex, tblBranch in ipairs(GAMEMODE.SkillBranches) do
		local x = TierColumnWidth + (intIndex - 1) * (self.ColumnWidth or 0)
		draw.SimpleText(tblBranch.PrintName, "UiBold", x + (self.ColumnWidth or 0) / 2, 9, clrText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(ply:GetBranchSkillPoints(tblBranch.Name) .. " points", "DefaultSmall", x + (self.ColumnWidth or 0) / 2, 22, clrDimText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	for _, pnlNode in pairs(self.Nodes) do
		local tblSkill = pnlNode.Skill
		local pnlParent = tblSkill.SkillNeeded and self.Nodes[tblSkill.SkillNeeded]
		if IsValid(pnlParent) then
			local x1, y1 = self:GetNodeAnchor(pnlParent, true)
			local x2, y2 = self:GetNodeAnchor(pnlNode, false)
			local boolActive = ply:MeetsSkillPrerequisite(tblSkill.Name)
			surface.SetDrawColor(boolActive and clrLineActive or clrLine)
			if math.abs(x1 - x2) < 1 then
				surface.DrawRect(x1 - 1, y1, 3, math.max(y2 - y1, 1))
			else
				surface.DrawLine(x1, y1, x2, y2)
			end
		end
	end
end

function PANEL:Refresh()
	local intCount = table.Count(GAMEMODE.DataBase.Skills)
	if intCount ~= table.Count(self.Nodes) then self:BuildNodes() end
	for _, pnlNode in pairs(self.Nodes) do
		if pnlNode:IsHovered() then pnlNode:UpdateTooltip() end
	end
end
vgui.Register("skillstab", PANEL, "Panel")
