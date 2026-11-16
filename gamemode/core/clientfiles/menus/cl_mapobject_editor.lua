GM.MapEditor = {}
local Editor = GM.MapEditor

Editor.Models = {
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_c17/oildrum001.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_combine/combinetower001.mdl",
	"models/props/CS_militia/caseofbeer01.mdl",
	"models/props/CS_militia/footlocker01_closed.mdl",
	"models/props_combine/combine_barricade_short01a.mdl",
	"models/props_combine/combine_barricade_med01a.mdl",
	"models/props_combine/combine_barricade_med01b.mdl",
	"models/props_combine/combine_booth_short01a.mdl",
	"models/props_interiors/Radiator01a.mdl",
	"models/props_wasteland/kitchen_stove001a.mdl",
	"models/props/de_piranesi/pi_merlon.mdl",
	"models/props/de_inferno/fountain.mdl",
	"models/props/de_inferno/crates_fruit1.mdl",
	"models/props/de_inferno/crates_fruit2.mdl",
	"models/props/de_inferno/ClayOven.mdl",
	"models/props/de_inferno/bench_wood.mdl",
	"models/props/cs_militia/Furnace01.mdl",
	"models/props/cs_italy/it_mkt_table3.mdl",
}

if not game.SinglePlayer() then return end

local MarkerRadius = 16
local SelectReach = 40
local ColorPlaced = Color(255, 255, 255, 200)
local ColorSelected = Color(255, 200, 0, 255)
local ColorPending = Color(80, 255, 80, 255)
local ColorMoving = Color(80, 200, 255, 255)
local ColorOutline = Color(0, 0, 0, 255)

Editor.Mode = "npc"
Editor.Pending = nil
Editor.SelectedKey = nil
Editor.Edit = nil
Editor.Moving = false
Editor.Dirty = false
Editor.Settings = {NPC = nil, Level = 5, SpawnTime = 30, Radius = 0, Count = 1, Yaw = 0, Model = Editor.Models[1]}

local Rebuild

local function ObjectList()
	if Editor.Mode == "npc" then return GAMEMODE.MapEntities.NPCSpawnPoints end
	return GAMEMODE.MapEntities.WorldProps
end

local function CurrentValues()
	if Editor.SelectedKey then return Editor.Edit end
	return Editor.Settings
end

local function SendCommand(...)
	RunConsoleCommand(...)
	Editor.Dirty = true
end

local function PositionArgs(Position)
	return math.Round(Position.x, 2), math.Round(Position.y, 2), math.Round(Position.z, 2)
end

local function StatusText()
	local Noun = Editor.Mode == "npc" and "spawn point" or "prop"
	local Status
	if Editor.Moving then
		Status = "Click the spot to move the selected " .. Noun .. " to. Right-click cancels."
	elseif Editor.SelectedKey then
		Status = "Editing " .. Noun .. " #" .. Editor.SelectedKey .. ". Right-click to deselect."
	elseif Editor.Pending then
		Status = "New " .. Noun .. ": choose its settings, then press Add. Right-click cancels."
	else
		Status = "Left-click the ground to place a " .. Noun .. ", or click a marker to edit it."
	end
	local Counts = #GAMEMODE.MapEntities.NPCSpawnPoints .. " spawn points, " .. #GAMEMODE.MapEntities.WorldProps .. " props"
	if Editor.Dirty then Counts = Counts .. "  -  unsaved changes" end
	return Status .. "\n" .. Counts
end

local function UpdateStatus()
	if IsValid(Editor.StatusLabel) then Editor.StatusLabel:SetText(StatusText()) end
end

local function AddLabel(Parent, Text)
	local Label = vgui.Create("DLabel", Parent)
	Label:Dock(TOP)
	Label:DockMargin(0, 0, 0, 4)
	Label:SetWrap(true)
	Label:SetAutoStretchVertical(true)
	Label:SetDark(true)
	Label:SetText(Text)
	return Label
end

local function AddButton(Parent, Text, OnClick)
	local Button = vgui.Create("DButton", Parent)
	Button:Dock(TOP)
	Button:DockMargin(0, 4, 0, 0)
	Button:SetTall(24)
	Button:SetText(Text)
	Button.DoClick = OnClick
	return Button
end

