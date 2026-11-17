local function IsDeveloper(ply)
	return IsValid(ply) and (game.SinglePlayer() or ply:IsSuperAdmin())
end

concommand.Add("UD_Dev_GiveItem", function(ply, command, args)
	if not IsDeveloper(ply) then return end
	local strItem = args[1]
	local tblItemTable = strItem and ItemTable(strItem)
	if not tblItemTable then
		ply:ChatPrint("Unknown item: " .. tostring(strItem))
		return
	end
	local intAmount = math.Clamp(math.floor(tonumber(args[2]) or 1), 1, 1000)
	ply:AddItem(strItem, intAmount)
	ply:ChatPrint("Gave " .. intAmount .. "x " .. (tblItemTable.PrintName or strItem))
end)

concommand.Add("UD_Dev_SetTrade", function(ply, command, args)
	if not IsDeveloper(ply) then return end
	local strTrade = string.lower(tostring(args[1] or ""))
	local tblMasters = {}
	if strTrade == "all" then
		for strMaster in pairs(GAMEMODE.DataBase.Masters) do table.insert(tblMasters, strMaster) end
	elseif MasterTable("master_" .. strTrade) then
		tblMasters = {"master_" .. strTrade}
	end
	if #tblMasters == 0 then
		ply:ChatPrint("Unknown trade: " .. strTrade .. " (use blacksmithing, leatherworking, tailoring, mining or all)")
		return
	end
	local intTier = math.Clamp(math.floor(tonumber(args[2]) or 1), 1, GAMEMODE.Combat.MaxTradeTier)
	for _, strMaster in ipairs(tblMasters) do
		ply:SetMaster(strMaster, toMasterExp(intTier))
	end
	ply:ChatPrint("Set " .. strTrade .. " to tier " .. intTier)
end)
