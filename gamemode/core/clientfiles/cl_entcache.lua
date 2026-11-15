UD_EntCache = UD_EntCache or {}
UD_EntCache.NPCs = UD_EntCache.NPCs or {}
UD_EntCache.Items = UD_EntCache.Items or {}
UD_EntCache.Props = UD_EntCache.Props or {}
UD_EntCache.Workbenches = UD_EntCache.Workbenches or {}

local RefreshInterval = 0.25
local WorkbenchModel = "models/props/de_inferno/clayoven.mdl"

local function RefreshEntCache()
	local NPCs, Items, Props, Workbenches = {}, {}, {}, {}

	for _, ent in ipairs(ents.GetAll()) do
		local Class = ent:GetClass()
		if (ent:IsNPC() or Class == "prop_physics") and ent:GetNWInt("level") > 0 then
			NPCs[#NPCs + 1] = ent
		elseif string.sub(Class, 1, 5) == "prop_" then
			if Class == "prop_physics" then Props[#Props + 1] = ent end
			if ent:GetNWInt("Amount") > 0 then Items[#Items + 1] = ent end
			local Model = ent:GetModel()
			if Model and string.lower(Model) == WorkbenchModel then Workbenches[#Workbenches + 1] = ent end
		end
	end

	UD_EntCache.NPCs = NPCs
	UD_EntCache.Items = Items
	UD_EntCache.Props = Props
	UD_EntCache.Workbenches = Workbenches

	if GAMEMODE and GAMEMODE.UpdateQuestWaypoints then
		GAMEMODE:UpdateQuestWaypoints()
	end
end
timer.Create("UD_EntCacheRefresh", RefreshInterval, 0, RefreshEntCache)
