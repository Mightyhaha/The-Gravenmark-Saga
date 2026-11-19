local Fabric = "models/props_c17/furniturefabric003a"
local Leather = "nayrbarr/round shield/leather-dark brown"
local Steel = "nayrbarr/round shield/steelplt"
local DarkMetal = "nayrbarr/hammer/dark scuffed metal"
local IronMetal = "nayrbarr/iron/scuffed metal"
local Dome = "models/props_phx/construct/metal_dome360.mdl"
local Tube = "models/hunter/tubes/tube1x1x1.mdl"
local TubeCap = "models/hunter/tubes/tube1x1x1c.mdl"
local Plate = "models/hunter/plates/plate05x05.mdl"

local MetalMaterials = {[Steel] = true, [DarkMetal] = true, [IronMetal] = true, ["models/shiny"] = true}

local function Part(strModel, vecPosition, angAngle, clrColor, strMaterial, vecScale)
	return {Model = strModel, Position = vecPosition, Angle = angAngle, Color = clrColor, Material = strMaterial, Scale = vecScale}
end

local function Skin(tblParts, tblSkin)
	local tblCopy = {}
	for _, tblPart in ipairs(tblParts) do
		local tblNewPart = table.Copy(tblPart)
		if tblSkin and tblPart.Material and MetalMaterials[tblPart.Material] then
			tblNewPart.Material = tblSkin.Material
			tblNewPart.Color = tblSkin.Color
		end
		table.insert(tblCopy, tblNewPart)
	end
	return tblCopy
end

local function Tinted(tblParts, tblSkin)
	local tblCopy = table.Copy(tblParts)
	if tblSkin and tblSkin.Tint then tblCopy[1].Color = tblSkin.Tint end
	return tblCopy
end

local Shapes = {}

Shapes.coif = {
	Part(Dome, Vector(-3.15, -0.1, 0.25), Angle(0, 0, 0), Color(168, 142, 105, 255), Fabric, Vector(0.105, 0.096, 0.103)),
	Part("models/hunter/tubes/tube1x1x1c.mdl", Vector(0, 0, -5.9), Angle(0, 0, 0), Color(168, 142, 105, 255), Fabric, Vector(0.208, 0.192, 0.126)),
}

Shapes.kettle = {
	Part(Dome, Vector(-3.05, -0.1, 0.95), Angle(0, 0, 0), nil, IronMetal, Vector(0.1, 0.095, 0.092)),
	Part("models/hunter/tubes/circle2x2.mdl", Vector(0, 0, 0), Angle(0, 0, 0), nil, IronMetal, Vector(0.172, 0.164, 0.097)),
	Part(Tube, Vector(0, 0, 0), Angle(0, 0, 0), nil, Leather, Vector(0.202, 0.194, 0.017)),
}

Shapes.greathelm = {
	Part(Tube, Vector(-2.85, -0.1, -5.05), Angle(0, 0, 0), nil, Steel, Vector(0.246, 0.208, 0.222)),
	Part(Dome, Vector(0, 0, 10.6), Angle(0, 0, 0), nil, Steel, Vector(0.124, 0.105, 0.029)),
	Part(TubeCap, Vector(0, 0, 4.7), Angle(0, 180, 0), Color(10, 10, 10, 255), "models/debug/debugwhite", Vector(0.249, 0.211, 0.015)),
	Part(Plate, Vector(-5.3, 0, 6.02), Angle(90, 0, 0), nil, DarkMetal, Vector(0.43, 0.033, 0.067)),
	Part(Tube, Vector(0, 0, 5.7), Angle(0, 0, 0), nil, DarkMetal, Vector(0.249, 0.212, 0.013)),
	Part(Tube, Vector(0, 0, 0), Angle(0, 0, 0), nil, DarkMetal, Vector(0.249, 0.212, 0.013)),
}

Shapes.gambeson = {
	Part(Tube, Vector(-1.05, 0, -17.45), Angle(0.8, 0, 0), Color(150, 124, 92, 255), Fabric, Vector(0.288, 0.375, 0.403)),
	Part(Dome, Vector(0, 0, 19.2), Angle(0, 0, 0), Color(150, 124, 92, 255), Fabric, Vector(0.145, 0.189, 0.09)),
	Part(Tube, Vector(0, 0, 7), Angle(0, 0, 0), Color(118, 96, 70, 255), Fabric, Vector(0.291, 0.378, 0.007)),
	Part(Tube, Vector(0, 0, 13), Angle(0, 0, 0), Color(118, 96, 70, 255), Fabric, Vector(0.291, 0.378, 0.007)),
}

