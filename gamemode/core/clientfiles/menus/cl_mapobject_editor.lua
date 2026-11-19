GM.MapEditor = {}
local Editor = GM.MapEditor

Editor.Models = {
	"station:forge",
	"station:tailoring",
	"station:leatherwork",
	"models/props/furnitures/humans/chests/poor_chest_01.mdl",
	"models/props/furnitures/humans/chests/big_chest_metal01_dirty.mdl",
	"models/props/furnitures/humans/chests/big_chest_metal_cov01.mdl",
	"models/props/furnitures/humans/barrel_large/barrel_large.mdl",
	"models/props/furnitures/humans/basket_cloth.mdl",
	"models/props/furnitures/gob/l6_basket_01/l6_basket_01.mdl",
	"models/props/furnitures/humans/table01.mdl",
	"models/props/furnitures/humans/l02_tablebench.mdl",
	"models/props/furnitures/humans/bench01_big.mdl",
	"models/props/furnitures/humans/poor_bench_01.mdl",
	"models/props/furnitures/humans/stool02.mdl",
	"models/props/furnitures/humans/shelf_01.mdl",
	"models/props/furnitures/mn/mn_chairrich.mdl",
	"models/props/furnitures/l10/l10_bed_01.mdl",
	"models/props/furnitures/gob/l6_mattress/l6_mattress.mdl",
	"models/props/tools/humans/campbed01.mdl",
	"models/props/tools/humans/firecamp01/brazier.mdl",
	"models/props/tools/humans/training_dummy/training_dummy.mdl",
	"models/skyrimznalecc/smallimperialtent.mdl",
	"models/skyrimznalecc/implargetent.mdl",
	"models/skyrimznalecc/nordlargetent.mdl",
	"models/skyrimznalecc/bedroll01.mdl",
	"models/props/kingdom/spike_wall.mdl",
	"models/props/kingdom/wheel.mdl",
	"models/dimidrol/transport/cart_cod_01.mdl",
	"models/props/furnitures/humans/abreuvoirs/abreuvoir01.mdl",
	"models/props_forest/fence_trail_128.mdl",
	"models/props_forest/fence_trail_256.mdl",
	"models/props_shacks/fishing_net01.mdl",
	"models/items/magic/scrolls/scroll_rolled.mdl",
	"models/props/debris/skeleton/cr_skel_pose01.mdl",
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
local ColorPlayerSpawn = Color(120, 170, 255, 220)
local ColorOutline = Color(0, 0, 0, 255)
local ColorRoute = Color(255, 140, 60, 230)
local ColorRoamer = Color(190, 120, 255, 230)
local ModeNouns = {npc = "spawn point", prop = "prop", player = "player spawn", ore = "ore vein", route = "patrol route"}
local WhenNames = {[0] = "Always", [1] = "Only at night", [2] = "Only by day"}

Editor.Mode = "npc"
Editor.Pending = nil
Editor.SelectedKey = nil
Editor.Edit = nil
Editor.Moving = false
Editor.Dirty = false
Editor.Settings = {NPC = nil, Level = 5, SpawnTime = 30, Radius = 0, Count = 1, Yaw = 0, Model = Editor.Models[1], Ore = "bogiron", OreRespawn = 180, OreModel = nil, Route = 0, When = 0, RouteName = "", Roamer = false, RouteLevel = 30}

local Rebuild

local function ObjectList()
	if Editor.Mode == "npc" then return GAMEMODE.MapEntities.NPCSpawnPoints end
	if Editor.Mode == "player" then return GAMEMODE.MapEntities.PlayerSpawns end
	if Editor.Mode == "ore" then return GAMEMODE.MapEntities.OreVeins end
	if Editor.Mode == "route" then return GAMEMODE.MapEntities.PatrolRoutes end
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
	local Noun = ModeNouns[Editor.Mode]
	local Status
	if Editor.Moving then
		Status = "Click the spot to move the selected " .. Noun .. " to. Right-click cancels."
	elseif Editor.SelectedKey and Editor.Mode == "route" then
		Status = "Editing patrol route #" .. Editor.SelectedKey .. ". Left-click the ground to add the next point. Right-click to deselect."
	elseif Editor.SelectedKey then
		Status = "Editing " .. Noun .. " #" .. Editor.SelectedKey .. ". Right-click to deselect."
	elseif Editor.Pending then
		Status = "New " .. Noun .. ": choose its settings, then press Add. Right-click cancels."
	else
		Status = "Left-click the ground to place a " .. Noun .. ", or click a marker to edit it."
	end
	local Counts = #GAMEMODE.MapEntities.NPCSpawnPoints .. " NPC spawns, " .. #GAMEMODE.MapEntities.WorldProps .. " props, " .. #GAMEMODE.MapEntities.PlayerSpawns .. " player spawns, " .. #GAMEMODE.MapEntities.OreVeins .. " ore veins, " .. #GAMEMODE.MapEntities.PatrolRoutes .. " routes"
	if Editor.Dirty then Counts = Counts .. "  -  unsaved changes" end
	local Mouse = Editor.CursorEnabled and "Mouse: ON (press C to look around)" or "Mouse: OFF (press C to use this window)"
	return Status .. "\n" .. Counts .. "\n" .. Mouse
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
		Editor.Edit = {NPC = Object.NPC, Level = Object.Level or 5, SpawnTime = Object.SpawnTime or 30, Radius = Object.Radius or 0, Count = Object.Count or 1, Yaw = Yaw, Route = Object.Route or 0, When = Object.When or 0}
	elseif Editor.Mode == "route" then
		Editor.Edit = {RouteName = Object.Name or "", Roamer = Object.Roamer or false, RouteLevel = Object.Level or 30}
	elseif Editor.Mode == "player" then
		Editor.Edit = {Yaw = Yaw}
	elseif Editor.Mode == "ore" then
		Editor.Edit = {Ore = Object.Ore, OreRespawn = Object.SpawnTime or 180, OreModel = Object.Model, Yaw = Yaw}
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

	AddSlider(Body, "Level", 1, 150, Values.Level, function(Value) Values.Level = Value end)
	AddSlider(Body, "Respawn (seconds)", 1, 900, Values.SpawnTime, function(Value) Values.SpawnTime = Value end)
	AddSlider(Body, "How many NPCs", 1, 20, Values.Count, function(Value) Values.Count = Value end)
	AddSlider(Body, "Spawn area radius", 0, 1000, Values.Radius, function(Value) Values.Radius = Value end)
	AddSlider(Body, "Facing", -180, 180, Values.Yaw, function(Value) Values.Yaw = Value end)
	AddSlider(Body, "Patrol route # (0 = stay put)", 0, math.max(#GAMEMODE.MapEntities.PatrolRoutes, 1), Values.Route or 0, function(Value) Values.Route = Value end)
	local WhenBox = vgui.Create("DComboBox", Body)
	WhenBox:Dock(TOP)
	WhenBox:DockMargin(0, 0, 0, 4)
	for intWhen = 0, 2 do WhenBox:AddChoice("Spawns: " .. WhenNames[intWhen], intWhen, (Values.When or 0) == intWhen) end
	WhenBox.OnSelect = function(_, _, _, Data) Values.When = Data end

	if Editor.SelectedKey then
		local Key = Editor.SelectedKey
		AddButton(Body, "Apply changes", function()
			SendCommand("UD_Dev_EditMap_UpdateSpawnPoint", Key, Values.NPC, Values.Level, Values.SpawnTime, Values.Yaw, Values.Radius, Values.Count, Values.Route or 0, Values.When or 0)
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
			SendCommand("UD_Dev_EditMap_AddSpawnPoint", x, y, z, Values.Yaw, Values.NPC, Values.Level, Values.SpawnTime, Values.Radius, Values.Count, Values.Route or 0, Values.When or 0)
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
	local function ValidChoice(strModel)
		return util.IsValidModel(GAMEMODE:ResolvePropModel(strModel or ""))
	end
	if not ValidChoice(Values.Model) then
		for _, Model in ipairs(Editor.Models) do
			if ValidChoice(Model) then
				Values.Model = Model
				break
			end
		end
	end
	for _, Model in ipairs(Editor.Models) do
		if not ValidChoice(Model) then continue end
		local tblBuild = GAMEMODE:GetStationBuild(Model)
		local Icon = Grid:Add("SpawnIcon")
		Icon:SetSize(52, 52)
		Icon:SetModel(GAMEMODE:ResolvePropModel(Model))
		Icon:SetTooltip(tblBuild and (tblBuild.PrintName .. " (crafting station: " .. (GAMEMODE.CraftingStationNames[tblBuild.Station] or tblBuild.Station) .. ")") or Model)
		Icon.DoClick = function() Values.Model = Model end
		Icon.PaintOver = function(_, w, h)
			if tblBuild then draw.SimpleTextOutlined(tblBuild.PrintName, "DefaultSmall", w / 2, h - 2, ColorSelected, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, ColorOutline) end
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

local function BuildPlayerSpawnControls(Body, Values)
	AddLabel(Body, "Players appear at a random free player spawn. With none placed, the map's own spawn is used.")
	AddSlider(Body, "Facing", -180, 180, Values.Yaw, function(Value) Values.Yaw = Value end)

	if Editor.SelectedKey then
		local Key = Editor.SelectedKey
		AddButton(Body, "Apply changes", function()
			SendCommand("UD_Dev_EditMap_UpdatePlayerSpawn", Key, Values.Yaw)
			UpdateStatus()
		end)
		AddButton(Body, "Move to a new spot", function()
			Editor.Moving = true
			UpdateStatus()
		end)
		AddButton(Body, "Remove", function()
			SendCommand("UD_Dev_EditMap_RemovePlayerSpawn", Key)
			Deselect()
		end)
		AddButton(Body, "Deselect", Deselect)
	else
		AddButton(Body, "Add player spawn", function()
			if not Editor.Pending then return end
			local x, y, z = PositionArgs(Editor.Pending.Position)
			SendCommand("UD_Dev_EditMap_AddPlayerSpawn", x, y, z, Values.Yaw)
			Editor.Pending = nil
			Rebuild()
		end)
		AddButton(Body, "Cancel", Cancel)
	end
end

local function OreColor(strOre)
	local Ore = GAMEMODE:GetOreType(strOre)
	if not Ore then return ColorPlaced end
	return Color(math.max(Ore.Tint.r, 90), math.max(Ore.Tint.g, 90), math.max(Ore.Tint.b, 90), 230)
end

local function BuildOreControls(Body, Values)
	AddLabel(Body, "Players press E on a vein to mine it. A mined vein disappears and grows back after the respawn time.")
	local OreBox = vgui.Create("DComboBox", Body)
	OreBox:Dock(TOP)
	OreBox:DockMargin(0, 0, 0, 4)
	for _, Ore in ipairs(GAMEMODE.OreTypes or {}) do
		OreBox:AddChoice(Ore.PrintName .. "  (Mining tier " .. Ore.MiningTier .. ", level " .. Ore.Level .. "+)", Ore.Key, Ore.Key == Values.Ore)
	end
	OreBox.OnSelect = function(_, _, _, Data) Values.Ore = Data end

	if not GAMEMODE:IsOreVeinModel(Values.OreModel) then Values.OreModel = GAMEMODE:DefaultOreVeinModel() end
	local Grid = vgui.Create("DIconLayout", Body)
	Grid:Dock(TOP)
	Grid:DockMargin(0, 0, 0, 4)
	Grid:SetSpaceX(2)
	Grid:SetSpaceY(2)
	for _, Model in ipairs(GAMEMODE.OreVeinModels) do
		if not util.IsValidModel(Model) then continue end
		local Icon = Grid:Add("SpawnIcon")
		Icon:SetSize(52, 52)
		Icon:SetModel(Model)
		Icon:SetTooltip(Model)
		Icon.DoClick = function() Values.OreModel = Model end
		Icon.PaintOver = function(_, w, h)
			if string.lower(Values.OreModel or "") ~= string.lower(Model) then return end
			surface.SetDrawColor(ColorSelected)
			surface.DrawOutlinedRect(0, 0, w, h, 2)
		end
	end

	AddSlider(Body, "Respawn (seconds)", 10, 3600, Values.OreRespawn, function(Value) Values.OreRespawn = Value end)
	AddSlider(Body, "Facing", -180, 180, Values.Yaw, function(Value) Values.Yaw = Value end)

	if Editor.SelectedKey then
		local Key = Editor.SelectedKey
		AddButton(Body, "Apply changes", function()
			SendCommand("UD_Dev_EditMap_UpdateOreVein", Key, Values.Ore, Values.OreRespawn, Values.Yaw, Values.OreModel)
			UpdateStatus()
		end)
		AddButton(Body, "Move to a new spot", function()
			Editor.Moving = true
			UpdateStatus()
		end)
		AddButton(Body, "Remove", function()
			SendCommand("UD_Dev_EditMap_RemoveOreVein", Key)
			Deselect()
		end)
		AddButton(Body, "Deselect", Deselect)
	else
		AddButton(Body, "Add ore vein", function()
			if not Editor.Pending or not Values.Ore then return end
			local x, y, z = PositionArgs(Editor.Pending.Position)
			SendCommand("UD_Dev_EditMap_AddOreVein", x, y, z, Values.Yaw, Values.Ore, Values.OreRespawn, Values.OreModel)
			Editor.Pending = nil
			Rebuild()
		end)
		AddButton(Body, "Cancel", Cancel)
	end
end

local function BuildRouteControls(Body, Values)
	if not Editor.SelectedKey then
		AddLabel(Body, "A patrol route is a line of points NPCs walk in a loop. Start one here, then keep clicking the ground to add points. Give an NPC spawn point the route's number to make its NPCs patrol it.")
		AddButton(Body, "Start a new route here", function()
			if not Editor.Pending then return end
			local x, y, z = PositionArgs(Editor.Pending.Position)
			SendCommand("UD_Dev_EditMap_AddRoute", x, y, z)
			Editor.Pending = nil
			Editor.AwaitRoute = #GAMEMODE.MapEntities.PatrolRoutes + 1
			Rebuild()
		end)
		AddButton(Body, "Cancel", Cancel)
		return
	end
	local Key = Editor.SelectedKey
	local Route = GAMEMODE.MapEntities.PatrolRoutes[Key]
	AddLabel(Body, "Route #" .. Key .. ", " .. (Route and #Route.Points or 0) .. " points. Click the ground to add the next point.")
	local NameEntry = vgui.Create("DTextEntry", Body)
	NameEntry:Dock(TOP)
	NameEntry:DockMargin(0, 0, 0, 4)
	NameEntry:SetPlaceholderText("Place name, used when a night monster is announced")
	NameEntry:SetValue(Values.RouteName or "")
	NameEntry.OnChange = function(self) Values.RouteName = self:GetValue() end
	local RoamerBox = vgui.Create("DCheckBoxLabel", Body)
	RoamerBox:Dock(TOP)
	RoamerBox:DockMargin(0, 0, 0, 4)
	RoamerBox:SetDark(true)
	RoamerBox:SetText("A night monster may roam this route")
	RoamerBox:SetValue(Values.Roamer and 1 or 0)
	RoamerBox.OnChange = function(_, Checked) Values.Roamer = Checked end
	AddSlider(Body, "Night monster level", 1, 150, Values.RouteLevel, function(Value) Values.RouteLevel = Value end)
	AddButton(Body, "Apply changes", function()
		SendCommand("UD_Dev_EditMap_UpdateRoute", Key, Values.RouteName or "", Values.Roamer and "1" or "0", Values.RouteLevel or 30)
		UpdateStatus()
	end)
	AddButton(Body, "Remove last point", function() SendCommand("UD_Dev_EditMap_RemoveRoutePoint", Key) end)
	AddButton(Body, "Remove route", function()
		SendCommand("UD_Dev_EditMap_RemoveRoute", Key)
		Deselect()
	end)
	AddButton(Body, "Deselect", Deselect)
end

Rebuild = function()
	if not IsValid(Editor.Frame) then return end
	UpdateStatus()
	local Body = Editor.Body
	Body:Clear()
	if not Editor.Pending and not Editor.SelectedKey then
		AddLabel(Body, "Left-click: place a new marker, or select an existing one.\nRight-click: cancel or deselect.\nC: switch between using the mouse here and looking around.\nWASD still moves you while the mouse is on.\nRun UD_Dev_EditMap again to close the editor.\nPress Save map when you are done.")
		return
	end
	if Editor.Mode == "npc" then
		BuildSpawnControls(Body, CurrentValues())
	elseif Editor.Mode == "player" then
		BuildPlayerSpawnControls(Body, CurrentValues())
	elseif Editor.Mode == "ore" then
		BuildOreControls(Body, CurrentValues())
	elseif Editor.Mode == "route" then
		BuildRouteControls(Body, CurrentValues())
	else
		BuildPropControls(Body, CurrentValues())
	end
end

local function FlatDistance(A, B)
	return math.sqrt((A.x - B.x) ^ 2 + (A.y - B.y) ^ 2)
end

local function FindSpawnPointAt(Position, tblList)
	local BestKey, BestDistance = nil, SelectReach
	for Key, Spawn in ipairs(tblList) do
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

local function FindRouteAt(Position)
	local BestKey, BestDistance = nil, SelectReach
	for Key, Route in ipairs(GAMEMODE.MapEntities.PatrolRoutes) do
		for _, Point in ipairs(Route.Points or {}) do
			local Distance = FlatDistance(Position, Point)
			if Distance < BestDistance and math.abs(Position.z - Point.z) < 96 then
				BestKey, BestDistance = Key, Distance
			end
		end
	end
	return BestKey
end

local function HandleWorldClick(Trace)
	if not Trace or not Trace.Hit then return end
	if Editor.Mode == "route" then
		local Key = FindRouteAt(Trace.HitPos)
		if Key and Key ~= Editor.SelectedKey then
			Select(Key)
		elseif Editor.SelectedKey then
			local x, y, z = PositionArgs(Trace.HitPos)
			SendCommand("UD_Dev_EditMap_AddRoutePoint", Editor.SelectedKey, x, y, z)
		else
			PlacePending(Trace.HitPos)
		end
		return
	end
	if Editor.Moving and Editor.SelectedKey then
		local x, y, z = PositionArgs(Trace.HitPos)
		local MoveCommands = {npc = "UD_Dev_EditMap_MoveSpawnPoint", prop = "UD_Dev_EditMap_MoveWorldProp", player = "UD_Dev_EditMap_MovePlayerSpawn", ore = "UD_Dev_EditMap_MoveOreVein"}
		SendCommand(MoveCommands[Editor.Mode], Editor.SelectedKey, x, y, z)
		Editor.Moving = false
		UpdateStatus()
		return
	end
	local Key
	if Editor.Mode == "npc" then
		Key = FindSpawnPointAt(Trace.HitPos, GAMEMODE.MapEntities.NPCSpawnPoints)
	elseif Editor.Mode == "player" then
		Key = FindSpawnPointAt(Trace.HitPos, GAMEMODE.MapEntities.PlayerSpawns)
	elseif Editor.Mode == "ore" then
		Key = FindSpawnPointAt(Trace.HitPos, GAMEMODE.MapEntities.OreVeins)
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

	local Frame = CreateGenericFrame("Map Editor  (C toggles the mouse)", true, true)
	Frame:SetSize(310, 500)
	Frame:SetPos(20, 80)
	Frame.OnClose = function()
		Editor.Frame = nil
		Editor.Pending = nil
		Editor.SelectedKey = nil
		Editor.Edit = nil
		Editor.Moving = false
		Editor.CursorEnabled = false
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
	ModeBox:AddChoice("Player spawns", "player", Editor.Mode == "player")
	ModeBox:AddChoice("Ore veins", "ore", Editor.Mode == "ore")
	ModeBox:AddChoice("Patrol routes", "route", Editor.Mode == "route")
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

	Editor.SetCursor(true)
	Rebuild()
end
concommand.Add("UD_Dev_EditMap", function() Editor.Open() end)

function Editor.SetCursor(Enabled)
	local Frame = Editor.Frame
	if not IsValid(Frame) then return end
	Editor.CursorEnabled = Enabled
	if Enabled then
		Frame:MakePopup()
		Frame:SetKeyboardInputEnabled(false)
		Frame:SetMouseInputEnabled(true)
	else
		Frame:SetMouseInputEnabled(false)
		Frame:SetKeyboardInputEnabled(false)
	end
	UpdateStatus()
end
concommand.Add("UD_Dev_EditMap_Mouse", function() Editor.SetCursor(not Editor.CursorEnabled) end)

hook.Add("OnTextEntryGetFocus", "UD_MapEditorTyping", function(Panel)
	if IsValid(Editor.Frame) and Panel:HasParent(Editor.Frame) then Editor.Frame:SetKeyboardInputEnabled(true) end
end)

hook.Add("OnTextEntryLoseFocus", "UD_MapEditorTyping", function(Panel)
	if IsValid(Editor.Frame) and Panel:HasParent(Editor.Frame) then Editor.Frame:SetKeyboardInputEnabled(false) end
end)

hook.Add("UD_MapObjectsChanged", "UD_MapEditorSync", function()
	if not IsValid(Editor.Frame) then return end
	if Editor.AwaitRoute and Editor.Mode == "route" and GAMEMODE.MapEntities.PatrolRoutes[Editor.AwaitRoute] then
		local intKey = Editor.AwaitRoute
		Editor.AwaitRoute = nil
		Select(intKey)
		return
	end
	if Editor.Mode == "route" and Editor.SelectedKey and ObjectList()[Editor.SelectedKey] then
		Rebuild()
		return
	end
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
	if string.find(Bind, "+menu_context", 1, true) then
		Editor.SetCursor(not Editor.CursorEnabled)
		return true
	end
	if string.find(Bind, "+attack2", 1, true) then
		Cancel()
		return true
	end
	if string.find(Bind, "+attack", 1, true) then
		HandleWorldClick(LocalPlayer():GetEyeTraceNoCursor())
		return true
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

local function DrawRoute(Route, Col, boolNumbers)
	local Points = Route.Points or {}
	for intIndex, Point in ipairs(Points) do
		DrawCircle(Point + Vector(0, 0, 3), 10, Col)
		local Next = Points[intIndex + 1] or (#Points > 2 and Points[1])
		if Next then render.DrawLine(Point + Vector(0, 0, 6), Next + Vector(0, 0, 6), Col, true) end
	end
end

local function DrawSpawnMarker(Position, Values, Col)
	local Center = Position + Vector(0, 0, 3)
	DrawCircle(Center, MarkerRadius, Col)
	if (Values.Radius or 0) > MarkerRadius then DrawCircle(Center, Values.Radius, Col) end
	DrawFacing(Center, Values.Yaw, Col)
end

hook.Add("PostDrawTranslucentRenderables", "UD_MapEditorMarkers", function(DrawingDepth, DrawingSkybox)
	if DrawingDepth or DrawingSkybox or not IsValid(Editor.Frame) then return end
	if Editor.Mode == "route" or Editor.Mode == "npc" then
		for Key, Route in ipairs(GAMEMODE.MapEntities.PatrolRoutes) do
			local Col = (Editor.Mode == "route" and Key == Editor.SelectedKey) and ColorSelected or (Route.Roamer and ColorRoamer or ColorRoute)
			DrawRoute(Route, Col)
		end
		if Editor.Mode == "route" and Editor.Pending then DrawCircle(Editor.Pending.Position + Vector(0, 0, 3), 10, ColorPending) end
	end
	if Editor.Mode == "route" then
	elseif Editor.Mode == "npc" then
		for Key, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
			if Key == Editor.SelectedKey then
				DrawSpawnMarker(Spawn.Position, Editor.Edit, Editor.Moving and ColorMoving or ColorSelected)
			else
				DrawSpawnMarker(Spawn.Position, {Radius = Spawn.Radius, Yaw = Spawn.Angle and Spawn.Angle.y}, ColorPlaced)
			end
		end
		if Editor.Pending then DrawSpawnMarker(Editor.Pending.Position, Editor.Settings, ColorPending) end
	elseif Editor.Mode == "player" then
		for Key, Spawn in ipairs(GAMEMODE.MapEntities.PlayerSpawns) do
			if Key == Editor.SelectedKey then
				DrawSpawnMarker(Spawn.Position, Editor.Edit, Editor.Moving and ColorMoving or ColorSelected)
			else
				DrawSpawnMarker(Spawn.Position, {Yaw = Spawn.Angle and Spawn.Angle.y}, ColorPlayerSpawn)
			end
		end
		if Editor.Pending then DrawSpawnMarker(Editor.Pending.Position, {Yaw = Editor.Settings.Yaw}, ColorPending) end
	elseif Editor.Mode == "ore" then
		for Key, Vein in ipairs(GAMEMODE.MapEntities.OreVeins) do
			if Key == Editor.SelectedKey then
				DrawSpawnMarker(Vein.Position, {Radius = 30, Yaw = Editor.Edit and Editor.Edit.Yaw}, Editor.Moving and ColorMoving or ColorSelected)
			else
				DrawSpawnMarker(Vein.Position, {Radius = 30, Yaw = Vein.Angle and Vein.Angle.y}, OreColor(Vein.Ore))
			end
		end
		if Editor.Pending then DrawSpawnMarker(Editor.Pending.Position, {Radius = 30, Yaw = Editor.Settings.Yaw}, ColorPending) end
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
	if Editor.Mode == "route" then
		for Key, Route in ipairs(GAMEMODE.MapEntities.PatrolRoutes) do
			local First = Route.Points and Route.Points[1]
			if First then
				local Text = "Route #" .. Key .. ((Route.Name or "") ~= "" and ("  " .. Route.Name) or "") .. "  (" .. #Route.Points .. " points)"
				if Route.Roamer then Text = Text .. "  night monster Lv " .. (Route.Level or 30) end
				DrawLabel(First, Text, Key == Editor.SelectedKey and ColorSelected or (Route.Roamer and ColorRoamer or ColorRoute))
			end
		end
		if Editor.Pending then DrawLabel(Editor.Pending.Position, "New route", ColorPending) end
	elseif Editor.Mode == "npc" then
		for Key, Spawn in ipairs(GAMEMODE.MapEntities.NPCSpawnPoints) do
			local NPC = NPCTable(Spawn.NPC)
			local Text = "#" .. Key .. "  " .. (NPC and NPC.PrintName or Spawn.NPC) .. "  x" .. (Spawn.Count or 1) .. "  Lv " .. (Spawn.Level or 1)
			if (Spawn.Route or 0) > 0 then Text = Text .. "  route " .. Spawn.Route end
			if (Spawn.When or 0) > 0 then Text = Text .. "  (" .. WhenNames[Spawn.When] .. ")" end
			if (Spawn.SpawnTime or 0) <= 0 then Text = Text .. "  (respawn 0: never spawns)" end
			DrawLabel(Spawn.Position, Text, Key == Editor.SelectedKey and ColorSelected or White)
		end
		if Editor.Pending then DrawLabel(Editor.Pending.Position, "New spawn point", ColorPending) end
	elseif Editor.Mode == "player" then
		for Key, Spawn in ipairs(GAMEMODE.MapEntities.PlayerSpawns) do
			DrawLabel(Spawn.Position, "Player spawn #" .. Key, Key == Editor.SelectedKey and ColorSelected or ColorPlayerSpawn)
		end
		if Editor.Pending then DrawLabel(Editor.Pending.Position, "New player spawn", ColorPending) end
	elseif Editor.Mode == "ore" then
		for Key, Vein in ipairs(GAMEMODE.MapEntities.OreVeins) do
			local Ore = GAMEMODE:GetOreType(Vein.Ore)
			local Text = "#" .. Key .. "  " .. (Ore and Ore.PrintName or Vein.Ore) .. " vein  respawn " .. (Vein.SpawnTime or 180) .. "s"
			DrawLabel(Vein.Position, Text, Key == Editor.SelectedKey and ColorSelected or OreColor(Vein.Ore))
		end
		if Editor.Pending then DrawLabel(Editor.Pending.Position, "New ore vein", ColorPending) end
	else
		for Key, Prop in ipairs(GAMEMODE.MapEntities.WorldProps) do
			DrawLabel(Prop.Position, "#" .. Key .. "  " .. string.GetFileFromFilename(Prop.Model or ""), Key == Editor.SelectedKey and ColorSelected or White)
		end
		if Editor.Pending then DrawLabel(Editor.Pending.Position, "New prop", ColorPending) end
	end
end)
