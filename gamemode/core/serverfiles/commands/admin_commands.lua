function GM:ChangeMapTimed(NewMap, MapChangeDelay)
	MapChangeDelay = MapChangeDelay or 10
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) then
			ply:CreateNotification("Saving Accounts")
			ply:SaveGameNow()
		end
	end
	GAMEMODE.StopSaving = true
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) then
			ply:CreateNotification("Server changing map to " .. NewMap .. " in " .. MapChangeDelay .. " seconds")
			for i = 1, MapChangeDelay do
				timer.Simple(i, function()
					if IsValid(ply) then ply:CreateNotification(tostring(MapChangeDelay - (i - 1)) .. " ...") end
				end)
			end
		end
	end
	timer.Simple(MapChangeDelay, function() game.ConsoleCommand("changelevel " .. NewMap .. "\n") end)
end
concommand.Add("UD_Admin_ChangeMap", function(ply, command, args)
	if (not IsValid(ply) or ply:IsAdmin()) and args[1] then
		local NewMap = args[1]
		local MapChangeDelay = tonumber(args[2]) or 10
		GAMEMODE:ChangeMapTimed(NewMap, MapChangeDelay)
	end
end)

function GM:AdminBackup()
	for _, ply in ipairs(player.GetAll()) do
		if ply.Loaded then
			ply:SaveGameNow("backups")
			ply:ChatPrint("Admin has saved a backup of player data")
		end
	end
end

concommand.Add("UD_Admin_SaveBackup", function(ply, command, args)
	if not IsValid(ply) or ply:IsAdmin() then
		GAMEMODE:AdminBackup()
	end
end)