local function AddSlider(Parent, Text, Min, Max, Value, OnChange)
	local Slider = vgui.Create("DNumSlider", Parent)
	Slider:Dock(TOP)
	Slider:DockMargin(0, 0, 0, 2)
	Slider:SetText(Text)
	Slider:SetMinMax(Min, Max)
	Slider:SetDecimals(0)
	Slider:SetDark(true)
	Slider:SetValue(tonumber(Value) or Min)
	Slider.OnValueChanged = function(_, NewValue) OnChange(math.Round(NewValue)) end
	return Slider
end

local function Deselect()
	Editor.SelectedKey = nil
	Editor.Edit = nil
	Editor.Moving = false
	Rebuild()
end

local function Cancel()
	if Editor.Moving then
		Editor.Moving = false
		UpdateStatus()
	elseif Editor.Pending then
		Editor.Pending = nil
		Rebuild()
	elseif Editor.SelectedKey then
		Deselect()
	end
end

local function Select(Key)
	local Object = ObjectList()[Key]
	if not Object then return end
	Editor.Pending = nil
	Editor.Moving = false
	Editor.SelectedKey = Key
	local Yaw = Object.Angle and math.Round(math.NormalizeAngle(Object.Angle.y)) or 0
	if Editor.Mode == "npc" then
		Editor.Edit = {NPC = Object.NPC, Level = Object.Level or 5, SpawnTime = Object.SpawnTime or 30, Radius = Object.Radius or 0, Count = Object.Count or 1, Yaw = Yaw}
	else
		Editor.Edit = {Model = Object.Model, Yaw = Yaw}
	end
	Rebuild()
end

local function PlacePending(Position)
	Editor.SelectedKey = nil
	Editor.Edit = nil
	Editor.Moving = false
	Editor.Pending = {Position = Position}
	Editor.Settings.Yaw = math.Round(math.NormalizeAngle((LocalPlayer():GetPos() - Position):Angle().y))
	Rebuild()
end

local function BuildSpawnControls(Body, Values)
	local AddSpawnButton

	local NPCBox = vgui.Create("DComboBox", Body)
	NPCBox:Dock(TOP)
	NPCBox:DockMargin(0, 0, 0, 4)
	NPCBox:SetValue("Choose an NPC...")
	local Names = table.GetKeys(GAMEMODE.DataBase.NPCs)
	table.sort(Names)
	for _, Name in ipairs(Names) do
		local NPC = GAMEMODE.DataBase.NPCs[Name]
		NPCBox:AddChoice(Name .. "  (" .. (NPC.PrintName or Name) .. ")", Name, Name == Values.NPC)
	end
	NPCBox.OnSelect = function(_, _, _, Data)
		Values.NPC = Data
		if IsValid(AddSpawnButton) then AddSpawnButton:SetEnabled(true) end
	end

	AddSlider(Body, "Level", 1, 100, Values.Level, function(Value) Values.Level = Value end)
	AddSlider(Body, "Respawn (seconds)", 1, 900, Values.SpawnTime, function(Value) Values.SpawnTime = Value end)
	AddSlider(Body, "How many NPCs", 1, 20, Values.Count, function(Value) Values.Count = Value end)
	AddSlider(Body, "Spawn area radius", 0, 1000, Values.Radius, function(Value) Values.Radius = Value end)
	AddSlider(Body, "Facing", -180, 180, Values.Yaw, function(Value) Values.Yaw = Value end)

	if Editor.SelectedKey then
		local Key = Editor.SelectedKey
		AddButton(Body, "Apply changes", function()
			SendCommand("UD_Dev_EditMap_UpdateSpawnPoint", Key, Values.NPC, Values.Level, Values.SpawnTime, Values.Yaw, Values.Radius, Values.Count)
			UpdateStatus()
		end)
		AddButton(Body, "Move to a new spot", function()
			Editor.Moving = true
			UpdateStatus()
		end)
		AddButton(Body, "Remove", function()
			SendCommand("UD_Dev_EditMap_RemoveSpawnPoint", Key)
			Deselect()
		end)
		AddButton(Body, "Deselect", Deselect)
	else
		AddSpawnButton = AddButton(Body, "Add spawn point", function()
			if not Values.NPC or not Editor.Pending then return end
			local x, y, z = PositionArgs(Editor.Pending.Position)
			SendCommand("UD_Dev_EditMap_AddSpawnPoint", x, y, z, Values.Yaw, Values.NPC, Values.Level, Values.SpawnTime, Values.Radius, Values.Count)
			Editor.Pending = nil
			Rebuild()
		end)
		AddSpawnButton:SetEnabled(Values.NPC ~= nil)
		AddButton(Body, "Cancel", Cancel)
	end
