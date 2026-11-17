GM.PaperDollEditor = {}
GM.PaperDollEditor.IsOpen = false
GM.PaperDollEditor.CurrentCamRotation = nil
GM.PaperDollEditor.CurrentCamDistance = nil
GM.PaperDollEditor.CurrentCamHeight = nil

if not game.SinglePlayer() then return end

local Editor = GM.PaperDollEditor
Editor.Parts = {}
Editor.Selected = nil
Editor.Slot = nil
Editor.Preview = {}

local PropGroups = {
	{"Shapes", {
		{"Dome (half sphere)", "models/props_phx/construct/metal_dome360.mdl"},
		{"Dome quarter", "models/props_phx/construct/metal_dome180.mdl"},
		{"Dome eighth", "models/props_phx/construct/metal_dome90.mdl"},
		{"Tube", "models/hunter/tubes/tube1x1x1.mdl"},
		{"Tube half", "models/hunter/tubes/tube1x1x1c.mdl"},
		{"Tube quarter", "models/hunter/tubes/tube1x1x1d.mdl"},
		{"Curved plate half", "models/props_phx/construct/metal_plate_curve180.mdl"},
		{"Curved plate quarter", "models/props_phx/construct/metal_plate_curve.mdl"},
		{"Disc", "models/hunter/tubes/circle2x2.mdl"},
		{"Plate", "models/hunter/plates/plate05x05.mdl"},
		{"Ball", "models/hunter/misc/sphere025x025.mdl"},
		{"Cone", "models/hunter/misc/cone1x1.mdl"},
		{"Cone short", "models/hunter/misc/cone1x05.mdl"},
		{"Shell quarter", "models/hunter/misc/shell2x2c.mdl"},
	}},
	{"Household", {
		{"Metal bucket", "models/props_junk/metalbucket01a.mdl"},
		{"Cooking pot", "models/props_interiors/pot01a.mdl"},
		{"Pan", "models/props_interiors/pot02a.mdl"},
		{"Metal pot", "models/props_c17/metalpot001a.mdl"},
		{"Lamp shade", "models/props_c17/lampshade001a.mdl"},
		{"Saw blade", "models/props_junk/sawblade001a.mdl"},
		{"Pulley wheel", "models/props_c17/pulleywheels_large01.mdl"},
		{"Skull", "models/gibs/hgibs.mdl"},
	}},
	{"Medieval", {
		{"Round shield", "models/nayrbarr/round shield/round shield.mdl"},
		{"Guard shield", "models/items/armors/shield_guard/shield_guard.mdl"},
		{"Sword", "models/nayrbarr/sword/sword.mdl"},
		{"Long sword", "models/items/weapons/sword_long/sword_long.mdl"},
		{"Short sword", "models/items/weapons/sword_short/sword_short.mdl"},
		{"Axe", "models/nayrbarr/axe/axe.mdl"},
		{"War axe", "models/items/weapons/axes/axe.mdl"},
		{"Spear", "models/nayrbarr/spear/spear.mdl"},
		{"Hammer", "models/nayrbarr/hammer/hammer.mdl"},
		{"Tongs", "models/nayrbarr/tongs/tongs.mdl"},
		{"Iron bar", "models/nayrbarr/iron/iron.mdl"},
		{"Coin purse", "models/items/jewels/purses/very_big_purse.mdl"},
		{"Potion", "models/pickups/healthpotion/healthpotion.mdl"},
		{"Scroll", "models/items/magic/scrolls/scroll_rolled.mdl"},
	}},
}

local MaterialGroups = {
	{"Leather", {
		{"Leather, dark brown", "nayrbarr/round shield/leather-dark brown"},
		{"Leather, brown", "nayrbarr/bow/leather-dark brown"},
		{"Leather, black", "nayrbarr/bow/leather - black"},
	}},
	{"Metal", {
		{"Iron, dark scuffed", "nayrbarr/hammer/dark scuffed metal"},
		{"Iron, scuffed", "nayrbarr/iron/scuffed metal"},
		{"Steel plate", "nayrbarr/round shield/steelplt"},
		{"Blade steel", "nayrbarr/sword/blade"},
		{"Rivets", "nayrbarr/round shield/rivits"},
		{"Plain metal", "phoenix_storms/metalset_1-2"},
		{"Rusty sheet", "models/props_debris/metalwall001a"},
		{"Galvanised", "models/props_pipes/guttermetal01a"},
		{"Shiny (tint for gold or brass)", "models/shiny"},
	}},
	{"Cloth and wood", {
		{"Cloth, tan", "models/props_c17/furniturefabric003a"},
		{"Cloth, woven", "models/props_c17/furniturefabric001a"},
		{"Cloth, rough", "models/props_c17/furniturefabric002a"},
		{"Old wood", "nayrbarr/round shield/oldwood"},
		{"Fence wood", "models/props_wasteland/wood_fence01a"},
		{"Sword grip", "nayrbarr/sword/handle"},
	}},
	{"Other", {
		{"Flat colour (use tint)", "models/debug/debugwhite"},
	}},
}