Shapes.breastplate = {
	Part("models/props_phx/construct/metal_plate_curve180.mdl", Vector(1.05, 0, -11.95), Angle(-0.8, -180, 0), nil, Steel, Vector(0.149, 0.193, 0.293)),
	Part("models/props_phx/construct/metal_plate_curve180.mdl", Vector(0, 0, 0), Angle(0, -180, 0), nil, Steel, Vector(0.149, 0.193, 0.293)),
	Part(Dome, Vector(0, 0, 14), Angle(0, -180, 0), nil, Steel, Vector(0.149, 0.193, 0.084)),
	Part(Tube, Vector(0, 0, -5), Angle(0, -180, 0), nil, DarkMetal, Vector(0.306, 0.394, 0.107)),
	Part(Plate, Vector(-7, 0, 7.22), Angle(90, -180, 0), nil, Steel, Vector(0.537, 0.025, 0.067)),
}

Shapes.pauldrons = {
	Part(Dome, Vector(1.34, 9.28, 0.44), Angle(0, -56.9, -118), nil, Steel, Vector(0.096, 0.088, 0.071)),
	Part(Dome, Vector(0, 2.56, 0.16), Angle(0, 0, -27), nil, Steel, Vector(0.082, 0.071, 0.054)),
	Part(Dome, Vector(0, -14.83, 7.89), Angle(0, 0, 56), nil, Steel, Vector(0.096, 0.088, 0.071)),
	Part(Dome, Vector(0, -12.19, 13.93), Angle(0, 0, 83), nil, Steel, Vector(0.082, 0.071, 0.054)),
}

Shapes.swordbelt = {
	Part(Tube, Vector(-0.73, 0, 1.43), Angle(-90, -90, 0), nil, Leather, Vector(0.298, 0.383, 0.034)),
	Part(Plate, Vector(-0.8, 0, 7.3), Angle(90, 0, 0), Color(196, 164, 80, 255), "models/shiny", Vector(0.066, 0.079, 0.1)),
	Part("models/hunter/misc/sphere025x025.mdl", Vector(3.2, -9.2, -1), Angle(0, 0, 0), nil, Leather, Vector(0.21, 0.161, 0.274)),
	Part(Tube, Vector(-1.29, 9.6, -1.26), Angle(-25, 180, 180), nil, Leather, Vector(0.042, 0.029, 0.503)),
}

Shapes.quiltedbelt = {
	Part(Tube, Vector(-0.73, 0, 1.43), Angle(-90, -90, 0), Color(150, 124, 92, 255), Fabric, Vector(0.298, 0.383, 0.034)),
	Part("models/hunter/misc/sphere025x025.mdl", Vector(3.2, -9.2, -1), Angle(0, 0, 0), Color(118, 96, 70, 255), Fabric, Vector(0.21, 0.161, 0.274)),
}

Shapes.leatherboots = {
	Part(Tube, Vector(0.5, 0, -3), Angle(0, 0, 0), Color(110, 78, 50, 255), Leather, Vector(0.118, 0.112, 0.255)),
	Part("models/hunter/misc/sphere025x025.mdl", Vector(2.6, 0, 0.2), Angle(0, 0, 0), Color(96, 66, 42, 255), Leather, Vector(0.92, 0.44, 0.36)),
	Part(Tube, Vector(0, 0, 11), Angle(0, 0, 0), Color(80, 56, 36, 255), Leather, Vector(0.134, 0.128, 0.03)),
}

Shapes.sabatons = {
	Part(Tube, Vector(0.5, 0, -3), Angle(0, 0, 0), Color(90, 64, 42, 255), Leather, Vector(0.12, 0.114, 0.26)),
	Part("models/hunter/misc/sphere025x025.mdl", Vector(2.8, 0, 0.3), Angle(0, 0, 0), nil, Steel, Vector(0.96, 0.47, 0.38)),
	Part(Tube, Vector(0.2, 0, 4), Angle(0, 0, 0), nil, Steel, Vector(0.13, 0.124, 0.15)),
	Part(Tube, Vector(0, 0, 7.2), Angle(0, 0, 0), nil, DarkMetal, Vector(0.138, 0.132, 0.025)),
}

Shapes.buckler = {
	Part("models/hunter/tubes/circle2x2.mdl", Vector(0, 0, 1.5), Angle(51.4, 174.6, 98), nil, "nayrbarr/round shield/oldwood", Vector(0.138, 0.138, 0.194)),
	Part(Dome, Vector(0, 0, 0.35), Angle(0, 0, 0), nil, Steel, Vector(0.048, 0.048, 0.04)),
	Part(Tube, Vector(0, 0, -0.45), Angle(0, 0, 0), nil, DarkMetal, Vector(0.281, 0.281, 0.019)),
}

