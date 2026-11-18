GM.AssetBrowser = {}
local Browser = GM.AssetBrowser

Browser.ModelSources = {
	{Name = "Bremergard (weapons and tools)", Folder = "models/nayrbarr/"},
	{Name = "Bremergard furniture", Folder = "models/props/furnitures/"},
	{Name = "Bremergard tools and camp", Folder = "models/props/tools/"},
	{Name = "Medieval items", Folder = "models/items/"},
	{Name = "Bones and gibs", Folder = "models/gibs/"},
	{Name = "Skeletons and debris", Folder = "models/props/debris/"},
	{Name = "Junk", Folder = "models/props_junk/"},
	{Name = "Street props", Folder = "models/props_c17/"},
	{Name = "Interior props", Folder = "models/props_interiors/"},
	{Name = "Lab props", Folder = "models/props_lab/"},
	{Name = "Wasteland props", Folder = "models/props_wasteland/"},
	{Name = "Pipes", Folder = "models/props_pipes/"},
	{Name = "Morrowind swords", Folder = "models/morrowind/"},
	{Name = "Shapes (PHX)", Folder = "models/props_phx/construct/"},
	{Name = "Shapes (plates and tubes)", Folder = "models/hunter/"},
}

Browser.MaterialSources = {
	{Name = "Bremergard textures", Folder = "materials/nayrbarr/"},
	{Name = "Bremergard furniture", Folder = "materials/models/props/furnitures/"},
	{Name = "Bones and gibs", Folder = "materials/models/gibs/"},
	{Name = "Street props", Folder = "materials/models/props_c17/"},
	{Name = "Junk", Folder = "materials/models/props_junk/"},
	{Name = "Debris", Folder = "materials/models/props_debris/"},
	{Name = "Wasteland", Folder = "materials/models/props_wasteland/"},
	{Name = "Pipes and metal", Folder = "materials/models/props_pipes/"},
	{Name = "Canal and docks", Folder = "materials/models/props_canal/"},
	{Name = "Combine (glowing)", Folder = "materials/models/props_combine/"},
	{Name = "Phoenix storms", Folder = "materials/phoenix_storms/"},
	{Name = "Morrowind swords", Folder = "materials/models/morrowind/"},
	{Name = "Generic models", Folder = "materials/models/"},
}

local ScanLimit = 900
local ScanCache = {}

local function Scan(strFolder, strExt)
	local strKey = strFolder .. strExt
	if ScanCache[strKey] then return ScanCache[strKey] end
	local tblFound = {}
	local tblQueue = {{strFolder, 0}}
	while #tblQueue > 0 and #tblFound < ScanLimit do
		local Current = table.remove(tblQueue, 1)
		local tblFiles, tblDirs = file.Find(Current[1] .. "*", "GAME")
		for _, strFile in ipairs(tblFiles or {}) do
			if string.EndsWith(string.lower(strFile), strExt) then
				table.insert(tblFound, Current[1] .. strFile)
				if #tblFound >= ScanLimit then break end
			end
		end
		if Current[2] < 4 then
			for _, strDir in ipairs(tblDirs or {}) do table.insert(tblQueue, {Current[1] .. strDir .. "/", Current[2] + 1}) end
		end
	end
	table.sort(tblFound)
	ScanCache[strKey] = tblFound
	return tblFound
end

local function MaterialName(strPath)
	strPath = string.gsub(strPath, "^materials/", "")
	return (string.gsub(strPath, "%.vmt$", ""))
end

local PreviewCache = {}
local PreviewCount = 0
local function PreviewMaterial(strMaterial)
	if PreviewCache[strMaterial] ~= nil then return PreviewCache[strMaterial] end
	local matSource = Material(strMaterial)
	local texBase = matSource and not matSource:IsError() and matSource:GetTexture("$basetexture")
	if not texBase or texBase:IsError() then
		PreviewCache[strMaterial] = false
		return false
	end
	PreviewCount = PreviewCount + 1
	local matPreview = CreateMaterial("ud_asset_preview_" .. PreviewCount, "UnlitGeneric", {["$basetexture"] = texBase:GetName(), ["$vertexcolor"] = "1"})
	PreviewCache[strMaterial] = matPreview
	return matPreview
end

local ColorFrame = Color(215, 205, 185)
local ColorTile = Color(60, 55, 50)
local ColorPicked = Color(255, 200, 40)
local ColorText = Color(20, 20, 20)

