local Player = FindMetaTable("Player")
--TODO: make these 2 variables global and integrate with GM.Auctions (?)
local DefaultAuctionTime = 24 --1 Day
local CleanUpTime = 168 --1 Week
GM.Auctions = {}

if SERVER then

	function GM:AddAuction(Seller, Item, Amount, SellPrice)
		if not IsValid(Seller) or not Seller:HasItem(Item, Amount) then return false end
		if not Seller:RemoveItem(Item, Amount) then return false end
		if (ItemTable(Item).SellPrice or 0) <= 0 then return false end
		if Amount <= 0 or SellPrice <= 0 then return false end
		table.insert(GAMEMODE.Auctions, {SellerID = Seller:SteamID(), Item = Item, Amount = Amount, Price = SellPrice, TimeLeft = CleanUpTime})
		Seller:CreateNotification("You created an auction for " .. Amount .. " " .. ItemTable(Item).PrintName .. " at the price of " .. SellPrice .. ".")
		Seller:ConCommand("UD_RequestAuctionInfo " .. #GAMEMODE.Auctions)
		GAMEMODE:SaveAuctions()
		return true
	end

	function GM:CancelAuction(Canceler, Key)
		if not IsValid(Canceler) or not GAMEMODE.Auctions[Key] then return false end
		if GAMEMODE.Auctions[Key].SellerID ~= Canceler:SteamID() then return false end
		if GAMEMODE.Auctions[Key].TimeLeft <= CleanUpTime - DefaultAuctionTime then return false end
		GAMEMODE.Auctions[Key].TimeLeft = CleanUpTime - DefaultAuctionTime
		Canceler:CreateNotification("You canceled the auction.")
		Canceler:ConCommand("UD_RequestAuctionInfo " .. Key)
		GAMEMODE:SaveAuctions()
		return true
	end

	function GM:PickUpAuction(PickerUpper, Key)
		if not IsValid(PickerUpper) or not GAMEMODE.Auctions[Key] then return false end
		local AuctionTable = GAMEMODE.Auctions[Key]
		if AuctionTable.TimeLeft <= CleanUpTime - DefaultAuctionTime then
			if AuctionTable.SellerID == PickerUpper:SteamID() then
				if PickerUpper:HasRoomFor({[AuctionTable.Item] = AuctionTable.Amount}) then
					PickerUpper:AddItem(AuctionTable.Item, AuctionTable.Amount)
					PickerUpper:CreateNotification("You picked up your auction.")
					PickerUpper:ConCommand("UD_RequestAuctionInfo " .. Key)
					GAMEMODE.Auctions[Key] = nil
					GAMEMODE:SaveAuctions()
					return true
				end
			end
		end
	end

	function GM:BuyOutAuction(Buyer, Key)
		if not IsValid(Buyer) or not GAMEMODE.Auctions[Key] then return false end
		if GAMEMODE.Auctions[Key].SellerID == Buyer:SteamID() then return false end
		if GAMEMODE.Auctions[Key].TimeLeft <= CleanUpTime - DefaultAuctionTime then return false end
		local AuctionTable = GAMEMODE.Auctions[Key]
		if Buyer:HasItem("money", AuctionTable.Price) and Buyer:HasRoomFor({[AuctionTable.Item] = AuctionTable.Amount}) then
			Buyer:RemoveItem("money", AuctionTable.Price)
			Buyer:AddItem(AuctionTable.Item, AuctionTable.Amount)
			GAMEMODE.Auctions[Key].Item = "money"
			GAMEMODE.Auctions[Key].Amount = AuctionTable.Price
			GAMEMODE.Auctions[Key].TimeLeft = CleanUpTime - DefaultAuctionTime
			GAMEMODE:SaveAuctions()
			Buyer:CreateNotification("You bought out an auction.")
			Buyer:ConCommand("UD_RequestAuctionInfo " .. Key)
			return true
		end
	end

	function GM:LoadAuctions()
		local FileName = GAMEMODE.DataFolder .. "/Auctions.txt"
		if file.Exists(FileName, "DATA") then
			GAMEMODE.Auctions = util.JSONToTable(file.Read(FileName, "DATA") or "") or {}
		end
	end

	function GM:SaveAuctions()
		local FileName = GAMEMODE.DataFolder .. "/Auctions.txt"
		file.Write(FileName, util.TableToJSON(GAMEMODE.Auctions))
	end

	function GM:TimerUpdateAuctions()
		for Key, Info in pairs(GAMEMODE.Auctions) do
			Info.TimeLeft = Info.TimeLeft - 0.25
		end
	end

	hook.Add("Initialize", "AuctionsInitialize", function()
		GAMEMODE:LoadAuctions()
		timer.Create("UD_AuctionsHourTimer", 900, 0, function() GAMEMODE:TimerUpdateAuctions() end)
	end)
	local function SendAuctions(ply, AuctionList)
		local Data = util.Compress(util.TableToJSON(AuctionList))
		net.Start("UD_UpdateAuctions")
		net.WriteUInt(#Data, 32)
		net.WriteData(Data, #Data)
		net.Send(ply)
	end

	local function AuctionEntry(Key, Info)
		if not Info then return {Key = Key, Removed = true} end
		return {Key = Key, SellerID = Info.SellerID, Item = Info.Item, Amount = Info.Amount, Price = Info.Price, TimeLeft = Info.TimeLeft}
	end

	local RequestCooldown = 0.5
	concommand.Add("UD_RequestAuctionInfo", function(ply, command, args)
		if args[1] then
			local Key = tonumber(args[1])
			if Key then SendAuctions(ply, {AuctionEntry(Key, GAMEMODE.Auctions[Key])}) end
			return
		end

		if (ply.NextRequest or 0) > CurTime() then return end
		ply.NextRequest = CurTime() + RequestCooldown

		local FirstIndex = ply:GetNWInt("AuctionPage") * GAMEMODE.AuctionsPerPage
		local LastIndex = FirstIndex + GAMEMODE.AuctionsPerPage
		local ActiveAfter = CleanUpTime - DefaultAuctionTime
		local AuctionList = {}
		local Counter = 0
		for Key, Info in pairs(GAMEMODE.Auctions) do
			local IsOwn = ply:SteamID() == Info.SellerID
			local OnPage = Counter >= FirstIndex and Counter < LastIndex
			if (OnPage or IsOwn or game.SinglePlayer()) and (Info.TimeLeft > ActiveAfter or IsOwn or game.SinglePlayer()) then
				table.insert(AuctionList, AuctionEntry(Key, Info))
			end
			if Info.TimeLeft > ActiveAfter then
				Counter = Counter + 1
			end
		end
		SendAuctions(ply, AuctionList)
	end)

	concommand.Add("UD_CreateAuction", function(ply, command, args)
		GAMEMODE:AddAuction(
			ply,
			args[1],
			math.max(tonumber(args[2] or 1), 1),
			math.max(tonumber(args[3] or 1), 1),
			tonumber(args[3] or 1)
		)
	end)

	concommand.Add("UD_CancelAuction", function(ply, command, args)
		GAMEMODE:CancelAuction(ply, tonumber(args[1]))
	end)

	concommand.Add("UD_PickUpAuction", function(ply, command, args)
		GAMEMODE:PickUpAuction(ply, tonumber(args[1]))
	end)

	concommand.Add("UD_BuyOutAuction", function(ply, command, args)
		GAMEMODE:BuyOutAuction(ply, tonumber(args[1]))
	end)

	concommand.Add("UD_SetAuctionPage", function(ply, command, args)
		ply:SetNWInt("AuctionPage", math.max(tonumber(args[1]) or 0, 0))
		ply:ConCommand("UD_RequestAuctionInfo")
	end)
end

if CLIENT then
	net.Receive("UD_UpdateAuctions", function()
		local Length = net.ReadUInt(32)
		local AuctionList = util.JSONToTable(util.Decompress(net.ReadData(Length)) or "") or {}
		for _, Entry in ipairs(AuctionList) do
			if Entry.Removed or not Entry.Item or Entry.Item == "" then
				GAMEMODE.Auctions[Entry.Key] = nil
			else
				GAMEMODE.Auctions[Entry.Key] = {SellerID = Entry.SellerID, Item = Entry.Item, Amount = Entry.Amount, Price = Entry.Price, TimeLeft = Entry.TimeLeft}
			end
		end

		if GAMEMODE.AuctionMenu then
			GAMEMODE.AuctionMenu.BuyAuctions:LoadAuctions()
			GAMEMODE.AuctionMenu.PickUpAuction:LoadAuctions()
		end
	end)
end
