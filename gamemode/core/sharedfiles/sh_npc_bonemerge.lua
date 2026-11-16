if SERVER then
	function GM:ApplyNPCSkin(entNPC, tblNPCTable)
		local strModel = tblNPCTable.SkinModel
		if istable(strModel) then strModel = strModel[math.random(#strModel)] end
		if not strModel or not IsValid(entNPC) then return end

		if not util.IsValidModel(strModel) then
			print("[Gravenmark] SkinModel for NPC '" .. tostring(tblNPCTable.Name) .. "' is not mounted: " .. strModel)
			return
		end

		entNPC:SetNWString("UD_SkinModel", strModel)
	end

	local function AttachHeldItem(entNPC, strItem)
		local tblItemTable = ItemTable(strItem)
		local tblPart = tblItemTable and istable(tblItemTable.Model) and tblItemTable.Model[1]
		local tblSlotTable = tblItemTable and SlotTable(tblItemTable.Slot)
		if not tblPart or not tblSlotTable or not tblSlotTable.Attachment then return end
		if not util.IsValidModel(tblPart.Model) then
			print("[Gravenmark] Held item '" .. strItem .. "' model is not mounted: " .. tostring(tblPart.Model))
			return
		end
		local intAttachment = entNPC:LookupAttachment(tblSlotTable.Attachment)
		if not tblPart.BoneMerge and (not intAttachment or intAttachment <= 0) then return end

		local entProp = ents.Create("prop_dynamic")
		if not IsValid(entProp) then return end
		entProp:SetModel(tblPart.Model)
		entProp:SetKeyValue("solid", "0")
		entProp:Spawn()

		if tblPart.BoneMerge then
			entProp:SetParent(entNPC)
			entProp:AddEffects(EF_BONEMERGE)
		else
			entProp:SetParent(entNPC, intAttachment)
			local angLocal = tblPart.Angle or Angle(0, 0, 0)
			local vecLocal = Vector(tblPart.Position or vector_origin)
			vecLocal:Rotate(angLocal)
			entProp:SetLocalPos(vecLocal)
			entProp:SetLocalAngles(angLocal)
		end

		entProp:SetNotSolid(true)
		entProp:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		entProp:DrawShadow(false)
		if tblPart.Material then entProp:SetMaterial(tblPart.Material) end
		if tblPart.Color then entProp:SetColor(tblPart.Color) end
		if isnumber(tblPart.Scale) then entProp:SetModelScale(tblPart.Scale) end
		entNPC:DeleteOnRemove(entProp)
		return entProp
	end

	local function HideNPCWeapons(entNPC)
		local tblCandidates = entNPC:GetChildren()
		table.insert(tblCandidates, entNPC:GetActiveWeapon())
		for _, entChild in ipairs(tblCandidates) do
			if IsValid(entChild) and entChild:IsWeapon() then
				entChild:SetNoDraw(true)
				entNPC.UD_HiddenWeapons = entNPC.UD_HiddenWeapons or {}
				entNPC.UD_HiddenWeapons[entChild] = true
			end
		end
	end

	function GM:ApplyNPCHeldItems(entNPC, tblNPCTable)
		if not istable(tblNPCTable.HeldItems) or not IsValid(entNPC) then return end
		local boolAttached = false
		for _, strItem in ipairs(tblNPCTable.HeldItems) do
			if AttachHeldItem(entNPC, strItem) then boolAttached = true end
		end
		if not boolAttached then return end
		HideNPCWeapons(entNPC)
		timer.Simple(0.5, function()
			if IsValid(entNPC) then HideNPCWeapons(entNPC) end
		end)
	end

	hook.Add("OnNPCKilled", "UD_RemoveHiddenNPCWeapons", function(entNPC)
		local tblWeapons = entNPC.UD_HiddenWeapons
		if not tblWeapons then return end
		timer.Simple(0, function()
			for entWeapon in pairs(tblWeapons) do
				if IsValid(entWeapon) then entWeapon:Remove() end
			end
		end)
	end)

	hook.Add("EntityTakeDamage", "UD_NoNPCMeleeKick", function(entVictim, dmg)
		if not IsValid(entVictim) or not entVictim:IsPlayer() then return end
		local entAttacker = dmg:GetAttacker()
		if not IsValid(entAttacker) or not entAttacker:IsNPC() then return end
		dmg:SetDamageForce(vector_origin)
		entVictim:ViewPunchReset()
	end)

	hook.Add("CreateEntityRagdoll", "UD_SkinnedNPCRagdoll", function(entOwner, entRagdoll)
		if not IsValid(entOwner) then return end
		local strModel = entOwner:GetNWString("UD_SkinModel", "")
		if strModel ~= "" then entRagdoll:SetNWString("UD_SkinModel", strModel) end
	end)
else
	local function BuildBoneMap(entSkin, entParent)
		local tblMap = {}
		for i = 0, entSkin:GetBoneCount() - 1 do
			local strBone = entSkin:GetBoneName(i) or ""
			if string.find(strBone, "Finger", 1, true) then
				tblMap[i] = false
			else
				tblMap[i] = entParent:LookupBone(strBone) or false
			end
		end
		return tblMap
	end

	local function CopyParentBones(entSkin, intNumBones)
		local entParent = entSkin.UD_SkinParent
		if not IsValid(entParent) then return end
		local strParentModel = entParent:GetModel()
		if entSkin.UD_BoneMapModel ~= strParentModel then
			entSkin.UD_BoneMap = BuildBoneMap(entSkin, entParent)
			entSkin.UD_BoneMapModel = strParentModel
		end
		local tblMap = entSkin.UD_BoneMap

		local tblOwn = {}
		for i = 0, intNumBones - 1 do
			tblOwn[i] = entSkin:GetBoneMatrix(i)
		end

		for i = 0, intNumBones - 1 do
			local matNew
			if tblMap[i] then
				matNew = entParent:GetBoneMatrix(tblMap[i])
			else
				local intOwnParent = entSkin:GetBoneParent(i)
				local matOwnParent = intOwnParent and intOwnParent >= 0 and tblOwn[intOwnParent]
				local matNewParent = matOwnParent and entSkin:GetBoneMatrix(intOwnParent)
				if matOwnParent and matNewParent and tblOwn[i] then
					matNew = matNewParent * (matOwnParent:GetInverseTR() * tblOwn[i])
				end
			end
			if matNew then entSkin:SetBoneMatrix(i, matNew) end
		end
	end

	local function GetSkinEntity(ent, strModel)
		local entSkin = ent.UD_SkinEntity
		if IsValid(entSkin) and entSkin.UD_SkinModel == strModel then return entSkin end
		if IsValid(entSkin) then entSkin:Remove() end

		entSkin = ClientsideModel(strModel, RENDERGROUP_OPAQUE)
		if not IsValid(entSkin) then return end
		entSkin.UD_SkinModel = strModel
		entSkin.UD_SkinParent = ent
		entSkin:SetPos(ent:GetPos())
		entSkin:SetAngles(ent:GetAngles())
		entSkin:SetParent(ent)
		entSkin:SetNoDraw(true)
		entSkin:AddCallback("BuildBonePositions", CopyParentBones)
		ent.UD_SkinEntity = entSkin
		ent:CallOnRemove("UD_RemoveSkin", function()
			if IsValid(entSkin) then entSkin:Remove() end
		end)
		return entSkin
	end

	local function DrawSkinned(self, intFlags)
		local strModel = self.UD_SkinModelOverride or self:GetNWString("UD_SkinModel", "")
		local entSkin = strModel ~= "" and GetSkinEntity(self, strModel)
		if not entSkin then
			self:DrawModel(intFlags)
			return
		end
		self:SetupBones()
		local Col = self:GetColor()
		render.SetColorModulation(Col.r / 255, Col.g / 255, Col.b / 255)
		entSkin:DrawModel(intFlags)
		render.SetColorModulation(1, 1, 1)
	end

	hook.Add("OnEntityCreated", "UD_SkinnedNPCRender", function(ent)
		if not IsValid(ent) then return end
		if ent:IsNPC() or ent:GetClass() == "prop_ragdoll" then
			ent.RenderOverride = DrawSkinned
		end
	end)

	hook.Add("CreateClientsideRagdoll", "UD_SkinnedNPCRagdoll", function(entOwner, entRagdoll)
		if not IsValid(entOwner) then return end
		local strModel = entOwner:GetNWString("UD_SkinModel", "")
		if strModel == "" then return end
		entRagdoll.UD_SkinModelOverride = strModel
		entRagdoll.RenderOverride = DrawSkinned
	end)
end
