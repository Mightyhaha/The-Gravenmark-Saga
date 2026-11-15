GM.MapEditor = {}
GM.MapEditor.Open = false
GM.MapEditor.ObjectsList = nil
GM.MapEditor.CurrentObjectSet = nil
GM.MapEditor.ObjectSets = {}
GM.MapEditor.ObjectSets["NPC_Spawnpoints"] = GM.MapEntities.NPCSpawnPoints
GM.MapEditor.ObjectSets["World_Props"] = GM.MapEntities.WorldProps
GM.MapEditor.CurrentObjectNum = nil
GM.MapEditor.Models = {}
GM.MapEditor.Models[1] = "models/props_junk/wood_crate001a.mdl"
GM.MapEditor.Models[2] = "models/props_junk/wood_crate002a.mdl"
GM.MapEditor.Models[3] = "models/props_c17/oildrum001.mdl"
GM.MapEditor.Models[4] = "models/props_c17/oildrum001_explosive.mdl"
GM.MapEditor.Models[5] = "models/props_combine/combinetower001.mdl"
GM.MapEditor.Models[6] = "models/props/CS_militia/caseofbeer01.mdl"
GM.MapEditor.Models[7] = "models/props/CS_militia/footlocker01_closed.mdl"
GM.MapEditor.Models[8] = "models/props_combine/combine_barricade_short01a.mdl"
GM.MapEditor.Models[9] = "models/props_combine/combine_barricade_short01a.mdl"
GM.MapEditor.Models[10] = "models/props_combine/combine_barricade_med01a.mdl"
GM.MapEditor.Models[11] = "models/props_combine/combine_barricade_med01b.mdl"
GM.MapEditor.Models[12] = "models/props_combine/combine_booth_short01a.mdl"
GM.MapEditor.Models[13] = "models/props_interiors/Radiator01a.mdl"
GM.MapEditor.Models[14] = "models/props_wasteland/kitchen_stove001a.mdl"
GM.MapEditor.Models[15] = "models/props/de_piranesi/pi_merlon.mdl"
GM.MapEditor.Models[16] = "models/props/de_inferno/fountain.mdl"
GM.MapEditor.Models[17] = "models/props/de_inferno/crates_fruit1.mdl"
GM.MapEditor.Models[18] = "models/props/de_inferno/crates_fruit2.mdl"
GM.MapEditor.Models[19] = "models/props/de_inferno/ClayOven.mdl"
GM.MapEditor.Models[20] = "models/props/de_inferno/bench_wood.mdl"
GM.MapEditor.Models[21] = "models/props/cs_militia/Furnace01.mdl"
GM.MapEditor.Models[22] = "models/props/cs_italy/it_mkt_table3.mdl"

if not game.SinglePlayer() then return end