function Browser.Open(strKind, fnPick, tblSuggested, strTitle)
	if IsValid(Browser.Frame) then Browser.Frame:Close() end
	local boolModels = strKind == "model"
	local Frame = vgui.Create("DFrame")
	Browser.Frame = Frame
	Frame:SetSize(600, math.min(ScrH() - 80, 620))
	Frame:SetPos(math.min(430, ScrW() - 610), 40)
	Frame:SetTitle(strTitle or (boolModels and "Choose a model" or "Choose a material"))
	Frame:MakePopup()
	Frame.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ColorFrame) end

	local Top = vgui.Create("DPanel", Frame)
	Top:Dock(TOP)
	Top:SetTall(24)
	Top:DockMargin(0, 0, 0, 4)
	Top:SetPaintBackground(false)

	local SourceBox = vgui.Create("DComboBox", Top)
	SourceBox:Dock(LEFT)
	SourceBox:SetWide(250)
	SourceBox:DockMargin(0, 0, 6, 0)

	local Search = vgui.Create("DTextEntry", Top)
	Search:Dock(FILL)
	Search:SetPlaceholderText("Search...")

	local ModelRow
	if not boolModels then
		ModelRow = vgui.Create("DPanel", Frame)
		ModelRow:Dock(TOP)
		ModelRow:SetTall(24)
		ModelRow:DockMargin(0, 0, 0, 4)
		ModelRow:SetPaintBackground(false)
		ModelRow:SetVisible(false)
	end

	local Status = vgui.Create("DLabel", Frame)
	Status:Dock(BOTTOM)
	Status:SetTall(18)
	Status:SetTextColor(ColorText)

	local Scroll = vgui.Create("DScrollPanel", Frame)
	Scroll:Dock(FILL)
	local Grid = vgui.Create("DIconLayout", Scroll)
	Grid:Dock(FILL)
	Grid:SetSpaceX(4)
	Grid:SetSpaceY(4)

	local tblEntries, strPicked = {}, nil

	local function Fill()
		Grid:Clear()
		local strFilter = string.lower(string.Trim(Search:GetValue() or ""))
		local intShown = 0
		for _, Entry in ipairs(tblEntries) do
			if strFilter == "" or string.find(string.lower(Entry.Value .. " " .. (Entry.Label or "")), strFilter, 1, true) then
				intShown = intShown + 1
				if intShown <= 400 then
					local strValue = Entry.Value
					if boolModels then
						local Icon = Grid:Add("SpawnIcon")
						Icon:SetSize(72, 72)
						Icon:SetModel(strValue)
						Icon:SetTooltip((Entry.Label and Entry.Label .. "\n" or "") .. strValue)
						Icon.DoClick = function() strPicked = strValue fnPick(strValue) end
						Icon.PaintOver = function(_, w, h)
							if strPicked ~= strValue then return end
							surface.SetDrawColor(ColorPicked)
							surface.DrawOutlinedRect(0, 0, w, h, 2)
						end
					else
						local Tile = Grid:Add("DButton")
						Tile:SetSize(88, 100)
						Tile:SetText("")
						Tile:SetTooltip(strValue)
						Tile.DoClick = function() strPicked = strValue fnPick(strValue) end
						Tile.Paint = function(_, w, h)
							draw.RoundedBox(0, 0, 0, w, h, ColorTile)
							local matPreview = PreviewMaterial(strValue)
							if matPreview then
								surface.SetDrawColor(255, 255, 255)
								surface.SetMaterial(matPreview)
								surface.DrawTexturedRect(4, 4, w - 8, w - 8)
							else
								draw.SimpleText("no preview", "DefaultSmall", w / 2, w / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							end
							draw.SimpleText(Entry.Label or string.GetFileFromFilename(strValue), "DefaultSmall", w / 2, h - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							if strPicked == strValue then
								surface.SetDrawColor(ColorPicked)
								surface.DrawOutlinedRect(0, 0, w, h, 2)
							end
						end
					end
				end
			end
		end
		Status:SetText(intShown > 400 and ("Showing 400 of " .. intShown .. ". Type in the search box to narrow it down.") or (intShown .. " shown. Click one to use it; the window stays open so you can try several."))
	end

	local function SetEntries(tblNew)
		tblEntries = tblNew
		Fill()
	end

	Search.OnChange = function() Fill() end

	SourceBox:AddChoice("Suggested", "suggested", true)
	if not boolModels then SourceBox:AddChoice("Materials of a model...", "frommodel") end
	for Index, Source in ipairs(boolModels and Browser.ModelSources or Browser.MaterialSources) do
		SourceBox:AddChoice(Source.Name, Index)
	end
	SourceBox.OnSelect = function(_, _, _, Data)
		if IsValid(ModelRow) then ModelRow:SetVisible(Data == "frommodel") Frame:InvalidateLayout() end
		if Data == "suggested" then
			SetEntries(tblSuggested or {})
		elseif Data == "frommodel" then
			SetEntries({})
		else
			local Source = (boolModels and Browser.ModelSources or Browser.MaterialSources)[Data]
			local tblNew = {}
			for _, strPath in ipairs(Scan(Source.Folder, boolModels and ".mdl" or ".vmt")) do
				table.insert(tblNew, {Value = boolModels and strPath or MaterialName(strPath)})
			end
			SetEntries(tblNew)
		end
	end

	if IsValid(ModelRow) then
		local ModelEntry = vgui.Create("DTextEntry", ModelRow)
		ModelEntry:Dock(FILL)
		ModelEntry:SetPlaceholderText("Type a model path and press Enter, e.g. models/gibs/hgibs.mdl")
		ModelEntry.OnEnter = function(self)
			local strModel = string.Trim(self:GetValue())
			local entTemp = ClientsideModel(strModel, RENDERGROUP_OPAQUE)
			local tblNew = {}
			if IsValid(entTemp) then
				for _, strMaterial in ipairs(entTemp:GetMaterials() or {}) do table.insert(tblNew, {Value = strMaterial}) end
				entTemp:Remove()
			end
			SetEntries(tblNew)
		end
	end

	SetEntries(tblSuggested or {})
	return Frame
end
