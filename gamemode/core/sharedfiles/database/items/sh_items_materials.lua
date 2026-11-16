local Bands = {
	{Level = 19, Tint = Color(170, 150, 135, 255),
		Metal = {"mat_ingot_scrap", "Scrap Iron", "Rusted offcuts and broken tools, good enough for a first forging."},
		Leather = {"mat_leather_1", "Rough Hide", "A scraped hide, stiff and smelling of the pit."},
		Cloth = {"mat_cloth_1", "Linen Bolt", "Coarse undyed linen, the cloth of recruits."}},
	{Level = 39, Tint = Color(165, 165, 175, 255),
		Metal = {"mat_ingot_iron", "Iron Ingot", "A plain bar of iron, still warm from the bloomery."},
		Leather = {"mat_leather_2", "Tanned Leather", "Oak-tanned leather, supple enough to cut and stitch."},
		Cloth = {"mat_cloth_2", "Wool Bolt", "Thick wool, warm and hard to tear."}},
	{Level = 59, Tint = Color(205, 212, 225, 255),
		Metal = {"mat_ingot_steel", "Steel Ingot", "Folded and quenched steel, ready for the anvil."},
		Leather = {"mat_leather_3", "Boiled Leather", "Leather boiled in wax until it holds its shape."},
		Cloth = {"mat_cloth_3", "Canvas Bolt", "Heavy canvas, tight-woven and weatherproof."}},
	{Level = 79, Tint = Color(235, 235, 245, 255),
		Metal = {"mat_ingot_silver", "Silver Ingot", "A heavy bar of silver. The smith will be careful with it."},
		Leather = {"mat_leather_4", "Waxed Leather", "Fine leather, waxed and burnished to a dull shine."},
		Cloth = {"mat_cloth_4", "Silk Bolt", "Silk from the southern road, smooth and strong."}},
	{Level = 99, Tint = Color(130, 225, 175, 255),
		Metal = {"mat_ingot_glass", "Glass Ingot", "A bar of green crystal that takes an edge like steel."},
		Leather = {"mat_leather_5", "Stag Leather", "The hide of a royal stag, light and tough."},
		Cloth = {"mat_cloth_5", "Brocade Bolt", "Patterned brocade, stiff with gold thread."}},
	{Level = 119, Tint = Color(80, 80, 92, 255),
		Metal = {"mat_ingot_ebony", "Ebony Ingot", "Black ore smelted down to a dense, cold bar."},
		Leather = {"mat_leather_6", "Bearhide", "A thick bearhide that shrugs off knives."},
		Cloth = {"mat_cloth_6", "Velvet Bolt", "Deep velvet that drinks the light."}},
	{Level = 139, Tint = Color(140, 115, 180, 255),
		Metal = {"mat_ingot_graven", "Gravensteel Ingot", "Steel folded with iron from the Gravenmark's own wall."},
		Leather = {"mat_leather_7", "Direwolf Hide", "A pale pelt from the northern marches."},
		Cloth = {"mat_cloth_7", "Gilded Brocade", "Brocade worked with real gold thread."}},
	{Level = 150, Tint = Color(190, 60, 60, 255),
		Metal = {"mat_ingot_dread", "Dreadforged Ingot", "A bar that is warm when it should be cold."},
		Leather = {"mat_leather_8", "Wyrmhide", "Scale-backed leather from something that should not exist."},
		Cloth = {"mat_cloth_8", "Royal Velvet", "Crimson velvet cut for a king's household."}},
}

local LeatherTint = Color(150, 105, 70, 255)
local ClothTint = Color(225, 215, 190, 255)

GM.CraftMaterials = {}

local function RegisterMaterial(tblInfo, strKind, intBand, tblBand, flShare, intWeight, strIcon, strModel, clrTint)
	local Item = QuickCreateItemTable(BaseItem, tblInfo[1], tblInfo[2], tblInfo[3], strIcon)
	Item.Model = {{Model = strModel, Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0), Color = clrTint}}
	Item.Stackable = true
	Item.Weight = intWeight
	Item.SellPrice = math.max(math.Round(GM:GetGearPrice(tblBand.Level) * GM.Combat.CraftValueShare / GM.Combat.CraftUnitsAtBandTop * flShare), 2)
	Item.CraftMaterial = strKind
	Item.CraftBand = intBand
	Register.Item(Item)
	GM.CraftMaterials[strKind] = GM.CraftMaterials[strKind] or {}
	GM.CraftMaterials[strKind][intBand] = tblInfo[1]
end

for intBand, Band in ipairs(Bands) do
	RegisterMaterial(Band.Metal, "metal", intBand, Band, 1, 0.3, "icons/junk_cog", "models/nayrbarr/iron/iron.mdl", Band.Tint)
	RegisterMaterial(Band.Leather, "leather", intBand, Band, 0.7, 0.2, "icons/junk_box1", "models/props_junk/garbage_bag001a.mdl", LeatherTint)
	RegisterMaterial(Band.Cloth, "cloth", intBand, Band, 0.6, 0.1, "icons/junk_box1", "models/props_junk/garbage_bag001a.mdl", ClothTint)
end
