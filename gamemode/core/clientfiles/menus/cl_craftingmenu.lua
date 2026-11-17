local TradeChoices = {
	{"All trades", nil},
	{"Blacksmithing", "master_blacksmithing"},
	{"Leatherworking", "master_leatherworking"},
	{"Tailoring", "master_tailoring"},
}

local GroupChoices = {"All items", "Weapons", "Armor", "Jewelry", "Smelting"}

local ColorOk = Color(120, 210, 90, 255)
local ColorBad = Color(235, 90, 70, 255)

local function CountOf(strItem)
	local Data = LocalPlayer().Data
	return (Data and Data.Inventory and Data.Inventory[strItem]) or 0
end

local function TradeNames(tblRecipe)
	local tblNames = {}
	for strMaster, _ in pairs(tblRecipe.RequiredMasters) do
		local tblMaster = MasterTable(strMaster)
		table.insert(tblNames, tblMaster and tblMaster.PrintName or strMaster)
	end
	table.sort(tblNames)
	return table.concat(tblNames, ", ")
end

local function StateSignature(tblRecipe)
	local plyLocal = LocalPlayer()
	local tblParts = {plyLocal:CanMake(tblRecipe.Name) and 1 or 0, plyLocal:IsNearStation(tblRecipe.Station or "") and 1 or 0}
	for strItem, _ in pairs(tblRecipe.Ingredients) do table.insert(tblParts, strItem .. CountOf(strItem)) end
	for strMaster, _ in pairs(tblRecipe.RequiredMasters) do table.insert(tblParts, strMaster .. plyLocal:GetMasterLevel(strMaster)) end
	table.sort(tblParts, function(A, B) return tostring(A) < tostring(B) end)
	return table.concat(tblParts, "|")
end

local function AddLabel(Parent, strText, clrColor)
	local Label = Parent:Add("DLabel")
	Label:SetText(strText)
	Label:SetTextColor(clrColor or White)
	Label:SetWrap(true)
	Label:SetAutoStretchVertical(true)
	Label:Dock(TOP)
	Label:DockMargin(6, 2, 6, 2)
	return Label
end

local function BuildDetail(Scroll, strRecipe)
	Scroll:Clear()
	local tblRecipe = RecipeTable(strRecipe)
	if not tblRecipe then return end
	local plyLocal = LocalPlayer()
	local strProduct = next(tblRecipe.Products)
	local tblItem = ItemTable(strProduct)

	AddLabel(Scroll, tblRecipe.PrintName, Cream)
	if tblItem then
		if tblItem.Desc then AddLabel(Scroll, tblItem.Desc, White) end
		if tblItem.Level and tblItem.Level > 1 then AddLabel(Scroll, "Item level " .. tblItem.Level, White) end
		if tblItem.Power then
			local tblClass = GAMEMODE.WeaponClasses[tblItem.WeaponClass or ""]
			AddLabel(Scroll, (tblClass and tblClass.PrintName or "Weapon") .. ": damage " .. tblItem.Power .. ", speed " .. tblItem.FireRate, White)
			if tblItem.Range then AddLabel(Scroll, "Long reach", White) end
			if tblItem.CritBonus then AddLabel(Scroll, "+" .. math.Round(tblItem.CritBonus * 100) .. "% critical chance", White) end
		end
		if tblItem.Armor and tblItem.Armor > 0 then AddLabel(Scroll, "Armor: " .. tblItem.Armor, White) end
		for strStat, intAmount in pairs(tblItem.Buffs or {}) do
			local tblStat = StatTable(strStat)
			AddLabel(Scroll, "+" .. intAmount .. " " .. (tblStat and tblStat.PrintName or strStat), White)
		end
		if tblItem.Set then
			local tblSet = EquipmentSetTable(tblItem.Set)
			if tblSet then AddLabel(Scroll, "Part of " .. tblSet.PrintName, White) end
		end
	end

	AddLabel(Scroll, "Ingredients", Cream)
	for strItem, intAmount in pairs(tblRecipe.Ingredients) do
		local tblIngredient = ItemTable(strItem)
		local intHave = CountOf(strItem)
		AddLabel(Scroll, intHave .. " / " .. intAmount .. "  " .. (tblIngredient and tblIngredient.PrintName or strItem), intHave >= intAmount and ColorOk or ColorBad)
	end

	AddLabel(Scroll, "Requirements", Cream)
	for strMaster, intLevel in pairs(tblRecipe.RequiredMasters) do
		local tblMaster = MasterTable(strMaster)
		local intHave = plyLocal:GetMasterLevel(strMaster)
		AddLabel(Scroll, (tblMaster and tblMaster.PrintName or strMaster) .. " tier " .. intLevel .. " (you: " .. intHave .. ")", intHave >= intLevel and ColorOk or ColorBad)
	end
	if tblRecipe.Station then
		AddLabel(Scroll, "Stand near " .. (GAMEMODE.CraftingStationNames[tblRecipe.Station] or tblRecipe.Station), plyLocal:IsNearStation(tblRecipe.Station) and ColorOk or ColorBad)
	end
	if tblRecipe.MakeTime then AddLabel(Scroll, "Takes " .. math.Round(tblRecipe.MakeTime, 1) .. " seconds", White) end