end

local function BuildPropControls(Body, Values)
	local Grid = vgui.Create("DIconLayout", Body)
	Grid:Dock(TOP)
	Grid:DockMargin(0, 0, 0, 4)
	Grid:SetSpaceX(2)
	Grid:SetSpaceY(2)
	for _, Model in ipairs(Editor.Models) do
		local Icon = Grid:Add("SpawnIcon")
		Icon:SetSize(52, 52)
		Icon:SetModel(Model)
		Icon:SetTooltip(Model)
		Icon.DoClick = function() Values.Model = Model end
		Icon.PaintOver = function(_, w, h)
			if string.lower(Values.Model or "") ~= string.lower(Model) then return end
			surface.SetDrawColor(ColorSelected)
			surface.DrawOutlinedRect(0, 0, w, h, 2)
		end
	end

	AddSlider(Body, "Facing", -180, 180, Values.Yaw, function(Value) Values.Yaw = Value end)

	if Editor.SelectedKey then
		local Key = Editor.SelectedKey
		AddButton(Body, "Apply changes", function()
			SendCommand("UD_Dev_EditMap_SetWorldProp", Key, Values.Model, Values.Yaw)
			UpdateStatus()
		end)
		AddButton(Body, "Move to a new spot", function()
			Editor.Moving = true
			UpdateStatus()
		end)
		AddButton(Body, "Remove", function()
			SendCommand("UD_Dev_EditMap_RemoveWorldProp", Key)
			Deselect()
		end)
		AddButton(Body, "Deselect", Deselect)
	else
		AddButton(Body, "Add prop", function()
			if not Values.Model or not Editor.Pending then return end
			local x, y, z = PositionArgs(Editor.Pending.Position)
			SendCommand("UD_Dev_EditMap_AddWorldProp", x, y, z, Values.Yaw, Values.Model)
			Editor.Pending = nil
			Rebuild()
		end)
		AddButton(Body, "Cancel", Cancel)
	end
end

Rebuild = function()
	if not IsValid(Editor.Frame) then return end
	UpdateStatus()
	local Body = Editor.Body
	Body:Clear()
	if not Editor.Pending and not Editor.SelectedKey then
		AddLabel(Body, "Left-click: place a new marker, or select an existing one.\nRight-click: cancel or deselect.\nHold C: use the mouse on this window, or click in the world with it.\nRun UD_Dev_EditMap again to close the editor.\nPress Save map when you are done.")
		return
	end
	if Editor.Mode == "npc" then
		BuildSpawnControls(Body, CurrentValues())
	else
		BuildPropControls(Body, CurrentValues())
	end
end

local function FlatDistance(A, B)
	return math.sqrt((A.x - B.x) ^ 2 + (A.y - B.y) ^ 2)
end

local function FindSpawnPointAt(Position)
	local BestKey, BestDistance = nil, SelectReach
	for Key, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
		local Distance = FlatDistance(Position, Spawn.Position)
		if Distance < BestDistance and math.abs(Position.z - Spawn.Position.z) < 96 then
			BestKey, BestDistance = Key, Distance
		end
	end
	return BestKey
end

local function FindWorldPropAt(Trace)
	if IsValid(Trace.Entity) then
		for Key, Prop in ipairs(GAMEMODE.MapEntities.WorldProps) do
			if Prop.EntIndex == Trace.Entity:EntIndex() then return Key end
		end
	end
	local BestKey, BestDistance = nil, SelectReach
	for Key, Prop in ipairs(GAMEMODE.MapEntities.WorldProps) do
		local Distance = Trace.HitPos:Distance(Prop.Position)
		if Distance < BestDistance then
			BestKey, BestDistance = Key, Distance
		end
	end
	return BestKey
end

local function HandleWorldClick(Trace)
	if not Trace or not Trace.Hit then return end
	if Editor.Moving and Editor.SelectedKey then
		local x, y, z = PositionArgs(Trace.HitPos)
		local Command = Editor.Mode == "npc" and "UD_Dev_EditMap_MoveSpawnPoint" or "UD_Dev_EditMap_MoveWorldProp"
		SendCommand(Command, Editor.SelectedKey, x, y, z)
		Editor.Moving = false
		UpdateStatus()
		return
	end
	local Key
	if Editor.Mode == "npc" then
		Key = FindSpawnPointAt(Trace.HitPos)
	else
		Key = FindWorldPropAt(Trace)
	end
	if Key then
		Select(Key)
	else
		PlacePending(Trace.HitPos)
	end