Shapes.roundshield = {Part("models/nayrbarr/round shield/round shield.mdl", Vector(3.1, 1.9, -16.4), Angle(5, 78.3, 38.3))}
Shapes.guardshield = {Part("models/items/armors/shield_guard/shield_guard.mdl", Vector(2.12, 6.44, 0), Angle(0, 75, 0))}

local Skins = {
	steel = {Material = Steel, Color = Color(205, 212, 225, 255), Tint = Color(205, 212, 225, 255)},
	silver = {Material = Steel, Color = Color(238, 238, 248, 255), Tint = Color(238, 238, 248, 255)},
	glass = {Material = Steel, Color = Color(130, 225, 175, 255), Tint = Color(130, 225, 175, 255)},
	ebony = {Material = DarkMetal, Color = Color(80, 80, 92, 255), Tint = Color(80, 80, 92, 255)},
	graven = {Material = Steel, Color = Color(140, 115, 180, 255), Tint = Color(140, 115, 180, 255)},
	dread = {Material = DarkMetal, Color = Color(190, 60, 60, 255), Tint = Color(190, 60, 60, 255)},
}

local Icons = {
	slot_helm = "icons/junk_pan2",
	slot_chest = "icons/amor_junkyarmor",
	slot_shoulder = "icons/hat_cheifshat",
	slot_waist = "icons/item_cash",
	slot_offhand = "icons/armor_carbonsheild",
	slot_boots = "icons/junk_shoe",
}

local Weights = {slot_helm = 2, slot_chest = 5, slot_shoulder = 3, slot_waist = 1, slot_offhand = 3, slot_boots = 2}

local function PieceBuffs(strSlot, intLevel)
	local Buffs = {}
	if strSlot == "slot_helm" then Buffs.stat_maxhealth = math.max(math.Round(intLevel * 0.5), 1) end
	local intStrength = math.Round(intLevel / 60)
	if intStrength > 0 and (strSlot == "slot_shoulder" or strSlot == "slot_waist") then Buffs.stat_strength = intStrength end
	if strSlot == "slot_boots" then
		Buffs.stat_movespeed = math.Round(GM.Combat.BootSpeedBase + intLevel * GM.Combat.BootSpeedPerLevel)
		local intAgility = math.Round(intLevel / 60)
		if intAgility > 0 then Buffs.stat_agility = intAgility end
	end
	return Buffs
end

local function RegisterPiece(strId, strName, strDesc, strSlot, intLevel, tblModel, strSet, intWeight, strIcon)
	local Item = QuickCreateItemTable(BaseArmor, strId, strName, strDesc, strIcon or Icons[strSlot])
	Item.Model = tblModel
	Item.Slot = strSlot
	Item.Level = intLevel
	Item.Armor = GM:GetArmorTierValue(strSlot, intLevel)
	Item.Weight = intWeight or Weights[strSlot]
	Item.SellPrice = GM:GetArmorPrice(strSlot, intLevel)
	Item.Buffs = PieceBuffs(strSlot, intLevel)
	Item.Set = strSet
	Item.Crafted = true
	Register.Item(Item)
end

local function RegisterSet(strId, strName, tblItems, tblBuffs)
	local EquipmentSet = {}
	EquipmentSet.Name = strId
	EquipmentSet.PrintName = strName
	EquipmentSet.Items = tblItems
	EquipmentSet.Buffs = tblBuffs
	Register.EquipmentSet(EquipmentSet)
end

local function TierBuffs(intLevel)
	return {stat_maxhealth = intLevel, stat_strength = math.max(math.Round(intLevel / 40), 1)}
end

RegisterPiece("armor_chest_gambeson", "Padded Gambeson", "Layers of stitched cloth. The first armor every recruit is handed.", "slot_chest", 1, Shapes.gambeson, "set_recruit", 3)
RegisterPiece("armor_shield_buckler", "Buckler", "A fist-sized shield of oak and iron for turning blades aside.", "slot_offhand", 1, Shapes.buckler, nil, 2)
RegisterPiece("armor_boots_leather", "Leather Boots", "Turnshoes of waxed hide, laced to the calf. Dry feet win more fights than sharp swords.", "slot_boots", 5, Shapes.leatherboots, nil, 1)
RegisterPiece("armor_belt_quilted", "Quilted Belt", "A wide belt of quilted linen. It keeps the gambeson from riding up.", "slot_waist", 10, Shapes.quiltedbelt, "set_recruit", 1)
RegisterPiece("armor_helm_paddedcoif", "Padded Coif", "Quilted linen hood. Keeps the rain off and the worst of a cudgel.", "slot_helm", 15, Shapes.coif, "set_recruit", 1, "icons/hat_cheifshat")
RegisterSet("set_recruit", "Recruit's Kit", {"armor_helm_paddedcoif", "armor_chest_gambeson", "armor_belt_quilted"}, {stat_maxhealth = 10})

