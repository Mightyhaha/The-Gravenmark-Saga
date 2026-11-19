local Player = FindMetaTable("Player")

concommand.Add("udk_edit_items_giveitem", function(ply, command, args)
	local tblItemTable = ItemTable(args[1])
	if tblItemTable.Use then
		tblItemTable:Use(ply, tblItemTable)
	end
end)

concommand.Add("udk_edit_items_clearpaperdoll", function(ply, command, args)
	for strSlot, strItem in pairs(ply.Data.Paperdoll or {}) do
		local tblItemTable = ItemTable(strItem)
		if tblItemTable.Use then tblItemTable:Use(ply, tblItemTable, strSlot) end
	end
end)

function Player:HasSet(strSet)
	if not IsValid(self) then return false end
	local tblSetTable = EquipmentSetTable(strSet)
	if not tblSetTable then return false end
	for _, strItem in pairs(tblSetTable.Items or {}) do
		if not self:IsWearingPiece(strItem) then return false end
	end
	return true
end

function Player:SetPaperDoll(strSlot, strItem)
	if not self or not self:IsValid() and not self:Alive() then return false end
	local tblItemTable = ItemTable(strItem) or {}
	self.Data = self.Data or {}
	self.Data.Paperdoll = self.Data.Paperdoll or {}
	if not strItem or self:GetSlot(strSlot) == strItem then
		if tblItemTable.Set and self:HasSet(tblItemTable.Set) then
			local tblSetTable = EquipmentSetTable(tblItemTable.Set)
			self:ApplyBuffTable(tblSetTable.Buffs, -1)
		end
		self.Data.Paperdoll[strSlot] = nil
		self:ApplyBuffTable(tblItemTable.Buffs, -1)
	else
		if self:GetSlot(strSlot) then
			if ItemTable(self:GetSlot(strSlot)).Set and self:HasSet(ItemTable(self:GetSlot(strSlot)).Set) then
				local tblSetTable = EquipmentSetTable(ItemTable(self:GetSlot(strSlot)).Set)
				self:ApplyBuffTable(tblSetTable.Buffs, -1)
			end
			self:ApplyBuffTable(ItemTable(self:GetSlot(strSlot)).Buffs, -1)
		end
		self.Data.Paperdoll[strSlot] = strItem
		if tblItemTable.Set and self:HasSet(tblItemTable.Set) then
			local tblSetTable = EquipmentSetTable(tblItemTable.Set)
			self:ApplyBuffTable(tblSetTable.Buffs)
		end
		self:ApplyBuffTable(tblItemTable.Buffs)
	end
	if SERVER then
		for strChkSlot, strChkItem in pairs(self.Data.Paperdoll or {}) do
			local tblSlotTable = GAMEMODE.DataBase.Slots[strChkSlot]
			if strChkSlot ~= strSlot and tblSlotTable.ShouldClear and tblSlotTable:ShouldClear(self, tblItemTable) then
				self:UseItem(strChkItem, strChkSlot)
			end
		end
		SendNetworkMessage("UD_UpdatePaperDoll", player.GetAll(), {self, strSlot, self:GetSlot(strSlot)})
		self:SaveGame()
	end
end

function Player:GetSlot(strSlot)
	if self.Data and self.Data.Paperdoll and self.Data.Paperdoll[strSlot] then return self.Data.Paperdoll[strSlot] end
	return
end

function GetItemSlots(tblItemTable)
	if not tblItemTable then return {} end
	if tblItemTable.SlotGroup then
		local tblSlots = {}
		for strName, tblSlot in pairs(GAMEMODE.DataBase.Slots) do
			if tblSlot.Group == tblItemTable.SlotGroup then table.insert(tblSlots, strName) end
		end
		table.sort(tblSlots)
		return tblSlots
	end
	return {tblItemTable.Slot}
end

function SlotAcceptsItem(strSlot, tblItemTable)
	return table.HasValue(GetItemSlots(tblItemTable), strSlot)
end

function Player:GetWornSlots(strItem)
	local tblWorn = {}
	for _, strSlot in ipairs(GetItemSlots(ItemTable(strItem))) do
		if self:GetSlot(strSlot) == strItem then table.insert(tblWorn, strSlot) end
	end
	return tblWorn
end

function Player:IsWearing(strItem)
	return #self:GetWornSlots(strItem) > 0
end