function GM.MapEditor.OpenMapEditor()
	if GAMEMODE.MapEditor.Open and IsValid(GAMEMODE.MapEditor.Frame) then return end
	local MapEditorFrame = CreateGenericFrame("Map Editor  (hold C to use the mouse)", true, true)
	MapEditorFrame:SetPos(50, 50)
	MapEditorFrame:SetSize(375, 450)
	MapEditorFrame:SetMouseInputEnabled(false)
	MapEditorFrame:SetKeyboardInputEnabled(false)
	GAMEMODE.MapEditor.Frame = MapEditorFrame
	MapEditorFrame.InternalClose = MapEditorFrame.Close
	MapEditorFrame.Close = function()
		MapEditorFrame:InternalClose()
		GAMEMODE.MapEditor.Open = false
		GAMEMODE.MapEditor.Frame = nil
	end

	local ControlsList = CreateGenericList(MapEditorFrame, 5, false, true)
	ControlsList:SetPos(5, 55)
	ControlsList:SetSize(MapEditorFrame:GetWide() - 10, MapEditorFrame:GetTall() - 60)

	local ObjectSetList = vgui.Create("DComboBox", MapEditorFrame)
	local Objects = vgui.Create("DNumberWang", MapEditorFrame)
	GAMEMODE.MapEditor.ObjectsList = Objects

	ObjectSetList:SetPos(75, 30)
	ObjectSetList:SetSize(MapEditorFrame:GetWide() - 135, 20)
	for key, sets in pairs(GAMEMODE.MapEditor.ObjectSets) do ObjectSetList:AddChoice(key) end
	ObjectSetList.OnSelect = function(index, value, data)
		GAMEMODE.MapEditor.CurrentObjectSet = GAMEMODE.MapEditor.ObjectSets[data]
		GAMEMODE.MapEditor.CurrentObjectNum = 0
		GAMEMODE.MapEditor.UpatePanel()
		ControlsList:Clear()
	end

	Objects:SetPos(MapEditorFrame:GetWide() - 55, 30)
	Objects:SetSize(50, 20)
	Objects:SetDecimals(0)
	Objects:SetMin(1)
	Objects:SetMax(1)
	if GAMEMODE.MapEditor.CurrentObjectSet then
		Objects:SetMax(#GAMEMODE.MapEditor.CurrentObjectSet)
	end
	Objects.OnValueChanged = function(Panel, Index)
		Index = math.Round(Index)
		if GAMEMODE.MapEditor.CurrentObjectSet and GAMEMODE.MapEditor.CurrentObjectSet[tonumber(Index)] then
			GAMEMODE.MapEditor.CurrentObjectNum = tonumber(Index)
			if GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.NPCSpawnPoints then
				GAMEMODE.MapEditor.AddSpawnPointControls(ControlsList)
			elseif GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.WorldProps then
				GAMEMODE.MapEditor.AddWorldPropControls(ControlsList)
			end
			LocalPlayer():SetEyeAngles((GAMEMODE.MapEditor.CurrentObjectSet[tonumber(Index)].Position - LocalPlayer():GetShootPos()):Angle())
		end
	end

	local function SaveMap() RunConsoleCommand("UD_Dev_EditMap_SaveMap") end
	local SaveButton = CreateGenericImageButton(MapEditorFrame, "icon16/disk_multiple.png", "Save Map", SaveMap)
	SaveButton:SetPos(7, 32)
	SaveButton:SetSize(16, 16)

	local function AddObject()
		GAMEMODE.MapEditor.CurrentObjectNum = #GAMEMODE.MapEditor.CurrentObjectSet + 1
		if GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.NPCSpawnPoints then
			RunConsoleCommand("UD_Dev_EditMap_CreateSpawnPoint")
		elseif GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.WorldProps then
			RunConsoleCommand("UD_Dev_EditMap_CreateWorldProp")
		end
	end
	local NewSpawnButton = CreateGenericImageButton(MapEditorFrame, "icon16/brick_add.png", "New Object", AddObject)
	NewSpawnButton:SetPos(32, 32)
	NewSpawnButton:SetSize(16, 16)

	local function RemoveObject()
		ControlsList:Clear()
		if GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.NPCSpawnPoints then
			RunConsoleCommand("UD_Dev_EditMap_RemoveSpawnPoint", GAMEMODE.MapEditor.CurrentObjectNum)
		elseif GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.WorldProps then
			RunConsoleCommand("UD_Dev_EditMap_RemoveWorldProp", GAMEMODE.MapEditor.CurrentObjectNum)
		end
	end
	local RemoveButton = CreateGenericImageButton(MapEditorFrame, "icon16/delete.png", "Remove Object", RemoveObject)
	RemoveButton:SetPos(57, 32)
	RemoveButton:SetSize(16, 16)

	GAMEMODE.MapEditor.Open = true
end
concommand.Add("UD_Dev_EditMap", function() GAMEMODE.MapEditor.OpenMapEditor() end)

local function IsCursorKeyDown()
	local KeyName = input.LookupBinding("+menu_context") or "c"
	local KeyCode = input.GetKeyCode(KeyName)
	return KeyCode and KeyCode > 0 and input.IsKeyDown(KeyCode)
end

local function IsTypingInFrame(Frame)
	local Focus = vgui.GetKeyboardFocus()
	return IsValid(Focus) and Focus ~= Frame and Focus:HasParent(Frame)
end

hook.Add("Think", "UD_MapEditorCursor", function()
	local Frame = GAMEMODE.MapEditor.Frame
	if not IsValid(Frame) then return end
	local WantsCursor = IsCursorKeyDown() or IsTypingInFrame(Frame)
	if WantsCursor == Frame.UD_HasCursor then return end
	Frame.UD_HasCursor = WantsCursor
	if WantsCursor then
		Frame:MakePopup()
	else
		Frame:SetMouseInputEnabled(false)
		Frame:SetKeyboardInputEnabled(false)
	end
end)

function GM.MapEditor.UpatePanel()
	if GAMEMODE.MapEditor.Open then
		if not GAMEMODE.MapEditor.CurrentObjectSet then return end
		GAMEMODE.MapEditor.ObjectsList:SetMax(#GAMEMODE.MapEditor.CurrentObjectSet)
		if GAMEMODE.MapEditor.CurrentObjectNum > 0 and GAMEMODE.MapEditor.CurrentObjectSet[GAMEMODE.MapEditor.CurrentObjectNum] then
			GAMEMODE.MapEditor.ObjectsList:SetValue(GAMEMODE.MapEditor.CurrentObjectNum)
		end
	end
end

local function CreateEditorButton(AddList, Text, OnClick)
	local NewButton = vgui.Create("DButton")
	NewButton:SetText(Text)
	NewButton.DoClick = OnClick
	NewButton.Paint = function(self, w, h)
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, w, h)
		PaintPanel:SetStyle(4, Gray)
		PaintPanel:SetBorder(2, Tan)
		jdraw.DrawPanel(PaintPanel)
	end
	AddList:AddItem(NewButton)
	return NewButton
end

function GM.MapEditor.AddSpawnPointControls(AddList)
	AddList:Clear()
	local SpawnKey = GAMEMODE.MapEditor.CurrentObjectNum
	local SpawnTable = GAMEMODE.MapEditor.CurrentObjectSet[SpawnKey]
	local NPCName = SpawnTable.NPC or "zombie"
	local Level = SpawnTable.Level or 5
	local SpawnTime = SpawnTable.SpawnTime or 0
	local Rotation = SpawnTable.Angle and SpawnTable.Angle.y or 90

	local NPCTypes = vgui.Create("DComboBox")
	local NPCNames = table.GetKeys(GAMEMODE.DataBase.NPCs)
	table.sort(NPCNames)
	for ID, Name in ipairs(NPCNames) do
		NPCTypes:AddChoice(Name)
		if Name == NPCName then NPCTypes:ChooseOptionID(ID) end
	end
	NPCTypes.OnSelect = function(Panel, Index, Value) NPCName = Value end
	AddList:AddItem(NPCTypes)

	local LevelSlider = GAMEMODE.MapEditor.CreateGenericSlider(AddList, "Level", 50, 0)
	LevelSlider:SetMin(1)
	LevelSlider.OnValueChanged = function(Panel, Value) Level = math.Round(Value) end
	LevelSlider.UpdateSlider(Level)

	local SpawnTimeSlider = GAMEMODE.MapEditor.CreateGenericSlider(AddList, "Respawn seconds (0 = never spawns)", 600, 0)
	SpawnTimeSlider:SetMin(0)
	SpawnTimeSlider.OnValueChanged = function(Panel, Value) SpawnTime = math.Round(Value) end
	SpawnTimeSlider.UpdateSlider(SpawnTime)

	local RotationSlider = GAMEMODE.MapEditor.CreateGenericSlider(AddList, "Rotation", 180, 0)
	RotationSlider.OnValueChanged = function(Panel, Value) Rotation = math.Round(Value) end
	RotationSlider.UpdateSlider(Rotation)

	CreateEditorButton(AddList, "Move spawn point to where I'm looking", function()
		RunConsoleCommand("UD_Dev_EditMap_MoveSpawnPoint", SpawnKey)
	end)
	CreateEditorButton(AddList, "Update Server", function()
		RunConsoleCommand("UD_Dev_EditMap_UpdateSpawnPoint", SpawnKey, NPCName, Level, SpawnTime, Rotation)
	end)
end

function GM.MapEditor.AddWorldPropControls(AddList)
	AddList:Clear()
	local SpawnKey = GAMEMODE.MapEditor.CurrentObjectNum
	local SpawnTable = GAMEMODE.MapEditor.CurrentObjectSet[SpawnKey]
	local Model = IsValid(SpawnTable.Entity) and SpawnTable.Entity:GetModel() or SpawnTable.Model or "models/props_junk/garbage_metalcan001a.mdl"
	local vecOffset = Vector(0, 0, 0)
	local Rotation = 0

	local VectorControls = GAMEMODE.MapEditor.AddVectorControls(AddList)
	VectorControls.ValueChanged = function(vecValue) vecOffset = vecValue end
	VectorControls.UpdateNewValues(vecOffset)

	local RotationSlider = GAMEMODE.MapEditor.CreateGenericSlider(AddList, "Rotation", 180, 0)
	RotationSlider.OnValueChanged = function(Panel, Value) Rotation = math.Round(Value) end
	RotationSlider.UpdateSlider(Rotation)

	local ModelControls = GAMEMODE.MapEditor.AddModelControls(AddList)
	ModelControls:SetExpanded(false)
	ModelControls.ValueChanged = function(NewModel)
		Model = NewModel
		RunConsoleCommand("UD_Dev_EditMap_UpdateWorldProp", SpawnKey, NewModel, StringatizeVector(vecOffset), Rotation)
	end

	CreateEditorButton(AddList, "Update Server", function()
		RunConsoleCommand("UD_Dev_EditMap_UpdateWorldProp", SpawnKey, Model, StringatizeVector(vecOffset), Rotation)
	end)
end

function GM.MapEditor.CreateGenericCollapse(AddList, Name)
	local NewCollapseCat = vgui.Create("DCollapsibleCategory")
	NewCollapseCat:SetLabel(Name)
	NewCollapseCat.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat:GetWide(), NewCollapseCat:GetTall())
		PaintPanel:SetStyle(4, Tan)
		PaintPanel:SetBorder(1, DrakGray)
		jdraw.DrawPanel(PaintPanel)
	end
	NewCollapseCat.List = vgui.Create("DPanelList")
	NewCollapseCat.List:SetAutoSize(true)
	NewCollapseCat.List:SetSpacing(5)
	NewCollapseCat.List:SetPadding(5)
	NewCollapseCat.List:EnableHorizontal(false)
	NewCollapseCat.List.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat.List:GetWide(), NewCollapseCat.List:GetTall())
		PaintPanel:SetStyle(4, DrakGray)
		PaintPanel:SetBorder(1, Tan)
		jdraw.DrawPanel(PaintPanel)
	end
	NewCollapseCat:SetContents(NewCollapseCat.List)
	AddList:AddItem(NewCollapseCat)
	return NewCollapseCat
