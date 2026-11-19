local SLOT = {}
SLOT.Name = "slot_shoulder"
SLOT.PrintName = "Shoulder"
SLOT.Desc = "Goes over your shoulders"
SLOT.Position = Vector(75, 12, 0)
SLOT.Attachment = "ValveBiped.Bip01_Neck1"
SLOT.BodyAngle = Angle(-56.9, 0, 90)
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_helm"
SLOT.PrintName = "Helmet/Hat"
SLOT.Desc = "Goes on your head"
SLOT.Position = Vector(50, 12, 0)
SLOT.Attachment = "eyes"
SLOT.BodyAngle = Angle(0, 0, 0)
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_chest"
SLOT.PrintName = "Chest Piece"
SLOT.Desc = "Goes on your chest"
SLOT.Position = Vector(50, 35, 0)
SLOT.Attachment = "chest"
SLOT.BodyAngle = Angle(-0.8, 0, 0)
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_waist"
SLOT.PrintName = "Waist Piece"
SLOT.Desc = "Goes on your waist"
SLOT.Position = Vector(50, 58, 0)
SLOT.Attachment = "ValveBiped.Bip01_Pelvis"
SLOT.BodyAngle = Angle(0, 90, 90)
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_boots"
SLOT.PrintName = "Boots"
SLOT.Desc = "Goes on your feet"
SLOT.Position = Vector(50, 81, 0)
SLOT.Attachment = "ValveBiped.Bip01_R_Foot"
SLOT.MirrorAttachment = "ValveBiped.Bip01_L_Foot"
SLOT.RestAligned = true
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_primaryweapon"
SLOT.PrintName = "Primary Weapon"
SLOT.Desc = "Your main weapon"
SLOT.Position = Vector(25, 35, 0)
SLOT.Attachment = "anim_attachment_RH"
function SLOT:ShouldClear(ply, itm)
	local PrimaryWeapon = ItemTable(ply:GetSlot("slot_primaryweapon"))
	local Shield = ItemTable(ply:GetSlot("slot_offhand"))
	if not Shield or (Shield and PrimaryWeapon.HoldType and PrimaryWeapon.HoldType == "melee") then
		return false
	end
	return true
end
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_offhand"
SLOT.PrintName = "Off Hand"
SLOT.Desc = "A off hand object for melee weapons"
SLOT.Position = Vector(75, 35, 0)
SLOT.Attachment = "anim_attachment_LH"
function SLOT:ShouldClear(ply, itm)
	local PrimaryWeapon = ItemTable(ply:GetSlot("slot_primaryweapon"))
	if not PrimaryWeapon or (PrimaryWeapon and PrimaryWeapon.HoldType and PrimaryWeapon.HoldType == "melee") then
		return false
	end
	return true
end
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_neck"
SLOT.PrintName = "Necklace"
SLOT.Desc = "Worn around your neck"
SLOT.Position = Vector(25, 12, 0)
SLOT.NoModel = true
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_ring_1"
SLOT.PrintName = "Ring"
SLOT.Desc = "Any ring"
SLOT.Position = Vector(25, 58, 0)
SLOT.Group = "ring"
SLOT.NoModel = true
Register.Slot(SLOT)

local SLOT = {}
SLOT.Name = "slot_ring_2"
SLOT.PrintName = "Ring"
SLOT.Desc = "Any ring"
SLOT.Position = Vector(75, 58, 0)
SLOT.Group = "ring"
SLOT.NoModel = true
Register.Slot(SLOT)