local function Num(Value, Decimals)
	local Text = string.format("%." .. Decimals .. "f", Value)
	if string.find(Text, ".", 1, true) then
		Text = string.gsub(Text, "0+$", "")
		Text = string.gsub(Text, "%.$", "")
	end
	if Text == "-0" or Text == "" then Text = "0" end
	return Text
end

local function SlotTableOf(strSlot)
	return strSlot and GAMEMODE.DataBase.Slots[strSlot]
end

local function BodyAngleOf(strSlot)
	local tblSlot = SlotTableOf(strSlot)
	return tblSlot and tblSlot.BodyAngle or Angle(0, 0, 0)
end

local function ToSlotSpace(Part)
	return WorldToLocal(Part.Pos, Part.Ang, vector_origin, BodyAngleOf(Editor.Slot))
end

local function FromSlotSpace(vecPos, angAng)
	return LocalToWorld(vecPos, angAng, vector_origin, BodyAngleOf(Editor.Slot))
end

local function ToItemModel()
	local tblModel = {}
	local vecRoot, angRoot
	for Index, Part in ipairs(Editor.Parts) do
		local vecSlot, angSlot = ToSlotSpace(Part)
		local vecOut, angOut
		if Index == 1 then
			vecRoot, angRoot = vecSlot, angSlot
			angOut = angSlot
			vecOut = WorldToLocal(vecSlot, Angle(0, 0, 0), vector_origin, angSlot)
		else
			local _, angRel = WorldToLocal(vector_origin, angSlot, vector_origin, angRoot)
			angOut = angRel
			vecOut = WorldToLocal(vecSlot, Angle(0, 0, 0), vecRoot, angSlot)
		end
		table.insert(tblModel, {Model = Part.Model, Position = vecOut, Angle = angOut, Color = Part.Color, Material = Part.Material, Scale = Part.Scale, BoneMerge = Part.BoneMerge})
	end
	return tblModel
end

local function FromItemModel(Model)
	local tblParts = {}
	if isstring(Model) then Model = {{Model = Model, Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0)}} end
	if not istable(Model) then return tblParts end
	local vecRoot, angRoot
	for Index, Info in ipairs(Model) do
		local vecLocal = Info.Position and Vector(Info.Position) or Vector(0, 0, 0)
		local angLocal = Info.Angle and Angle(Info.Angle.p, Info.Angle.y, Info.Angle.r) or Angle(0, 0, 0)
		local vecSlot, angSlot
		if Index == 1 then
			angSlot = angLocal
			vecSlot = LocalToWorld(vecLocal, Angle(0, 0, 0), vector_origin, angSlot)
			vecRoot, angRoot = vecSlot, angSlot
		else
			local _, angWorld = LocalToWorld(vector_origin, angLocal, vector_origin, angRoot)
			angSlot = angWorld
			vecSlot = LocalToWorld(vecLocal, Angle(0, 0, 0), vecRoot, angSlot)
		end
		local vecBody, angBody = FromSlotSpace(vecSlot, angSlot)
		local Scale = Info.Scale
		if isnumber(Scale) then Scale = Vector(Scale, Scale, Scale) end
		if Scale then Scale = Vector(Scale) end
		local Col = Info.Color and Color(Info.Color.r, Info.Color.g, Info.Color.b, 255) or nil
		table.insert(tblParts, {Model = Info.Model, Pos = vecBody, Ang = angBody, Scale = Scale, Color = Col, Material = Info.Material, BoneMerge = Info.BoneMerge})
	end
	return tblParts
end

local PreviewItem = "ud_armorbuilder_preview"

local function ModelExists(strModel)
	if not isstring(strModel) or strModel == "" then return false end
	return util.IsValidModel(strModel) or file.Exists(strModel, "GAME")
end

hook.Remove("Think", "UD_PaperDollEditorHideWorn")
hook.Remove("PreDrawOpaqueRenderables", "UD_PaperDollEditorPreview")
hook.Remove("PostDrawOpaqueRenderables", "UD_PaperDollEditorPreview")