function Player:PickEquipSlot(tblItemTable, strSlot)
	local tblSlots = GetItemSlots(tblItemTable)
	if #tblSlots == 0 then return nil end
	local tblWorn = self:GetWornSlots(tblItemTable.Name)

	if strSlot then
		if not table.HasValue(tblSlots, strSlot) then return nil end
		if self:GetSlot(strSlot) == tblItemTable.Name then return strSlot end
		if not self:HasItem(tblItemTable.Name, #tblWorn + 1) then return nil end
		return strSlot
	end

	if #tblSlots == 1 then return tblSlots[1] end

	if self:HasItem(tblItemTable.Name, #tblWorn + 1) then
		for _, strFree in ipairs(tblSlots) do
			if not self:GetSlot(strFree) then return strFree end
		end
	end
	if #tblWorn > 0 then return tblWorn[#tblWorn] end
	return tblSlots[1]
end

if CLIENT then
	GM.PaperDollEnts = {}

	net.Receive("UD_UpdatePaperDoll", function()
		local plyPlayer = net.ReadEntity()
		if not IsValid(plyPlayer) then return end
		local strSlot = net.ReadString()
		local strItem = net.ReadString()
		if strItem == "" then strItem = nil end
		plyPlayer:SetPaperDoll(strSlot, strItem)
		plyPlayer:PaperDollBuildSlot(strSlot, strItem)
		if plyPlayer == LocalPlayer() and GAMEMODE.MainMenu then
			GAMEMODE.MainMenu.InventoryTab:LoadInventory()
		end
	end)

	function Player:PaperDollBuildSlot(strSlot, strItem)
		if not self:Alive() then return end
		GAMEMODE.PaperDollEnts[self:SteamID64()] = GAMEMODE.PaperDollEnts[self:SteamID64()] or {}
		local tblPlayerTable = GAMEMODE.PaperDollEnts[self:SteamID64()]
		tblPlayerTable = tblPlayerTable or {}
		for _, strKey in ipairs({strSlot, strSlot .. "#mirror"}) do
			local entPaperDollEnt = tblPlayerTable[strKey]
			if entPaperDollEnt and entPaperDollEnt:IsValid() then
				for _, kid in pairs(entPaperDollEnt.Children or {}) do SafeRemoveEntity(kid) end
				SafeRemoveEntity(entPaperDollEnt)
			end
			tblPlayerTable[strKey] = nil
		end
		if strItem and strSlot then
			local tblItemTable = ItemTable(strItem)
			local tblSlotTable = SlotTable(strSlot)
			if tblItemTable and tblSlotTable and not tblSlotTable.NoModel then
				local entNewPart = GAMEMODE:BuildModel(tblItemTable.Model)
				if not entNewPart then error("help") end
				entNewPart:SetParent(self)
				if istable(tblItemTable.Model) and tblItemTable.Model[1] and tblItemTable.Model[1].BoneMerge then
					entNewPart:AddEffects(EF_BONEMERGE)
					entNewPart.UD_BoneMerged = true
				end
				entNewPart.Item = strItem
				entNewPart.Attachment = tblSlotTable.Attachment
				entNewPart.UD_RestAligned = tblSlotTable.RestAligned
				GAMEMODE.PaperDollEnts[self:SteamID64()][strSlot] = entNewPart
				GAMEMODE:AttachItemEffects(entNewPart)
				if tblSlotTable.MirrorAttachment then
					local entMirror = GAMEMODE:BuildModel(tblItemTable.Model)
					if entMirror then
						entMirror:SetParent(self)
						entMirror.Item = strItem
						entMirror.Attachment = tblSlotTable.MirrorAttachment
						entMirror.UD_RestAligned = tblSlotTable.RestAligned
						entMirror.UD_Mirror = true
						GAMEMODE.PaperDollEnts[self:SteamID64()][strSlot .. "#mirror"] = entMirror
						GAMEMODE:AttachItemEffects(entMirror)
					end
				end
			end
		end
	end

	local RestOffsets = {}
	local RestRetry = {}

	function GM:GetRestOffset(strModel, strBone)
		local strKey = strModel .. "|" .. strBone
		if RestOffsets[strKey] then return RestOffsets[strKey] end
		if (RestRetry[strKey] or 0) > RealTime() then return end
		RestRetry[strKey] = RealTime() + 2
		local entRest = ClientsideModel(strModel, RENDERGROUP_OTHER)
		if not IsValid(entRest) then return end
		entRest:SetNoDraw(true)
		entRest:SetPos(vector_origin)
		entRest:SetAngles(angle_zero)
		local intSequence = entRest:LookupSequence("idle_all_01")
		if intSequence and intSequence > 0 then
			entRest:ResetSequence(intSequence)
			entRest:SetCycle(0)
		end
		entRest:SetupBones()
		local intBone = entRest:LookupBone(strBone)
		local matBone = intBone and entRest:GetBoneMatrix(intBone)
		entRest:Remove()
		if not matBone then return end
		local _, angOffset = WorldToLocal(vector_origin, angle_zero, vector_origin, matBone:GetAngles())
		RestOffsets[strKey] = angOffset
		return angOffset
	end

	local function RestAlign(plyPlayer, strBone, angBone)
		local angOffset = GAMEMODE:GetRestOffset(plyPlayer:GetModel(), strBone)
		if not angOffset then return angBone end
		local _, angAligned = LocalToWorld(vector_origin, angOffset, vector_origin, angBone)
		return angAligned
	end

	local function MirrorLocal(vecPos, angAng)
		local vecForward, vecUp = angAng:Forward(), angAng:Up()
		vecForward.y = -vecForward.y
		vecUp.y = -vecUp.y
		return Vector(vecPos.x, -vecPos.y, vecPos.z), vecForward:AngleEx(vecUp)
	end

	local function PlaceMirrored(entTarget, tblModel, vecSlot, angSlot)
		local Root = tblModel[1]
		local angRoot = Root.Angle or angle_zero
		local vecRoot = LocalToWorld(Root.Position or vector_origin, angle_zero, vector_origin, angRoot)
		local tblPlace = {{entTarget, vecRoot, angRoot}}
		for k, kid in pairs(entTarget.Children or {}) do
			local Info = tblModel[k + 1]
			if IsValid(kid) and Info then
				local _, angKid = LocalToWorld(vector_origin, Info.Angle or angle_zero, vector_origin, angRoot)
				local vecKid = LocalToWorld(Info.Position or vector_origin, angle_zero, vecRoot, angKid)
				table.insert(tblPlace, {kid, vecKid, angKid})
			end
		end
		for _, Place in ipairs(tblPlace) do
			local vecLocal, angLocal = MirrorLocal(Place[2], Place[3])
			local vecWorld, angWorld = LocalToWorld(vecLocal, angLocal, vecSlot, angSlot)
			Place[1]:SetPos(vecWorld)
			Place[1]:SetAngles(angWorld)
		end
	end

	local function GetSlotTransform(plyPlayer, entTarget)
		local strModel = plyPlayer:GetModel()
		if entTarget.UD_LookupModel ~= strModel then
			entTarget.UD_LookupModel = strModel
			entTarget.UD_AttachmentID = plyPlayer:LookupAttachment(entTarget.Attachment)
			entTarget.UD_BoneID = plyPlayer:LookupBone(entTarget.Attachment)
		end
		local tblAttachment = plyPlayer:GetAttachment(entTarget.UD_AttachmentID)
		if tblAttachment then return tblAttachment.Pos, tblAttachment.Ang end
		if entTarget.UD_BoneID then
			local vecBone, angBone = plyPlayer:GetBonePosition(entTarget.UD_BoneID)
			if entTarget.UD_RestAligned and angBone then angBone = RestAlign(plyPlayer, entTarget.Attachment, angBone) end
			return vecBone, angBone
		end
	end

	function GM:GetPaperDollSlotTransform(plyPlayer, strAttachment)
		if not IsValid(plyPlayer) or not strAttachment then return end
		local intAttachment = plyPlayer:LookupAttachment(strAttachment)
		local tblAttachment = intAttachment and intAttachment > 0 and plyPlayer:GetAttachment(intAttachment)
		if tblAttachment then return tblAttachment.Pos, tblAttachment.Ang end
		local intBone = plyPlayer:LookupBone(strAttachment)
		if not intBone then return end
		local vecBone, angBone = plyPlayer:GetBonePosition(intBone)
		for _, tblSlot in pairs(self.DataBase.Slots) do
			if tblSlot.RestAligned and angBone and (tblSlot.Attachment == strAttachment or tblSlot.MirrorAttachment == strAttachment) then
				angBone = RestAlign(plyPlayer, strAttachment, angBone)
				break
			end
		end
		return vecBone, angBone
	end

	local LastPositionedFrame = -1
	local function PositionPaperDolls()
		if FrameNumber() == LastPositionedFrame then return end
		LastPositionedFrame = FrameNumber()

		if LocalPlayer() and not LocalPlayer().Data then LocalPlayer().Data = {} end
		if LocalPlayer() and LocalPlayer().Data and not LocalPlayer().Data.Paperdoll then LocalPlayer().Data.Paperdoll = {} end
		for steamID64, tblPlayerTable in pairs(GAMEMODE.PaperDollEnts) do
			local plyPlayer = player.GetBySteamID64(steamID64)
			if not IsValid(plyPlayer) then
				for _, entTarget in pairs(tblPlayerTable or {}) do
					if IsValid(entTarget) then
						for _, kid in pairs(entTarget.Children or {}) do SafeRemoveEntityDelayed(kid, 0) end
						SafeRemoveEntityDelayed(entTarget, 0)
					end
				end
				GAMEMODE.PaperDollEnts[steamID64] = nil
			elseif not plyPlayer:IsDormant() then
				local EditorOpen = GAMEMODE.PaperDollEditor and GAMEMODE.PaperDollEditor.IsOpen
				for strSlot, entTarget in pairs(tblPlayerTable or {}) do
					local tblItemTable = IsValid(entTarget) and ItemTable(entTarget.Item)
					local tblModel = tblItemTable and istable(tblItemTable.Model) and tblItemTable.Model
					local vecSlot, angSlot
					if tblModel and tblModel[1] then vecSlot, angSlot = GetSlotTransform(plyPlayer, entTarget) end
					if vecSlot and entTarget.UD_Mirror then
						PlaceMirrored(entTarget, tblModel, vecSlot, angSlot)
					elseif vecSlot then
						local Root = tblModel[1]
						local _, angRoot = LocalToWorld(vector_origin, Root.Angle or angle_zero, vector_origin, angSlot)
						local vecRoot = LocalToWorld(Root.Position or vector_origin, angle_zero, vecSlot, angRoot)
						if not entTarget.UD_BoneMerged then
							entTarget:SetAngles(angRoot)
							entTarget:SetPos(vecRoot)
						end
						if EditorOpen or entTarget.UD_BoneMerged or not entTarget.UD_ChildrenPlaced then
							entTarget.UD_ChildrenPlaced = true
							for k, kid in pairs(entTarget.Children or {}) do
								local Info = tblModel[k + 1]
								if IsValid(kid) and Info then
									local _, angKid = LocalToWorld(vector_origin, Info.Angle or angle_zero, vector_origin, angRoot)
									local vecKid = LocalToWorld(Info.Position or vector_origin, angle_zero, vecRoot, angKid)
									if entTarget.UD_BoneMerged and IsValid(kid:GetParent()) then kid:SetParent(NULL) end
									kid:SetAngles(angKid)
									kid:SetPos(vecKid)
									if not entTarget.UD_BoneMerged and kid:GetParent() ~= entTarget then kid:SetParent(entTarget) end
								end
							end
						end
					end
				end
			end
		end
	end
	hook.Add("PreDrawOpaqueRenderables", "UD_DrawPaperDoll", PositionPaperDolls)
end

function GM:BuildModel(tblModelTable)
	local tblLoopTable = tblModelTable
	if type(tblModelTable) == "string" then
		tblLoopTable = {}
		tblLoopTable[1] = {Model = tblModelTable, Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0)}
	end
	local entReturnEnt = nil
	local entNewPart = nil
	for key, tblModelInfo in pairs(tblLoopTable) do
		if SERVER then
			entNewPart = ents.Create("prop_physics")
		elseif CLIENT then
			entNewPart = ents.CreateClientProp("prop_physics")
		end
		entNewPart:SetModel(tblModelInfo.Model)
		if entReturnEnt then entNewPart:SetAngles(entReturnEnt:GetAngles()) end
		if entReturnEnt then entNewPart:SetAngles(entNewPart:LocalToWorldAngles(tblModelInfo.Angle)) end
		if not entReturnEnt then entNewPart:SetAngles(tblModelInfo.Angle) end
		if entReturnEnt then entNewPart:SetPos(entReturnEnt:GetPos()) end
		if entReturnEnt then entNewPart:SetPos(entNewPart:LocalToWorld(tblModelInfo.Position)) end
		if not entReturnEnt then entNewPart:SetPos(tblModelInfo.Position) end
		entNewPart:SetParent(entReturnEnt)
		if SERVER then entNewPart:SetCollisionGroup(COLLISION_GROUP_WORLD) end
		if tblModelInfo.Material then entNewPart:SetMaterial(tblModelInfo.Material) end
		if tblModelInfo.Color then entNewPart:SetColor(Color(tblModelInfo.Color.r, tblModelInfo.Color.g, tblModelInfo.Color.b, tblModelInfo.Color.a)) end
		if tblModelInfo.Scale then
			local scale = type(tblModelInfo.Scale) == "Vector" and tblModelInfo.Scale or tonumber(tblModelInfo.Scale)
			if not scale then return ErrorNoHalt("scale is nil") end

			if CLIENT then
				local matrix = Matrix()
				matrix:Scale(scale)
				entNewPart:EnableMatrix("RenderMultiply", matrix)
				entNewPart.UD_Scale = isvector(scale) and Vector(scale) or Vector(scale, scale, scale)
				--entNewPart:SetModelScale(scale)
			else
				entNewPart:SetServerScale(scale)
			end
		end
		entNewPart:Spawn()
		if entReturnEnt then
			entReturnEnt.Children = entReturnEnt.Children or {}
			table.insert(entReturnEnt.Children, entNewPart)
		end
		if not entReturnEnt then entReturnEnt = entNewPart end
	end
	return entReturnEnt
end
