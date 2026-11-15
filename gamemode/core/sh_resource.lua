local Root = GM.FolderName .. "/gamemode/core/"

local SharedFolders = {
	"sharedfiles/",
	"sharedfiles/database/",
	"sharedfiles/database/items/",
	"sharedfiles/database/npcs/",
	"sharedfiles/database/npc_dialog/",
	"sharedfiles/database/quests/",
	"sharedfiles/database/shops/",
	"sharedfiles/database/skills/",
	"sharedfiles/database/stats/",
	"sharedfiles/database/recipes/",
	"sharedfiles/database/masters/",
	"sharedfiles/database/events/",
}

local ClientFolders = {
	"clientfiles/",
	"clientfiles/menus/",
	"clientfiles/vgui/",
	"clientfiles/menutabs/",
	"clientfiles/menutabs/helpmenu/",
	"clientfiles/menutabs/auctionmenu/",
}

local ServerFolders = {
	"serverfiles/",
	"serverfiles/commands/",
}

local function ForEachLuaFile(Folders, Callback)
	for _, Folder in ipairs(Folders) do
		local Path = Root .. Folder
		for _, FileName in ipairs(file.Find(Path .. "*.lua", "LUA")) do
			Callback(Path .. FileName)
		end
	end
end

if SERVER then
	ForEachLuaFile(SharedFolders, function(Path) AddCSLuaFile(Path) include(Path) end)
	ForEachLuaFile(ClientFolders, AddCSLuaFile)
	ForEachLuaFile(ServerFolders, include)

	function resource.AddDir(dir, ext)
		for _, f in ipairs(file.Find(dir .. "/*" .. (ext or ""), "GAME")) do
			resource.AddFile(dir .. "/" .. f)
		end
	end

	resource.AddDir("materials/gui",   ".vmt")
	resource.AddDir("materials/gui",   ".vtf")
	resource.AddDir("materials/icons", ".vmt")
	resource.AddDir("materials/icons", ".vtf")
else
	ForEachLuaFile(SharedFolders, include)
	ForEachLuaFile(ClientFolders, include)
end