end

function GM.MapEditor.AddVectorControls(AddList)
	local vecCommyVector = Vector(0, 0, 0)
	local NewCollapseCat = GAMEMODE.MapEditor.CreateGenericCollapse(AddList, "Offset Controls")
	local NewXSlider = GAMEMODE.MapEditor.CreateGenericSlider(NewCollapseCat.List, "X Axis", 30)
	NewXSlider.OnValueChanged = function(self, value) vecCommyVector.x = value NewCollapseCat.ValueChanged(vecCommyVector) end
	local NewYSlider = GAMEMODE.MapEditor.CreateGenericSlider(NewCollapseCat.List, "Y Axis", 30)
	NewYSlider.OnValueChanged = function(self, value) vecCommyVector.y = value NewCollapseCat.ValueChanged(vecCommyVector) end
	local NewZSlider = GAMEMODE.MapEditor.CreateGenericSlider(NewCollapseCat.List, "Z Axis", 30)
	NewZSlider.OnValueChanged = function(self, value) vecCommyVector.z = value NewCollapseCat.ValueChanged(vecCommyVector) end
	NewCollapseCat.UpdateNewValues = function(vecNewOffset)
		NewXSlider.UpdateSlider(vecNewOffset.x)
		NewYSlider.UpdateSlider(vecNewOffset.y)
		NewZSlider.UpdateSlider(vecNewOffset.z)
	end
	return NewCollapseCat