RegisterPiece("armor_helm_greathelm", "Great Helm", "A flat-topped steel helm with a narrow sight. You hear your own breathing.", "slot_helm", 20, Shapes.greathelm, "set_garrison")
RegisterPiece("armor_chest_breastplate", "Iron Breastplate", "Front and back plates over a mail skirt.", "slot_chest", 20, Shapes.breastplate, "set_garrison")
RegisterPiece("armor_shoulder_pauldrons", "Iron Pauldrons", "Overlapping shoulder plates that guard the sword arm.", "slot_shoulder", 20, Shapes.pauldrons, "set_garrison")
RegisterPiece("armor_belt_swordbelt", "Sword Belt", "Leather belt with a scabbard, a pouch and a brass buckle.", "slot_waist", 20, Shapes.swordbelt, "set_garrison")
RegisterPiece("armor_boots_ironshod", "Iron-Shod Boots", "Riding boots with iron plates over the toes and shins.", "slot_boots", 20, Shapes.sabatons, nil)
RegisterPiece("armor_shield_round", "Round Shield", "Wood and iron, painted over many times.", "slot_offhand", 20, Shapes.roundshield)
RegisterSet("set_garrison", "Garrison Plate", {"armor_helm_greathelm", "armor_chest_breastplate", "armor_shoulder_pauldrons", "armor_belt_swordbelt"}, TierBuffs(20))

