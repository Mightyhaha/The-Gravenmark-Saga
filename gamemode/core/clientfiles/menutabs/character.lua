PANEL = {}
PANEL.HeaderHieght = 15
PANEL.StatsWidth = 190

local StatRows = {
	{Stat = "stat_maxhealth", Label = "Max Health"},
	{Stat = "stat_strength", Label = "Strength"},
	{Stat = "stat_dexterity", Label = "Dexterity"},
	{Stat = "stat_agility", Label = "Agility"},
	{Stat = "stat_luck", Label = "Luck"},
	{Stat = "stat_maxweight", Label = "Max Weight"},
}

function PANEL:Init()
	self.HeaderList = CreateGenericList(self, 1, true, false)
	self.StatsList = CreateGenericList(self, 2, false, true)
	self.MastersHeader = CreateGenericList(self, 1, true, false)
	self.MastersList = CreateGenericList(self, 2, false, false)
	self:LoadHeader()
	self:LoadMasters()
end

function PANEL:PerformLayout()
	self.HeaderList:SetPos(0, 0)
	self.HeaderList:SetSize(self.StatsWidth, self.HeaderHieght)
	self.StatsList:SetPos(0, self.HeaderHieght + 5)
	self.StatsList:SetSize(self.StatsWidth, self:GetTall() - self.HeaderHieght - 5)
	self.MastersHeader:SetPos(self.StatsWidth + 5, 0)
	self.MastersHeader:SetSize(self:GetWide() - self.StatsWidth - 5, self.HeaderHieght)
	self.MastersList:SetPos(self.StatsWidth + 5, self.HeaderHieght + 5)
	self.MastersList:SetSize(self.MastersHeader:GetWide(), self:GetTall() - self.HeaderHieght - 5)
	for Master, MasterBar in pairs(self.MastersList.Masters or {}) do
		if MasterBar.TierUp then
			MasterBar.TierUp:SetPos(self.MastersList:GetWide() - 16 - 5, 2)
		end
	end
end

function PANEL:LoadSkills()
	if GAMEMODE.MainMenu and GAMEMODE.MainMenu.SkillsTab then GAMEMODE.MainMenu.SkillsTab:Refresh() end
end

local function AddStatLabel(List, Text)
	local Label = vgui.Create("DLabel")
	Label:SetFont("UiBold")
	Label:SetColor(clrDrakGray)
	Label:SetText("  " .. Text)
	Label:SizeToContents()
	List:AddItem(Label)
end

function PANEL:LoadHeader()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply.GetStat then return end
	self.HeaderList:Clear()
	AddStatLabel(self.HeaderList, "Level " .. ply:GetLevel())
	self.StatsList:Clear()
	for _, Row in ipairs(StatRows) do
		if StatTable(Row.Stat) then AddStatLabel(self.StatsList, Row.Label .. ": " .. ply:GetStat(Row.Stat)) end
	end
	AddStatLabel(self.StatsList, "Armor: " .. ((ply:GetArmorRating() or 1) - 1))
	if ply:GetLevel() < GAMEMODE.MaxLevel then
		local intProgress = ply:GetNWInt("exp") - toExp(ply:GetLevel())
		AddStatLabel(self.StatsList, "Experience: " .. intProgress .. " / " .. ExpToNextLevel(ply:GetLevel()))
	else
		AddStatLabel(self.StatsList, "Experience: max level")
	end
	AddStatLabel(self.StatsList, "Skill points: " .. ply:GetNWInt("SkillPoints"))
	self:PerformLayout()
end

function PANEL:LoadMasters()
	self.MastersList:Clear()
	self.MastersList.Masters = {}
	for Name, MasterTable in pairs(table.Copy(GAMEMODE.DataBase.Masters)) do
		local MasterBar = vgui.Create("FPercentBar")
		local CurentLevel = LocalPlayer():GetMasterLevel(Name)
		local CurentExp =  LocalPlayer():GetMasterExp(Name) - toMasterExp(CurentLevel)
		local NextExp = toMasterExp(CurentLevel + 1) - toMasterExp(CurentLevel)
		MasterBar:SetTall(20)
		MasterBar:SetMax(NextExp - 1)
		MasterBar:SetValue(CurentExp)
		MasterBar:SetText(MasterTable.PrintName .. " Tier " .. CurentLevel)
		if LocalPlayer():GetMasterExp(Name) == LocalPlayer():GetMasterExpNextLevel(Name) - 1 then
			if LocalPlayer():GetTotalMasters() < GAMEMODE.MaxMaxtersTiers and CurentLevel < GAMEMODE.Combat.MaxTradeTier then
				MasterBar.TierUp = CreateGenericImageButton(MasterBar, "gui/arrow_up", "Tier Up", function()
					RunConsoleCommand("UD_BuyMasterLevel", Name)
				end)
			end
		end
		self.MastersList:AddItem(MasterBar)
		if MasterBar.TierUp then
			MasterBar.TierUp:SetPos(MasterBar:GetWide() - MasterBar.TierUp:GetWide() - 5, 2)
		end
		table.insert(self.MastersList.Masters, MasterBar)
	end
	self.MastersHeader:Clear()
	local Total = vgui.Create("DLabel")
	Total:SetFont("UiBold")
	Total:SetColor(clrDrakGray)
	Total:SetText("  Total Tiers " .. LocalPlayer():GetTotalMasters() .. "/" .. GAMEMODE.MaxMaxtersTiers)
	Total:SizeToContents()
	self.MastersHeader:AddItem(Total)
	self:PerformLayout()
end
vgui.Register("charactertab", PANEL, "Panel")