end

local function OpenCraftMenu(plyCaller, strCommand, tblArgs)
	if IsValid(GAMEMODE.CraftMenu) then GAMEMODE.CraftMenu:Remove() end

	local Frame = vgui.Create("DFrame")
	Frame:SetSize(820, 500)
	Frame:SetTitle("Crafting")
	Frame:Center()
	Frame:MakePopup()
	Frame.Paint = function(self, intWide, intTall)
		draw.RoundedBox(4, 0, 0, intWide, intTall, DrakGray)
		draw.RoundedBox(4, 0, 0, intWide, 24, Mooca)
	end
	GAMEMODE.CraftMenu = Frame

	local intTrade, strGroup, boolOnlyMakeable = 1, "All items", false
	if tblArgs and tblArgs[1] == "smithing" then intTrade = 2 end
	if tblArgs and tblArgs[1] == "leatherwork" then intTrade = 3 end
	if tblArgs and tblArgs[1] == "tailoring" then intTrade = 4 end

	local Top = vgui.Create("DPanel", Frame)
	Top:Dock(TOP)
	Top:SetTall(26)
	Top:DockMargin(0, 0, 0, 4)
	Top.Paint = function() end

	local TradeBox = vgui.Create("DComboBox", Top)
	TradeBox:Dock(LEFT)
	TradeBox:SetWide(150)
	TradeBox:DockMargin(0, 0, 6, 0)
	for _, Choice in ipairs(TradeChoices) do TradeBox:AddChoice(Choice[1], Choice[2]) end
	TradeBox:ChooseOptionID(intTrade)

	local GroupBox = vgui.Create("DComboBox", Top)
	GroupBox:Dock(LEFT)
	GroupBox:SetWide(130)
	GroupBox:DockMargin(0, 0, 6, 0)
	for _, strName in ipairs(GroupChoices) do GroupBox:AddChoice(strName) end
	GroupBox:ChooseOptionID(1)

	local MakeableBox = vgui.Create("DCheckBoxLabel", Top)
	MakeableBox:Dock(LEFT)
	MakeableBox:SetWide(200)
	MakeableBox:SetText("Only what I can make now")
	MakeableBox:SetTextColor(White)
	MakeableBox:SetValue(false)

	local Bottom = vgui.Create("DPanel", Frame)
	Bottom:Dock(BOTTOM)
	Bottom:SetTall(34)
	Bottom:DockMargin(0, 4, 0, 0)
	Bottom.Paint = function() end

	local CraftButton = vgui.Create("DButton", Bottom)
	CraftButton:Dock(RIGHT)
	CraftButton:SetWide(180)
	CraftButton:SetText("Craft")
	CraftButton:SetEnabled(false)

	local Hint = vgui.Create("DLabel", Bottom)
	Hint:Dock(FILL)
	Hint:SetTextColor(White)
	Hint:SetText("Pick a recipe. Metal comes from mining and smelting, leather and cloth from enemies. Trades level up as you craft.")

	local List = vgui.Create("DListView", Frame)
	List:Dock(LEFT)
	List:SetWide(430)
	List:SetMultiSelect(false)
	local ColLevel = List:AddColumn("Lv")
	ColLevel:SetFixedWidth(40)
	List:AddColumn("Item")
	local ColTrade = List:AddColumn("Trade")
	ColTrade:SetFixedWidth(150)
	local ColMake = List:AddColumn("Can make")
	ColMake:SetFixedWidth(64)

	local Scroll = vgui.Create("DScrollPanel", Frame)
	Scroll:Dock(FILL)
	Scroll:DockMargin(6, 0, 0, 0)
	Scroll.Paint = function(self, intWide, intTall)
		draw.RoundedBox(4, 0, 0, intWide, intTall, Color(30, 29, 27, 255))
	end

	local strSelected, strSignature = nil, nil

	local function Matches(tblRecipe)
		if not LocalPlayer():HasRecipe(tblRecipe.Name) then return false end
		local _, strMaster = TradeBox:GetSelected()
		if strMaster and not tblRecipe.RequiredMasters[strMaster] then return false end
		if strGroup ~= "All items" and tblRecipe.Group ~= strGroup then return false end
		if boolOnlyMakeable and not LocalPlayer():CanMake(tblRecipe.Name) then return false end
		return true
	end

	local function Rebuild()
		List:Clear()
		local tblRows = {}
		for _, tblRecipe in pairs(GAMEMODE.DataBase.Recipes) do
			if Matches(tblRecipe) then table.insert(tblRows, tblRecipe) end
		end
		table.sort(tblRows, function(A, B)
			if (A.ItemLevel or 0) ~= (B.ItemLevel or 0) then return (A.ItemLevel or 0) < (B.ItemLevel or 0) end
			return A.PrintName < B.PrintName
		end)
		for _, tblRecipe in ipairs(tblRows) do
			local Line = List:AddLine(tblRecipe.ItemLevel or 1, tblRecipe.PrintName, TradeNames(tblRecipe), LocalPlayer():CanMake(tblRecipe.Name) and "Yes" or "No")
			Line.Recipe = tblRecipe.Name
			if tblRecipe.Name == strSelected then List:SelectItem(Line) end
		end
	end

	List.OnRowSelected = function(self, intIndex, Row)
		strSelected = Row.Recipe
		strSignature = nil
	end

	TradeBox.OnSelect = function() Rebuild() end
	GroupBox.OnSelect = function(self, intIndex, strValue)
		strGroup = strValue
		Rebuild()
	end
	MakeableBox.OnChange = function(self, boolValue)
		boolOnlyMakeable = boolValue
		Rebuild()
	end
	CraftButton.DoClick = function()
		if strSelected then RunConsoleCommand("UD_CraftRecipe", strSelected) end
	end

	Top.Think = function()
		if (Frame.NextRefresh or 0) > CurTime() then return end
		Frame.NextRefresh = CurTime() + 0.5
		for _, Line in ipairs(List:GetLines()) do
			Line:SetColumnText(4, LocalPlayer():CanMake(Line.Recipe) and "Yes" or "No")
		end
		local tblRecipe = strSelected and RecipeTable(strSelected)
		CraftButton:SetEnabled(tblRecipe and LocalPlayer():CanMake(strSelected) or false)
		if not tblRecipe then return end
		local strNow = StateSignature(tblRecipe)
		if strNow ~= strSignature then
			strSignature = strNow
			BuildDetail(Scroll, strSelected)
		end
	end

	Rebuild()
end

concommand.Add("UD_OpenCraftMenu", OpenCraftMenu)