local Tiers = {
	{Key = "steel", Level = 40, Set = "set_warden", SetName = "Warden's Plate", Helm = Shapes.kettle, Shield = Shapes.guardshield, Names = {
		helm = {"armor_helm_kettlehat", "Kettle Hat", "An iron cap with a wide brim, popular with sentries and pikemen."},
		chest = {"armor_chest_steel", "Steel Cuirass", "A steel cuirass over a quilted lining. Heavy, but it turns most blades."},
		shoulder = {"armor_shoulder_steel", "Steel Pauldrons", "Overlapping steel shoulder plates, riveted to a leather harness."},
		waist = {"armor_belt_steel", "Steel-Studded Belt", "A thick belt studded with steel. It spreads the weight of the plate."},
		boots = {"armor_boots_steel", "Steel Sabatons", "Laminated steel shoes that clank on every stair."},
		shield = {"armor_shield_guard", "Guard Shield", "A painted heater shield of the town watch, edged in iron."},
	}},
	{Key = "silver", Level = 60, Set = "set_silverguard", SetName = "Silverguard Plate", Helm = Shapes.greathelm, Shield = Shapes.guardshield, Names = {
		helm = {"armor_helm_silver", "Silver Great Helm", "A great helm washed in silver. The visor shows a narrow cross."},
		chest = {"armor_chest_silver", "Silver Cuirass", "Silvered plate worn by the guards of great houses."},
		shoulder = {"armor_shoulder_silver", "Silver Pauldrons", "Silvered plates with a raised crest along each edge."},
		waist = {"armor_belt_silver", "Silver-Studded Belt", "A belt studded with silver, worn to remind the wearer of an oath."},
		boots = {"armor_boots_silver", "Silver Sabatons", "Silvered sabatons, polished each morning by a squire who hates them."},
		shield = {"armor_shield_silver", "Silvered Guard Shield", "A heater shield faced with silver. It is never dented, only repainted."},
	}},
	{Key = "glass", Level = 80, Set = "set_glasswright", SetName = "Glasswright Plate", Helm = Shapes.kettle, Shield = Shapes.roundshield, Names = {
		helm = {"armor_helm_glass", "Glass Kettle Helm", "A kettle helm of green glass. Light, and harder than steel."},
		chest = {"armor_chest_glass", "Glass Cuirass", "Plates of green glass on a hardened leather jerkin."},
		shoulder = {"armor_shoulder_glass", "Glass Pauldrons", "Green glass plates that ring faintly when struck."},
		waist = {"armor_belt_glass", "Glass-Studded Belt", "A belt with glass studs. They do not rust or tarnish."},
		boots = {"armor_boots_glass", "Glass Sabatons", "Green glass over hardened leather. They make no sound at all."},
		shield = {"armor_shield_glass", "Glass Round Shield", "A round shield of laminated glass. Light as a plank."},
	}},
	{Key = "ebony", Level = 100, Set = "set_ebon", SetName = "Ebon Bulwark", Helm = Shapes.greathelm, Shield = Shapes.guardshield, Names = {
		helm = {"armor_helm_ebony", "Ebony Great Helm", "A black helm that swallows the face of the wearer."},
		chest = {"armor_chest_ebony", "Ebony Cuirass", "Black plate, cold even in summer. Few blades leave a mark."},
		shoulder = {"armor_shoulder_ebony", "Ebony Pauldrons", "Heavy ebony plates that need a strong back."},
		waist = {"armor_belt_ebony", "Ebony-Studded Belt", "A belt studded with ebony. It is heavier than it looks."},
		boots = {"armor_boots_ebony", "Ebony Sabatons", "Black plate shoes. The ground seems to give way before them."},
		shield = {"armor_shield_ebony", "Ebony Guard Shield", "A black heater shield that has outlived its owners."},
	}},
	{Key = "graven", Level = 120, Set = "set_gravenwarden", SetName = "Gravenwarden Plate", Helm = Shapes.kettle, Shield = Shapes.roundshield, Names = {
		helm = {"armor_helm_graven", "Gravensteel Helm", "A helm of Gravensteel, crested like the wall's own battlements."},
		chest = {"armor_chest_graven", "Gravensteel Cuirass", "Gravensteel plate worn by the wardens of the Gravenmark."},
		shoulder = {"armor_shoulder_graven", "Gravensteel Pauldrons", "Pauldrons stamped with the wall's seal."},
		waist = {"armor_belt_graven", "Gravensteel Belt", "A belt of linked Gravensteel plates."},
		boots = {"armor_boots_graven", "Gravensteel Sabatons", "Sabatons of Gravensteel, made to stand on the wall for a whole winter."},
		shield = {"armor_shield_graven", "Gravensteel Round Shield", "A round shield of Gravensteel, faced with the wall's seal."},
	}},
	{Key = "dread", Level = 140, Set = "set_dreadforged", SetName = "Dreadforged Regalia", Helm = Shapes.greathelm, Shield = Shapes.guardshield, Names = {
		helm = {"armor_helm_dread", "Dreadforged Great Helm", "A helm from the Dreadforge. The visor is always a little too dark."},
		chest = {"armor_chest_dread", "Dreadforged Cuirass", "Plate forged in a fire no smith will speak of."},
		shoulder = {"armor_shoulder_dread", "Dreadforged Pauldrons", "Pauldrons that seem to lean toward the enemy."},
		waist = {"armor_belt_dread", "Dreadforged Belt", "A belt of black iron links that never quite sits still."},
		boots = {"armor_boots_dread", "Dreadforged Sabatons", "They leave scorched prints that take a day to cool."},
		shield = {"armor_shield_dread", "Dreadforged Guard Shield", "A shield that has never been seen to break."},
	}},
}

for _, Tier in ipairs(Tiers) do
	local tblSkin = Skins[Tier.Key]
	local Names = Tier.Names
	RegisterPiece(Names.helm[1], Names.helm[2], Names.helm[3], "slot_helm", Tier.Level, Skin(Tier.Helm, tblSkin), Tier.Set)
	RegisterPiece(Names.chest[1], Names.chest[2], Names.chest[3], "slot_chest", Tier.Level, Skin(Shapes.breastplate, tblSkin), Tier.Set)
	RegisterPiece(Names.shoulder[1], Names.shoulder[2], Names.shoulder[3], "slot_shoulder", Tier.Level, Skin(Shapes.pauldrons, tblSkin), Tier.Set)
	RegisterPiece(Names.waist[1], Names.waist[2], Names.waist[3], "slot_waist", Tier.Level, Skin(Shapes.swordbelt, tblSkin), Tier.Set)
	RegisterPiece(Names.boots[1], Names.boots[2], Names.boots[3], "slot_boots", Tier.Level, Skin(Shapes.sabatons, tblSkin), nil)
	RegisterPiece(Names.shield[1], Names.shield[2], Names.shield[3], "slot_offhand", Tier.Level, Tinted(Tier.Shield, tblSkin), nil)
	RegisterSet(Tier.Set, Tier.SetName, {Names.helm[1], Names.chest[1], Names.shoulder[1], Names.waist[1]}, TierBuffs(Tier.Level))
end