end

local function TraceFromCursor(AimVector)
	local Start = EyePos()
	return util.TraceLine({start = Start, endpos = Start + AimVector * 16384, filter = LocalPlayer()})
end

function Editor.Open()
	if IsValid(Editor.Frame) then
		Editor.Frame:Close()
		return
	end

	local Frame = CreateGenericFrame("Map Editor  (hold C for the mouse)", true, true)
	Frame:SetSize(310, 500)
	Frame:SetPos(20, 80)
	Frame:SetMouseInputEnabled(false)
	Frame:SetKeyboardInputEnabled(false)
	Frame.OnClose = function()
		Editor.Frame = nil
		Editor.Pending = nil
		Editor.SelectedKey = nil
		Editor.Edit = nil
		Editor.Moving = false
	end
	Editor.Frame = Frame

	local Header = vgui.Create("DPanel", Frame)
	Header:Dock(TOP)
	Header:SetTall(22)
	Header:DockMargin(0, 0, 0, 4)
	Header:SetPaintBackground(false)

	local SaveButton = vgui.Create("DButton", Header)
	SaveButton:Dock(RIGHT)
	SaveButton:SetWide(80)
	SaveButton:DockMargin(4, 0, 0, 0)
	SaveButton:SetText("Save map")
	SaveButton.DoClick = function()
		RunConsoleCommand("UD_Dev_EditMap_SaveMap")
		Editor.Dirty = false
		UpdateStatus()
	end

	local ModeBox = vgui.Create("DComboBox", Header)
	ModeBox:Dock(FILL)
	ModeBox:AddChoice("NPC spawn points", "npc", Editor.Mode == "npc")
	ModeBox:AddChoice("Props", "prop", Editor.Mode == "prop")
	ModeBox.OnSelect = function(_, _, _, Data)
		Editor.Mode = Data
		Editor.Pending = nil
		Editor.SelectedKey = nil
		Editor.Edit = nil
		Editor.Moving = false
		Rebuild()
	end

	Editor.StatusLabel = AddLabel(Frame, "")
	Editor.Body = vgui.Create("DScrollPanel", Frame)
	Editor.Body:Dock(FILL)

	Rebuild()
end
concommand.Add("UD_Dev_EditMap", function() Editor.Open() end)

hook.Add("UD_MapObjectsChanged", "UD_MapEditorSync", function()
	if not IsValid(Editor.Frame) then return end
	if Editor.SelectedKey and not ObjectList()[Editor.SelectedKey] then
		Deselect()
	else
		UpdateStatus()
	end
end)

hook.Add("GUIMousePressed", "UD_MapEditorClick", function(MouseCode, AimVector)
	if not IsValid(Editor.Frame) then return end
	if MouseCode == MOUSE_LEFT then
		HandleWorldClick(TraceFromCursor(AimVector))
	elseif MouseCode == MOUSE_RIGHT then
		Cancel()
	end
end)

hook.Add("PlayerBindPress", "UD_MapEditorClick", function(ply, Bind, Pressed)
	if not IsValid(Editor.Frame) or not Pressed then return end
	if string.find(Bind, "+attack2", 1, true) then
		Cancel()
		return true
	end
	if string.find(Bind, "+attack", 1, true) then
		HandleWorldClick(LocalPlayer():GetEyeTraceNoCursor())
		return true
	end
end)

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
	local Frame = Editor.Frame
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

local function DrawCircle(Center, Radius, Col)
	local Segments = math.Clamp(math.floor(Radius / 6), 16, 72)
	local Previous = Center + Vector(Radius, 0, 0)
	for i = 1, Segments do
		local Theta = (i / Segments) * math.pi * 2
		local Point = Center + Vector(math.cos(Theta) * Radius, math.sin(Theta) * Radius, 0)
		render.DrawLine(Previous, Point, Col, true)
		Previous = Point
	end
end