end

function GM.MapEditor.AddModelControls(AddList)
	local IconsPerRow = 8
	local NewCollapseCat = GAMEMODE.MapEditor.CreateGenericCollapse(AddList, "Model Controls")
	NewCollapseCat.List:EnableHorizontal(true)
	for key, model in pairs(GAMEMODE.MapEditor.Models) do
		local ModelIcon = vgui.Create("SpawnIcon")
		ModelIcon:SetModel(model)
		ModelIcon:SetIconSize((AddList:GetWide() - ((IconsPerRow + 1) * 5) - 10) / IconsPerRow)
		ModelIcon.OnMousePressed = function()
			NewCollapseCat.ValueChanged(model)
		end
		NewCollapseCat.List:AddItem(ModelIcon)
	end
	return NewCollapseCat
end

function GM.MapEditor.CreateGenericSlider(AddList, Name, Range, Decimals)
	local NewSlider = vgui.Create("DNumSlider")
	NewSlider:SetText(Name)
	NewSlider:SetMin(-Range)
	NewSlider:SetMax(Range)
	NewSlider:SetDecimals(Decimals or 1)
	NewSlider.UpdateSlider = function(NewValue)
		NewSlider:SetValue(tonumber(NewValue) or 0)
	end
	AddList:AddItem(NewSlider)
	return NewSlider
end

hook.Add("HUDPaint", "UD_DrawMapObjects", function()
	if GAMEMODE.MapEditor.Open then
		for key, object in pairs(GAMEMODE.MapEditor.CurrentObjectSet or {}) do
			if not key or not object or not object.Position then return end
			local PosX, PosY = object.Position:ToScreen().x, object.Position:ToScreen().y
			local DrawColor = White
			if GAMEMODE.MapEditor.CurrentObjectNum == key then DrawColor = Blue end
			draw.SimpleTextOutlined(key, "UiBold", PosX, PosY, DrawColor, 1, 1, 1, Color(0, 0, 0, 255))
		end
	end
end)

hook.Add("GUIMouseReleased", "UD_TurnEditorCamGUIMouseReleased", function(mousecode)
	if GAMEMODE.MapEditor.Open then
		LocalPlayer():SetEyeAngles((LocalPlayer():GetEyeTrace().HitPos - LocalPlayer():GetShootPos()):Angle())
	end
end)