local function SlotEntity(strSlot)
	local tblEnts = GAMEMODE.PaperDollEnts and GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()]
	return tblEnts and tblEnts[strSlot or ""]
end

local function RestoreSlot(strSlot)
	local ply = LocalPlayer()
	if not strSlot or not IsValid(ply) then return end
	ply:PaperDollBuildSlot(strSlot, ply:GetSlot(strSlot))
end

local function RemovePreview()
	RestoreSlot(Editor.PreviewSlot)
	Editor.PreviewSlot = nil
	Editor.PreviewSig = nil
	Editor.Preview = {}
	GAMEMODE.DataBase.Items[PreviewItem] = nil
end

local function RebuildPreview()
	Editor.PreviewSig = nil
end

local function ApplyVisuals(entPart, Part)
	entPart:SetNoDraw(false)
	entPart:SetMaterial(Part.Material or "")
	local Col = Part.Color or Color(255, 255, 255, 255)
	entPart:SetColor(Color(Col.r, Col.g, Col.b, 255))
	if Part.Scale then
		local matScale = Matrix()
		matScale:Scale(Part.Scale)
		entPart:EnableMatrix("RenderMultiply", matScale)
	else
		entPart:DisableMatrix("RenderMultiply")
	end
end

hook.Add("Think", "UD_PaperDollEditorPreview", function()
	if not Editor.IsOpen or not Editor.Slot then return end
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	if Editor.PreviewSlot and Editor.PreviewSlot ~= Editor.Slot then
		RestoreSlot(Editor.PreviewSlot)
		Editor.PreviewSlot = nil
		Editor.PreviewSig = nil
	end

	local tblIndices, tblModel, tblSig = {}, {}, {}
	for Index, Info in ipairs(ToItemModel()) do
		if ModelExists(Info.Model) then
			table.insert(tblIndices, Index)
			table.insert(tblModel, Info)
			table.insert(tblSig, string.lower(Info.Model) .. (Info.BoneMerge and "#bm" or ""))
		end
	end
	local tblItem = GAMEMODE.DataBase.Items[PreviewItem] or {Name = PreviewItem, PrintName = "Armor Builder preview"}
	tblItem.Model = tblModel
	GAMEMODE.DataBase.Items[PreviewItem] = tblItem

	local strSig = table.concat(tblSig, "|")
	local entRoot = SlotEntity(Editor.Slot)
	local boolWrong = (#tblModel > 0 and (not IsValid(entRoot) or entRoot.Item ~= PreviewItem)) or (#tblModel == 0 and IsValid(entRoot))
	if strSig ~= Editor.PreviewSig or boolWrong then
		ply:PaperDollBuildSlot(Editor.Slot, #tblModel > 0 and PreviewItem or nil)
		Editor.PreviewSig = strSig
		Editor.PreviewSlot = Editor.Slot
		entRoot = SlotEntity(Editor.Slot)
	end

	Editor.Preview = {}
	if not IsValid(entRoot) then return end
	local tblEnts = {entRoot}
	for _, entKid in ipairs(entRoot.Children or {}) do table.insert(tblEnts, entKid) end
	for Number, Index in ipairs(tblIndices) do
		local entPart = tblEnts[Number]
		if IsValid(entPart) then
			ApplyVisuals(entPart, Editor.Parts[Index])
			Editor.Preview[Index] = entPart
		end
	end
end)

hook.Add("PostDrawTranslucentRenderables", "UD_PaperDollEditorSelection", function(bDepth, bSkybox)
	if bSkybox or not Editor.IsOpen or not Editor.Selected then return end
	local entPart = Editor.Preview[Editor.Selected]
	if not IsValid(entPart) then return end
	local vecMin, vecMax = entPart:GetModelBounds()
	local Part = Editor.Parts[Editor.Selected]
	if Part and Part.Scale then
		vecMin = Vector(vecMin.x * Part.Scale.x, vecMin.y * Part.Scale.y, vecMin.z * Part.Scale.z)
		vecMax = Vector(vecMax.x * Part.Scale.x, vecMax.y * Part.Scale.y, vecMax.z * Part.Scale.z)
	end
	render.DrawWireframeBox(entPart:GetPos(), entPart:GetAngles(), vecMin, vecMax, Color(255, 200, 40), false)
end)

local function MirrorPart(Part)
	local function Flip(vec) return Vector(vec.x, -vec.y, vec.z) end
	local vecForward, vecLeft, vecUp = Part.Ang:Forward(), -Part.Ang:Right(), Part.Ang:Up()
	local tblAxes = {Flip(vecForward), Flip(vecLeft), Flip(vecUp)}
	local intAxis, numBest = 1, -1
	for Index, vec in ipairs({vecForward, vecLeft, vecUp}) do
		if math.abs(vec.y) > numBest then intAxis, numBest = Index, math.abs(vec.y) end
	end
	tblAxes[intAxis] = -tblAxes[intAxis]
	local angNew = tblAxes[1]:AngleEx(tblAxes[3])
	return {Model = Part.Model, Pos = Flip(Part.Pos), Ang = angNew, Scale = Part.Scale and Vector(Part.Scale) or nil, Color = Part.Color, Material = Part.Material}
end

local function CopyPart(Part)
	return {Model = Part.Model, Pos = Vector(Part.Pos), Ang = Angle(Part.Ang.p, Part.Ang.y, Part.Ang.r), Scale = Part.Scale and Vector(Part.Scale) or nil, Color = Part.Color, Material = Part.Material, BoneMerge = Part.BoneMerge}
end

local function BuildLua()
	local tblLines = {}
	for _, Info in ipairs(ToItemModel()) do
		local strColor = Info.Color and string.format("Color(%d, %d, %d, 255)", Info.Color.r, Info.Color.g, Info.Color.b) or "nil"
		local strMaterial = Info.Material and ("\"" .. Info.Material .. "\"") or "nil"
		local strScale = "nil"
		if Info.Scale and (Info.Scale.x ~= 1 or Info.Scale.y ~= 1 or Info.Scale.z ~= 1) then
			strScale = "Vector(" .. Num(Info.Scale.x, 3) .. ", " .. Num(Info.Scale.y, 3) .. ", " .. Num(Info.Scale.z, 3) .. ")"
		end
		local strPos = "Vector(" .. Num(Info.Position.x, 2) .. ", " .. Num(Info.Position.y, 2) .. ", " .. Num(Info.Position.z, 2) .. ")"
		local strAng = "Angle(" .. Num(Info.Angle.p, 1) .. ", " .. Num(Info.Angle.y, 1) .. ", " .. Num(Info.Angle.r, 1) .. ")"
		local strLine = "Item = AddModel(Item, \"" .. Info.Model .. "\", " .. strPos .. ", " .. strAng
		if strColor ~= "nil" or strMaterial ~= "nil" or strScale ~= "nil" then
			strLine = strLine .. ", " .. strColor .. ", " .. strMaterial .. ", " .. strScale
		end
		table.insert(tblLines, strLine .. ")")
		if Info.BoneMerge then table.insert(tblLines, "Item.Model[#Item.Model].BoneMerge = true") end
	end
	return table.concat(tblLines, "\n")
end

local function Notify(strText)
	chat.AddText(Color(255, 200, 40), "[Armor Builder] ", Color(255, 255, 255), strText)
end

local function AddSlider(Parent, strLabel, numMin, numMax, intDecimals, fnChanged)
	local Slider = vgui.Create("DNumSlider", Parent)
	Slider:Dock(TOP)
	Slider:DockMargin(4, 0, 4, 0)
	Slider:SetTall(22)
	Slider:SetText(strLabel)
	Slider:SetMin(numMin)
	Slider:SetMax(numMax)
	Slider:SetDecimals(intDecimals)
	Slider.Label:SetTextColor(Color(30, 30, 30))
	Slider.OnValueChanged = function(self, Value)
		if Editor.Syncing then return end
		fnChanged(tonumber(Value) or 0)
	end
	return Slider
end

local function AddHeader(Parent, strText)
	local Label = vgui.Create("DLabel", Parent)
	Label:Dock(TOP)
	Label:DockMargin(4, 8, 4, 2)
	Label:SetText(strText)
	Label:SetFont("DermaDefaultBold")
	Label:SetTextColor(Color(20, 20, 20))
	return Label
end

local function AddButtonRow(Parent, tblButtons)
	local Row = vgui.Create("DPanel", Parent)
	Row:Dock(TOP)
	Row:DockMargin(4, 2, 4, 2)
	Row:SetTall(22)
	Row:SetPaintBackground(false)
	local tblMade = {}
	for _, Info in ipairs(tblButtons) do
		local Button = vgui.Create("DButton", Row)
		Button:SetText(Info[1])
		Button.DoClick = Info[2]
		table.insert(tblMade, Button)
	end
	Row.PerformLayout = function(self, w, h)
		local intWidth = math.floor((w - (#tblMade - 1) * 4) / #tblMade)
		for Index, Button in ipairs(tblMade) do
			Button:SetPos((Index - 1) * (intWidth + 4), 0)
			Button:SetSize(intWidth, h)
		end
	end
	return Row, tblMade
end

function Editor.Open()
	if IsValid(Editor.Frame) then Editor.Frame:Close() end
	local Frame = vgui.Create("DFrame")
	Editor.Frame = Frame
	Frame:SetSize(390, math.min(ScrH() - 80, 760))
	Frame:SetPos(20, 40)
	Frame:SetTitle("Armor Builder")
	Frame:SetSizable(false)
	Frame:MakePopup()
	Frame:SetKeyboardInputEnabled(true)
	Editor.IsOpen = true
	Editor.CurrentCamRotation = Editor.CurrentCamRotation or 0
	Editor.CurrentCamDistance = Editor.CurrentCamDistance or -40
	Editor.CurrentCamHeight = Editor.CurrentCamHeight or 0
	Frame.OnClose = function()
		Editor.IsOpen = false
		RemovePreview()
		Editor.CurrentCamRotation = nil
		Editor.CurrentCamDistance = nil
		Editor.CurrentCamHeight = nil
	end

	local Body = vgui.Create("DScrollPanel", Frame)
	Body:Dock(FILL)
	Body.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(215, 205, 185))
	end

	local Controls = {}

	local function SelectedPart()
		return Editor.Selected and Editor.Parts[Editor.Selected]
	end

	local function RefreshList()
		Controls.List:Clear()
		for Index, Part in ipairs(Editor.Parts) do
			local strModel = string.GetFileFromFilename(Part.Model or "?")
			if Part.BoneMerge then strModel = strModel .. " (fits the rig)" end
			Controls.List:AddLine(Index, strModel)
		end
		if Editor.Selected and Controls.List:GetLine(Editor.Selected) then
			Controls.List:SelectItem(Controls.List:GetLine(Editor.Selected))
		end
	end

	local function SyncControls()
		local Part = SelectedPart()
		Editor.Syncing = true
		local vecPos = Part and Part.Pos or Vector(0, 0, 0)
		local angAng = Part and Part.Ang or Angle(0, 0, 0)
		local vecScale = Part and Part.Scale or Vector(1, 1, 1)
		Controls.PosX:SetValue(vecPos.x)
		Controls.PosY:SetValue(vecPos.y)
		Controls.PosZ:SetValue(vecPos.z)
		Controls.AngP:SetValue(angAng.p)
		Controls.AngY:SetValue(angAng.y)
		Controls.AngR:SetValue(angAng.r)
		Controls.ScaleX:SetValue(vecScale.x)
		Controls.ScaleY:SetValue(vecScale.y)
		Controls.ScaleZ:SetValue(vecScale.z)
		Controls.ModelEntry:SetValue(Part and Part.Model or "")
		Controls.MaterialEntry:SetValue(Part and Part.Material or "")
		local Col = Part and Part.Color or Color(255, 255, 255, 255)
		Controls.Color:SetColor(Color(Col.r, Col.g, Col.b, 255))
		Editor.Syncing = false
	end

	local function UpdatePartVisuals()
		local Part = SelectedPart()
		local entPart = Editor.Preview[Editor.Selected or 0]
		if Part and IsValid(entPart) then ApplyVisuals(entPart, Part) end
	end

	local function Rebuild()
		RebuildPreview()
		RefreshList()
		SyncControls()
	end

	local function SetSlot(strSlot)
		Editor.Slot = strSlot
		local tblSlot = SlotTableOf(strSlot)
		Controls.PosHeader:SetText(tblSlot and tblSlot.BodyAngle and "Position (forward / left / up)" or "Position (slot x / y / z)")
		Controls.AngHeader:SetText(tblSlot and tblSlot.BodyAngle and "Angle (relative to the body)" or "Angle (relative to the slot)")
	end

	local function LoadWorn()
		local strItem = LocalPlayer().Data and LocalPlayer().Data.Paperdoll and LocalPlayer().Data.Paperdoll[Editor.Slot]
		local tblItem = strItem and ItemTable(strItem)
		if not tblItem then
			Notify("Nothing is worn in that slot. Start with Add part.")
			Editor.Parts = {}
		else
			Editor.Parts = FromItemModel(tblItem.Model)
			Notify("Loaded " .. (tblItem.PrintName or strItem) .. ".")
		end
		Editor.Selected = #Editor.Parts > 0 and 1 or nil
		Rebuild()
	end

	AddHeader(Body, "Slot")
	local SlotBox = vgui.Create("DComboBox", Body)
	SlotBox:Dock(TOP)
	SlotBox:DockMargin(4, 0, 4, 2)
	SlotBox:SetTall(22)
	local tblSlotNames = {}
	for strName, tblSlot in pairs(GAMEMODE.DataBase.Slots) do
		if tblSlot.Attachment and not tblSlot.NoModel then table.insert(tblSlotNames, strName) end
	end
	table.sort(tblSlotNames)
	for _, strName in ipairs(tblSlotNames) do
		SlotBox:AddChoice((GAMEMODE.DataBase.Slots[strName].PrintName or strName) .. "  (" .. strName .. ")", strName)
	end
	SlotBox.OnSelect = function(self, Index, Text, strSlot)
		SetSlot(strSlot)
		if Editor.KeepDesign then
			Rebuild()
		else
			LoadWorn()
		end
	end

	AddButtonRow(Body, {
		{"Load worn item", function() if Editor.Slot then LoadWorn() end end},
		{"Start empty", function()
			Editor.Parts = {}
			Editor.Selected = nil
			Rebuild()
		end},
	})

	AddHeader(Body, "Parts")
	local List = vgui.Create("DListView", Body)
	List:Dock(TOP)
	List:DockMargin(4, 0, 4, 2)
	List:SetTall(110)
	List:SetMultiSelect(false)
	List:AddColumn("#"):SetFixedWidth(24)
	List:AddColumn("Model")
	List.OnRowSelected = function(self, Index, Line)
		Editor.Selected = tonumber(Line:GetColumnText(1))
		SyncControls()
	end
	Controls.List = List

	AddButtonRow(Body, {
		{"Add part", function()
			if not Editor.Slot then Notify("Pick a slot first.") return end
			local Base = SelectedPart()
			local Part = Base and CopyPart(Base) or {Model = "models/hunter/plates/plate05x05.mdl", Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0), Scale = Vector(0.2, 0.2, 0.2)}
			Part.BoneMerge = nil
			if Base then Part.Pos = Part.Pos + Vector(0, 0, 2) end
			table.insert(Editor.Parts, Part)
			Editor.Selected = #Editor.Parts
			Rebuild()
		end},
		{"Duplicate", function()
			local Part = SelectedPart()
			if not Part then return end
			table.insert(Editor.Parts, CopyPart(Part))
			Editor.Selected = #Editor.Parts
			Rebuild()
		end},
		{"Mirror", function()
			local Part = SelectedPart()
			if not Part or Part.BoneMerge then return end
			table.insert(Editor.Parts, MirrorPart(Part))
			Editor.Selected = #Editor.Parts
			Rebuild()
		end},
		{"Remove", function()
			if not Editor.Selected then return end
			table.remove(Editor.Parts, Editor.Selected)
			Editor.Selected = #Editor.Parts > 0 and math.min(Editor.Selected, #Editor.Parts) or nil
			Rebuild()
		end},
	})

	AddHeader(Body, "Model")
	local ModelRow = vgui.Create("DPanel", Body)
	ModelRow:Dock(TOP)
	ModelRow:DockMargin(4, 0, 4, 2)
	ModelRow:SetTall(22)
	ModelRow:SetPaintBackground(false)
	local ModelEntry = vgui.Create("DTextEntry", ModelRow)
	ModelEntry:Dock(FILL)
	ModelEntry.OnEnter = function(self)
		local Part = SelectedPart()
		local strModel = string.Trim(self:GetValue())
		if not Part then return end
		if not ModelExists(strModel) then Notify("Model not found: " .. strModel) return end
		Part.Model = strModel
		Part.BoneMerge = nil
		Rebuild()
	end
	local ModelPick = vgui.Create("DButton", ModelRow)
	ModelPick:Dock(RIGHT)
	ModelPick:SetWide(70)
	ModelPick:SetText("Browse")
	ModelPick.DoClick = function()
		local Menu = DermaMenu()
		for _, Group in ipairs(PropGroups) do
			local Sub = Menu:AddSubMenu(Group[1])
			for _, Entry in ipairs(Group[2]) do
				if ModelExists(Entry[2]) then
					Sub:AddOption(Entry[1], function()
						ModelEntry:SetValue(Entry[2])
						ModelEntry:OnEnter()
					end)
				end
			end
		end
		Menu:Open()
	end
	Controls.ModelEntry = ModelEntry

	local function PosChanged(Axis)
		return function(Value)
			local Part = SelectedPart()
			if not Part then return end
			Part.Pos = Vector(Part.Pos)
			Part.Pos[Axis] = Value
		end
	end
	Controls.PosHeader = AddHeader(Body, "Position")
	Controls.PosX = AddSlider(Body, "Forward / X", -40, 40, 2, PosChanged("x"))
	Controls.PosY = AddSlider(Body, "Left / Y", -40, 40, 2, PosChanged("y"))
	Controls.PosZ = AddSlider(Body, "Up / Z", -40, 40, 2, PosChanged("z"))

	local function AngChanged(Key)
		return function(Value)
			local Part = SelectedPart()
			if not Part then return end
			Part.Ang = Angle(Part.Ang.p, Part.Ang.y, Part.Ang.r)
			Part.Ang[Key] = Value
		end
	end
	Controls.AngHeader = AddHeader(Body, "Angle")
	Controls.AngP = AddSlider(Body, "Pitch", -180, 180, 1, AngChanged("p"))
	Controls.AngY = AddSlider(Body, "Yaw", -180, 180, 1, AngChanged("y"))
	Controls.AngR = AddSlider(Body, "Roll", -180, 180, 1, AngChanged("r"))

	AddHeader(Body, "Scale")
	local UniformBox = vgui.Create("DCheckBoxLabel", Body)
	UniformBox:Dock(TOP)
	UniformBox:DockMargin(4, 0, 4, 2)
	UniformBox:SetText("Uniform (X moves all three)")
	UniformBox:SetTextColor(Color(20, 20, 20))
	UniformBox:SetValue(false)
	local function ScaleChanged(Axis)
		return function(Value)
			local Part = SelectedPart()
			if not Part then return end
			Part.Scale = Part.Scale and Vector(Part.Scale) or Vector(1, 1, 1)
			if Axis == "x" and UniformBox:GetChecked() then
				local numRatio = Part.Scale.x ~= 0 and Value / Part.Scale.x or 1
				Part.Scale = Vector(Value, Part.Scale.y * numRatio, Part.Scale.z * numRatio)
				Editor.Syncing = true
				Controls.ScaleY:SetValue(Part.Scale.y)
				Controls.ScaleZ:SetValue(Part.Scale.z)
				Editor.Syncing = false
			else
				Part.Scale[Axis] = Value
			end
			UpdatePartVisuals()
		end
	end
	Controls.ScaleX = AddSlider(Body, "X", 0.005, 3, 3, ScaleChanged("x"))
	Controls.ScaleY = AddSlider(Body, "Y", 0.005, 3, 3, ScaleChanged("y"))
	Controls.ScaleZ = AddSlider(Body, "Z", 0.005, 3, 3, ScaleChanged("z"))

	AddHeader(Body, "Material")
	local MatRow = vgui.Create("DPanel", Body)
	MatRow:Dock(TOP)
	MatRow:DockMargin(4, 0, 4, 2)
	MatRow:SetTall(22)
	MatRow:SetPaintBackground(false)
	local MaterialEntry = vgui.Create("DTextEntry", MatRow)
	MaterialEntry:Dock(FILL)
	MaterialEntry.OnEnter = function(self)
		local Part = SelectedPart()
		if not Part then return end
		local strMaterial = string.Trim(self:GetValue())
		Part.Material = strMaterial ~= "" and strMaterial or nil
		UpdatePartVisuals()
	end
	local MatPick = vgui.Create("DButton", MatRow)
	MatPick:Dock(RIGHT)
	MatPick:SetWide(70)
	MatPick:SetText("Browse")
	MatPick.DoClick = function()
		local Menu = DermaMenu()
		Menu:AddOption("Model's own material", function()
			MaterialEntry:SetValue("")
			MaterialEntry:OnEnter()
		end)
		for _, Group in ipairs(MaterialGroups) do
			local Sub = Menu:AddSubMenu(Group[1])
			for _, Entry in ipairs(Group[2]) do
				Sub:AddOption(Entry[1], function()
					MaterialEntry:SetValue(Entry[2])
					MaterialEntry:OnEnter()
				end)
			end
		end
		Menu:Open()
	end
	Controls.MaterialEntry = MaterialEntry

	AddHeader(Body, "Tint")
	local Mixer = vgui.Create("DColorMixer", Body)
	Mixer:Dock(TOP)
	Mixer:DockMargin(4, 0, 4, 2)
	Mixer:SetTall(110)
	Mixer:SetPalette(false)
	Mixer:SetAlphaBar(false)
	Mixer:SetWangs(true)
	Mixer.ValueChanged = function(self, Col)
		if Editor.Syncing then return end
		local Part = SelectedPart()
		if not Part then return end
		Part.Color = Color(Col.r, Col.g, Col.b, 255)
		UpdatePartVisuals()
	end
	Controls.Color = Mixer
	AddButtonRow(Body, {
		{"No tint", function()
			local Part = SelectedPart()
			if not Part then return end
			Part.Color = nil
			UpdatePartVisuals()
			SyncControls()
		end},
	})

	AddHeader(Body, "Camera")
	local CamRot = AddSlider(Body, "Around", -180, 180, 0, function(Value) Editor.CurrentCamRotation = Value end)
	local CamDist = AddSlider(Body, "Distance", -60, 60, 0, function(Value) Editor.CurrentCamDistance = Value end)
	local CamHeight = AddSlider(Body, "Height", -45, 25, 0, function(Value) Editor.CurrentCamHeight = Value end)
	CamRot:SetValue(Editor.CurrentCamRotation)
	CamDist:SetValue(Editor.CurrentCamDistance)
	CamHeight:SetValue(Editor.CurrentCamHeight)

	AddHeader(Body, "Finish")
	AddButtonRow(Body, {
		{"Copy item Lua", function()
			if #Editor.Parts == 0 then Notify("No parts yet.") return end
			local strLua = BuildLua()
			SetClipboardText(strLua)
			print(strLua)
			Notify("Copied " .. #Editor.Parts .. " AddModel lines (also printed in the console).")
		end},
		{"Apply to worn item", function()
			local strItem = LocalPlayer().Data and LocalPlayer().Data.Paperdoll and LocalPlayer().Data.Paperdoll[Editor.Slot or ""]
			local tblItem = strItem and ItemTable(strItem)
			if not tblItem or #Editor.Parts == 0 then Notify("Wear an item in this slot first.") return end
			tblItem.Model = ToItemModel()
			LocalPlayer():PaperDollBuildSlot(Editor.Slot, strItem)
			Notify((tblItem.PrintName or strItem) .. " now uses this design until the map changes. Paste the Lua to keep it.")
		end},
	})
	local Hint = vgui.Create("DLabel", Body)
	Hint:Dock(TOP)
	Hint:DockMargin(4, 4, 4, 6)
	Hint:SetWrap(true)
	Hint:SetAutoStretchVertical(true)
	Hint:SetTextColor(Color(40, 40, 40))
	Hint:SetText("Press Enter after typing a model or material path. Positions are measured from the slot point. Mirror copies the part to the other side of the body. Paste copied lines into an item in gamemode/core/sharedfiles/database/items/.")

	local tblWorn = LocalPlayer().Data and LocalPlayer().Data.Paperdoll or {}
	local strStart = Editor.Slot
	if not strStart then
		for _, strName in ipairs(tblSlotNames) do
			if tblWorn[strName] then strStart = strName break end
		end
	end
	strStart = strStart or "slot_helm"
	Editor.KeepDesign = Editor.Slot == strStart and #Editor.Parts > 0
	for Index, strName in ipairs(tblSlotNames) do
		if strName == strStart then SlotBox:ChooseOptionID(Index) end
	end
	Editor.KeepDesign = nil
end

concommand.Add("UD_Dev_EditPaperDoll", function() Editor.Open() end)

concommand.Add("UD_Dev_EditPaperDoll_Debug", function()
	local ply = LocalPlayer()
	local strWorn = ply.Data and ply.Data.Paperdoll and ply.Data.Paperdoll[Editor.Slot or ""]
	print("[Armor Builder] open:", Editor.IsOpen, "slot:", Editor.Slot, "parts:", #Editor.Parts, "worn in slot:", strWorn)
	local tblEnts = GAMEMODE.PaperDollEnts and GAMEMODE.PaperDollEnts[ply:SteamID64()] or {}
	for strSlot, entRoot in pairs(tblEnts) do
		if IsValid(entRoot) then
			print("worn entity", strSlot, entRoot.Item, entRoot:GetModel(), "nodraw:", entRoot:GetNoDraw(), "pos:", entRoot:GetPos())
		else
			print("worn entity", strSlot, "invalid")
		end
	end
	for Index, entPart in pairs(Editor.Preview) do
		if IsValid(entPart) then
			print("preview part", Index, entPart:GetModel(), "pos:", entPart:GetPos())
		else
			print("preview part", Index, "invalid")
		end
	end
	local intAttached = 0
	for _, entAny in ipairs(ents.GetAll()) do
		if entAny.Item and IsValid(entAny) and entAny:GetParent() == ply then
			intAttached = intAttached + 1
			print("attached item entity", entAny.Item, entAny:GetModel(), "nodraw:", entAny:GetNoDraw(), "pos:", entAny:GetPos())
		end
	end
	print("item entities attached to you:", intAttached)
end)