local function DrawSquare(Center, Half, Col)
	local A = Center + Vector(-Half, -Half, 0)
	local B = Center + Vector(Half, -Half, 0)
	local C = Center + Vector(Half, Half, 0)
	local D = Center + Vector(-Half, Half, 0)
	render.DrawLine(A, B, Col, true)
	render.DrawLine(B, C, Col, true)
	render.DrawLine(C, D, Col, true)
	render.DrawLine(D, A, Col, true)
end

local function DrawFacing(Center, Yaw, Col)
	local Ang = Angle(0, Yaw or 0, 0)
	local Tip = Center + Ang:Forward() * 28
	render.DrawLine(Center, Tip, Col, true)
	render.DrawLine(Tip, Tip - Ang:Forward() * 8 + Ang:Right() * 6, Col, true)
	render.DrawLine(Tip, Tip - Ang:Forward() * 8 - Ang:Right() * 6, Col, true)
end

local function DrawSpawnMarker(Position, Values, Col)
	local Center = Position + Vector(0, 0, 3)
	DrawCircle(Center, MarkerRadius, Col)
	if (Values.Radius or 0) > MarkerRadius then DrawCircle(Center, Values.Radius, Col) end
	DrawFacing(Center, Values.Yaw, Col)
end

hook.Add("PostDrawTranslucentRenderables", "UD_MapEditorMarkers", function(DrawingDepth, DrawingSkybox)
	if DrawingDepth or DrawingSkybox or not IsValid(Editor.Frame) then return end
	if Editor.Mode == "npc" then
		for Key, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
			if Key == Editor.SelectedKey then
				DrawSpawnMarker(Spawn.Position, Editor.Edit, Editor.Moving and ColorMoving or ColorSelected)
			else
				DrawSpawnMarker(Spawn.Position, {Radius = Spawn.Radius, Yaw = Spawn.Angle and Spawn.Angle.y}, ColorPlaced)
			end
		end
		if Editor.Pending then DrawSpawnMarker(Editor.Pending.Position, Editor.Settings, ColorPending) end
	else
		for Key, Prop in ipairs(GAMEMODE.MapEntities.WorldProps) do
			local PropEntity = Entity(Prop.EntIndex or -1)
			if Key == Editor.SelectedKey and IsValid(PropEntity) then
				render.DrawWireframeBox(PropEntity:GetPos(), PropEntity:GetAngles(), PropEntity:OBBMins(), PropEntity:OBBMaxs(), Editor.Moving and ColorMoving or ColorSelected, true)
			else
				DrawSquare(Prop.Position, 12, Key == Editor.SelectedKey and ColorSelected or ColorPlaced)
			end
		end
		if Editor.Pending then
			local Center = Editor.Pending.Position + Vector(0, 0, 3)
			DrawSquare(Center, 16, ColorPending)
			DrawFacing(Center, Editor.Settings.Yaw, ColorPending)
		end
	end
end)

hook.Add("HUDPaint", "UD_MapEditorLabels", function()
	if not IsValid(Editor.Frame) then return end
	local ViewPosition = EyePos()
	local function DrawLabel(Position, Text, Col)
		if Position:DistToSqr(ViewPosition) > 3000 ^ 2 then return end
		local Screen = (Position + Vector(0, 0, 24)):ToScreen()
		if not Screen.visible then return end
		draw.SimpleTextOutlined(Text, "UiBold", Screen.x, Screen.y, Col, 1, 1, 1, ColorOutline)
	end
	if Editor.Mode == "npc" then
		for Key, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
			local NPC = NPCTable(Spawn.NPC)
			local Text = "#" .. Key .. "  " .. (NPC and NPC.PrintName or Spawn.NPC) .. "  x" .. (Spawn.Count or 1) .. "  Lv " .. (Spawn.Level or 1)
			if (Spawn.SpawnTime or 0) <= 0 then Text = Text .. "  (respawn 0: never spawns)" end
			DrawLabel(Spawn.Position, Text, Key == Editor.SelectedKey and ColorSelected or White)
		end
		if Editor.Pending then DrawLabel(Editor.Pending.Position, "New spawn point", ColorPending) end
	else
		for Key, Prop in ipairs(GAMEMODE.MapEntities.WorldProps) do
			DrawLabel(Prop.Position, "#" .. Key .. "  " .. string.GetFileFromFilename(Prop.Model or ""), Key == Editor.SelectedKey and ColorSelected or White)
		end
		if Editor.Pending then DrawLabel(Editor.Pending.Position, "New prop", ColorPending) end
	end
end)
