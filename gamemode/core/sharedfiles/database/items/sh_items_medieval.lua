local Sound = "weapons/iceaxe/iceaxe_swing1.wav"

local Icons = {
	sword = "icons/weapon_cleaver",
	axe = "icons/weapon_axe",
	spear = "icons/weapon_pipe",
	hammer = "icons/tool_wrench",
	bow = "icons/weapon_pipe",
	crossbow = "icons/weapon_pipe",
}

local Weights = {sword = 3, axe = 3, spear = 3, hammer = 4, bow = 2, crossbow = 4}

local Tint = {
	rust = Color(205, 120, 60, 255),
	scrap = Color(170, 150, 135, 255),
	iron = Color(165, 165, 175, 255),
	steel = Color(205, 212, 225, 255),
	silver = Color(235, 235, 245, 255),
	glass = Color(130, 225, 175, 255),
	ebony = Color(80, 80, 92, 255),
	graven = Color(140, 115, 180, 255),
	dread = Color(190, 60, 60, 255),
	moon = Color(200, 230, 255, 255),
	ash = Color(160, 160, 165, 255),
	gold = Color(255, 215, 120, 255),
}

local function Single(strModel, vecPosition, angAngle, clrTint)
	return {{Model = strModel, Position = vecPosition, Angle = angAngle, Color = clrTint}}
end

local function Merged(strMaterial, clrTint)
	return {{Model = "models/morrowind/" .. strMaterial .. "/longsword/w_" .. strMaterial .. "_longsword.mdl", Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0), BoneMerge = true, Color = clrTint}}
end

local function NayrSword(clrTint) return Single("models/nayrbarr/sword/sword.mdl", Vector(-16.4, -0.3, 0), Angle(98.3, 0, 0), clrTint) end
local function NayrAxe(clrTint) return Single("models/nayrbarr/axe/axe.mdl", Vector(-0.13, -11.81, -3.39), Angle(0, 73.7, -90), clrTint) end
local function NayrSpear(clrTint) return Single("models/nayrbarr/spear/spear.mdl", Vector(-19.99, -0.89, -0.08), Angle(83.4, 175.2, 180), clrTint) end
local function NayrHammer(clrTint) return Single("models/nayrbarr/hammer/hammer.mdl", Vector(-5, 0, -0.16), Angle(88.2, 180, 180), clrTint) end
local function NayrBow(clrTint) return Single("models/nayrbarr/bow/bow.mdl", Vector(5.76, 0.22, -27.95), Angle(0, 171.5, 2.4), clrTint) end
local function NayrCrossbow(clrTint) return Single("models/nayrbarr/crossbow/crossbow.mdl", Vector(-15.03, 0, 0), Angle(0, 180, 0), clrTint) end
local function ShortSword(clrTint) return Single("models/items/weapons/sword_short/sword_short.mdl", Vector(0, -0.76, -0.2), Angle(-90, 10, 0), clrTint) end
local function LongSword(clrTint) return Single("models/items/weapons/sword_long/sword_long.mdl", Vector(1, -0.76, -0.2), Angle(-90, 10, 0), clrTint) end
local function SilverSword(clrTint) return Single("models/items/weapons/sword_silver/sword_silver.mdl", Vector(0, -0.76, -0.2), Angle(-90, 10, 0), clrTint) end
local function BeardedAxe(clrTint) return Single("models/items/weapons/axes/axe.mdl", Vector(0, -0.76, -0.2), Angle(-90, 10, 0), clrTint) end

local Ladders = {}

Ladders.sword = {
	{1, "weapon_melee_rustysword", "Rusty Sword", "Pitted and dull, but it still has a point.", NayrSword(Tint.rust), 2},
	{10, "weapon_melee_sword", "Arming Sword", "A plain one-handed sword, standard issue in Morvaine's garrisons.", NayrSword()},
	{20, "weapon_melee_shortsword", "Short Sword", "A short, stiff blade. Quick in a press of bodies.", ShortSword()},
	{30, "weapon_melee_iron_longsword", "Iron Longsword", "Plain iron, honestly made. A soldier's first real sword.", Merged("iron")},
	{40, "weapon_melee_longsword", "Knight's Longsword", "A long cruciform blade with a leather grip, carried by the sworn.", LongSword()},
	{50, "weapon_melee_steel_longsword", "Steel Longsword", "Tempered steel from the forges of the south. Holds an edge through a campaign.", Merged("steel")},
	{60, "weapon_melee_silversword", "Silvered Sword", "Its blade is washed in silver. Some say it cuts what iron cannot.", SilverSword()},
	{70, "weapon_melee_silver_longsword", "Silver Longsword", "A long blade of true silver over a steel core. A lord's weapon.", Merged("silver")},
	{80, "weapon_melee_glass_longsword", "Glass Longsword", "A green crystal blade, light as a reed and sharper than any steel.", Merged("glass")},
	{90, "weapon_melee_moonglass_longsword", "Moonglass Longsword", "Glass drawn out pale and thin. It throws a cold light in the dark.", Merged("glass", Tint.moon)},
	{100, "weapon_melee_ebony_longsword", "Ebony Longsword", "Black ore from deep under the mountains, heavy and unbreakable.", Merged("ebony")},
	{110, "weapon_melee_ashen_longsword", "Ashen Ebony Longsword", "Ebony frosted grey by the ash of a hundred funeral fires.", Merged("ebony", Tint.ash)},
	{120, "weapon_melee_gravensteel_longsword", "Gravensteel Longsword", "Steel folded with iron from the Gravenmark's own wall.", Merged("steel", Tint.graven)},
	{130, "weapon_melee_gravensteel_bastard", "Gravensteel Bastard Sword", "A hand-and-a-half blade for those who duel in earnest.", Merged("silver", Tint.graven)},
	{140, "weapon_melee_daedric_longsword", "Dreadforged Longsword", "Forged in a fire no smith will speak of. It hums when blood is near.", Merged("daedric")},
	{150, "weapon_melee_dreadforged_oathblade", "Dreadforged Oathblade", "The last blade of its line. It was made to end oaths, not keep them.", Merged("daedric", Tint.gold)},
}

Ladders.axe = {
	{5, "weapon_melee_handaxe", "Hand Axe", "A short axe for wood and worse.", NayrAxe()},
	{15, "weapon_melee_waraxe", "War Axe", "A bearded axe on a long haft. Bites through shields.", BeardedAxe()},
	{25, "weapon_melee_iron_hatchet", "Iron Hatchet", "A hatchet of plain iron. It finds the gaps in armor.", NayrAxe(Tint.iron)},
	{35, "weapon_melee_iron_beardedaxe", "Iron Bearded Axe", "A bearded iron axe with a wide, hooking edge.", BeardedAxe(Tint.iron)},
	{45, "weapon_melee_steel_hatchet", "Steel Hatchet", "A steel hatchet, balanced for the quick, hard cut.", NayrAxe(Tint.steel)},
	{55, "weapon_melee_steel_beardedaxe", "Steel Bearded Axe", "Bearded steel. It bites deep and hooks shields aside.", BeardedAxe(Tint.steel)},
	{65, "weapon_melee_silver_hatchet", "Silver Hatchet", "Silver-bright and sharp enough to part a mail coif.", NayrAxe(Tint.silver)},
	{75, "weapon_melee_silver_beardedaxe", "Silver Bearded Axe", "A bearded axe with a silver-washed head.", BeardedAxe(Tint.silver)},
	{85, "weapon_melee_glass_hatchet", "Glass Hatchet", "A green glass edge on a short haft. It rings when it lands.", NayrAxe(Tint.glass)},
	{95, "weapon_melee_glass_beardedaxe", "Glass Bearded Axe", "Crystal, bearded and cruel. A good swing never needs a second.", BeardedAxe(Tint.glass)},
	{105, "weapon_melee_ebony_hatchet", "Ebony Hatchet", "Black and heavy. It lands where the wielder looks.", NayrAxe(Tint.ebony)},
	{115, "weapon_melee_ebony_beardedaxe", "Ebony Bearded Axe", "An ebony head on an ash haft. Shields split along its line.", BeardedAxe(Tint.ebony)},
	{125, "weapon_melee_gravensteel_hatchet", "Gravensteel Hatchet", "Gravensteel keeps an edge no whetstone can improve.", NayrAxe(Tint.graven)},
	{135, "weapon_melee_gravensteel_beardedaxe", "Gravensteel Bearded Axe", "A bearded axe of Gravensteel, made to end sieges.", BeardedAxe(Tint.graven)},
	{145, "weapon_melee_dreadforged_waraxe", "Dreadforged War Axe", "A war axe from the Dreadforge. It always finds the throat.", BeardedAxe(Tint.dread)},
}

Ladders.spear = {
	{8, "weapon_melee_spear", "Spear", "Long ash shaft, iron head. Keeps trouble at arm's length.", NayrSpear()},
	{18, "weapon_melee_boarspear", "Boar Spear", "A broad leaf head with a crossbar, for those who hunt what bites back.", NayrSpear(Tint.scrap)},
	{28, "weapon_melee_iron_spear", "Iron Spear", "An iron-headed spear, well balanced and honestly made.", NayrSpear(Tint.iron)},
	{38, "weapon_melee_iron_partisan", "Iron Partisan", "A winged iron head that catches blades as well as bodies.", NayrSpear(Tint.iron)},
	{48, "weapon_melee_steel_spear", "Steel Spear", "A steel spear with a long, tapering head.", NayrSpear(Tint.steel)},
	{58, "weapon_melee_steel_partisan", "Steel Partisan", "A winged steel partisan favoured by the town watch.", NayrSpear(Tint.steel)},
	{68, "weapon_melee_silver_spear", "Silver Spear", "A silver-bladed spear. Lords' guards carry nothing else.", NayrSpear(Tint.silver)},
	{78, "weapon_melee_silver_partisan", "Silver Partisan", "A silvered partisan carried by the Hallowgate honour guard.", NayrSpear(Tint.silver)},
	{88, "weapon_melee_glass_spear", "Glass Spear", "A crystal spearhead on a pale shaft. It never needs sharpening.", NayrSpear(Tint.glass)},
	{98, "weapon_melee_glass_partisan", "Glass Partisan", "A winged glass head. The cut is clean and the wound is not.", NayrSpear(Tint.glass)},
	{108, "weapon_melee_ebony_spear", "Ebony Spear", "A black spear that drinks the light.", NayrSpear(Tint.ebony)},
	{118, "weapon_melee_ebony_partisan", "Ebony Partisan", "A black partisan with wings like a raven's.", NayrSpear(Tint.ebony)},
	{128, "weapon_melee_gravensteel_spear", "Gravensteel Spear", "Gravensteel from tip to socket, with a very long reach.", NayrSpear(Tint.graven)},
	{138, "weapon_melee_gravensteel_partisan", "Gravensteel Partisan", "A partisan made for holding the Gravenmark's gates.", NayrSpear(Tint.graven)},
	{148, "weapon_melee_dreadforged_spear", "Dreadforged Spear", "A spear that is never quite where you thought it was.", NayrSpear(Tint.dread)},
}

Ladders.hammer = {
	{3, "weapon_melee_smithhammer", "Smithing Hammer", "Made for the anvil, but it settles arguments too.", NayrHammer()},
	{13, "weapon_melee_warhammer", "War Hammer", "A short haft and a heavy head. Slow, and worth it.", NayrHammer(Tint.scrap)},
	{23, "weapon_melee_iron_mace", "Iron Mace", "A flanged iron mace. It dents helms and the heads under them.", NayrHammer(Tint.iron)},
	{33, "weapon_melee_iron_maul", "Iron Maul", "A two-fisted iron maul. Armor means little under it.", NayrHammer(Tint.iron)},
	{43, "weapon_melee_steel_mace", "Steel Mace", "A steel flanged mace, balanced to hit hard and recover.", NayrHammer(Tint.steel)},
	{53, "weapon_melee_steel_maul", "Steel Maul", "A steel maul that rings like a bell on a helm.", NayrHammer(Tint.steel)},
	{63, "weapon_melee_silver_mace", "Silver Mace", "A silvered mace of the temple guard.", NayrHammer(Tint.silver)},
	{73, "weapon_melee_silver_maul", "Silver Maul", "A heavy silvered maul. It breaks what it cannot cut.", NayrHammer(Tint.silver)},
	{83, "weapon_melee_glass_mace", "Glass Mace", "A crystal-headed mace that shatters morale if not bone.", NayrHammer(Tint.glass)},
	{93, "weapon_melee_glass_maul", "Glass Maul", "A glass maul so heavy it should not be this light.", NayrHammer(Tint.glass)},
	{103, "weapon_melee_ebony_mace", "Ebony Mace", "Black as a funeral and twice as final.", NayrHammer(Tint.ebony)},
	{113, "weapon_melee_ebony_maul", "Ebony Maul", "A maul of solid ebony. Few can lift it, fewer survive it.", NayrHammer(Tint.ebony)},
	{123, "weapon_melee_gravensteel_mace", "Gravensteel Mace", "A mace of Gravensteel with a spiked flange.", NayrHammer(Tint.graven)},
	{133, "weapon_melee_gravensteel_maul", "Gravensteel Maul", "A maul that finishes what the wall began.", NayrHammer(Tint.graven)},
	{143, "weapon_melee_dreadforged_maul", "Dreadforged Maul", "It falls slowly, and nothing gets up.", NayrHammer(Tint.dread)},
}

Ladders.bow = {
	{6, "weapon_ranged_huntingbow", "Hunting Bow", "A short ash bow strung with gut. Good for hares, and for worse.", NayrBow()},
	{16, "weapon_ranged_shortbow", "Horn Short Bow", "A horn-backed short bow, quick to draw from the saddle.", NayrBow(Tint.scrap)},
	{26, "weapon_ranged_yewlongbow", "Yew Longbow", "A tall yew bow. A levyman's weapon, and a deadly one at a hundred paces.", NayrBow(Tint.rust)},
	{36, "weapon_ranged_iron_recurve", "Iron-Capped Recurve", "A recurve bow with iron caps on the limbs. It throws an arrow hard and flat.", NayrBow(Tint.iron)},
	{46, "weapon_ranged_steel_recurve", "Steel Recurve", "Steel-backed limbs that hold their draw through rain and frost.", NayrBow(Tint.steel)},
	{56, "weapon_ranged_steel_warbow", "Steel War Bow", "A heavy war bow. Few can draw it twice in a row, fewer can be hit twice by it.", NayrBow(Tint.steel)},
	{66, "weapon_ranged_silver_longbow", "Silvered Longbow", "Its limbs are bound in silver wire. Hunters of the old forests swear by it.", NayrBow(Tint.silver)},
	{76, "weapon_ranged_silver_recurve", "Silver Recurve", "A lord's hunting bow, quick and true.", NayrBow(Tint.silver)},
	{86, "weapon_ranged_glass_longbow", "Glass Longbow", "Green glass laminated over horn. It sings when loosed.", NayrBow(Tint.glass)},
	{96, "weapon_ranged_moonglass_bow", "Moonglass Bow", "Pale glass that throws a cold light. Its arrows are hard to see coming.", NayrBow(Tint.moon)},
	{106, "weapon_ranged_ebony_longbow", "Ebony Longbow", "Black wood heavy as iron. Only the strong can string it.", NayrBow(Tint.ebony)},
	{116, "weapon_ranged_ashen_bow", "Ashen Ebony Bow", "Ebony frosted grey by funeral ash. It never misses its mark twice.", NayrBow(Tint.ash)},
	{126, "weapon_ranged_gravensteel_recurve", "Gravensteel Recurve", "A recurve with Gravensteel limbs, built for the archers on the old wall.", NayrBow(Tint.graven)},
	{136, "weapon_ranged_gravensteel_warbow", "Gravensteel War Bow", "The bow of the wall's last captains. Its arrows go through mail.", NayrBow(Tint.graven)},
	{146, "weapon_ranged_dreadforged_longbow", "Dreadforged Longbow", "Strung with something that is not gut. The arrows whisper as they fly.", NayrBow(Tint.dread)},
}

Ladders.crossbow = {
	{12, "weapon_ranged_lightcrossbow", "Light Crossbow", "A hunting crossbow with a wooden prod. Slow, but anyone can aim it.", NayrCrossbow()},
	{22, "weapon_ranged_iron_crossbow", "Iron Crossbow", "An iron prod on an oak stock. Its bolts punch through leather.", NayrCrossbow(Tint.iron)},
	{32, "weapon_ranged_iron_arbalest", "Iron Arbalest", "A heavy crossbow drawn with a windlass. Worth the wait.", NayrCrossbow(Tint.iron)},
	{42, "weapon_ranged_steel_crossbow", "Steel Crossbow", "A steel-prodded crossbow of the town watch.", NayrCrossbow(Tint.steel)},
	{52, "weapon_ranged_steel_arbalest", "Steel Arbalest", "A siege crossbow cut down for the hand. It cracks shields.", NayrCrossbow(Tint.steel)},
	{62, "weapon_ranged_silver_crossbow", "Silver Crossbow", "Silver fittings on a black stock. A noble's weapon for the hunt.", NayrCrossbow(Tint.silver)},
	{72, "weapon_ranged_silver_arbalest", "Silver Arbalest", "A silvered arbalest of the Hallowgate honour guard.", NayrCrossbow(Tint.silver)},
	{82, "weapon_ranged_glass_crossbow", "Glass Crossbow", "A prod of green glass that never loses its spring.", NayrCrossbow(Tint.glass)},
	{92, "weapon_ranged_glass_arbalest", "Glass Arbalest", "Glass laminated over steel. The bolt leaves before you hear it.", NayrCrossbow(Tint.glass)},
	{102, "weapon_ranged_ebony_crossbow", "Ebony Crossbow", "Black and heavy. It is aimed once and remembered long.", NayrCrossbow(Tint.ebony)},
	{112, "weapon_ranged_ebony_arbalest", "Ebony Arbalest", "An ebony arbalest that only a winch can draw.", NayrCrossbow(Tint.ebony)},
	{122, "weapon_ranged_gravensteel_crossbow", "Gravensteel Crossbow", "Gravensteel prod, wall-oak stock. Made to hold a gate alone.", NayrCrossbow(Tint.graven)},
	{132, "weapon_ranged_gravensteel_arbalest", "Gravensteel Arbalest", "The great crossbow of the Gravenmark towers.", NayrCrossbow(Tint.graven)},
	{142, "weapon_ranged_dreadforged_arbalest", "Dreadforged Arbalest", "Its bolts are never found again, and neither is what they hit.", NayrCrossbow(Tint.dread)},
}

for strClass, tblLadder in pairs(Ladders) do
	local Class = GM.WeaponClasses[strClass]
	for _, Entry in ipairs(tblLadder) do
		local intLevel = Entry[1]
		local Item = QuickCreateItemTable(BaseWeapon, Entry[2], Entry[3], Entry[4], Icons[strClass])
		Item.Model = Entry[5]
		Item.WeaponClass = strClass
		Item.Level = intLevel
		Item.Power = GM:GetWeaponTierPower(strClass, intLevel)
		Item.FireRate = Class.FireRate
		Item.HoldType = Class.HoldType
		Item.Melee = Class.AmmoType == nil
		Item.Range = Class.Range
		Item.CritBonus = Class.CritBonus
		Item.Sound = Class.Sound or Sound
		if Class.AmmoType then
			Item.AmmoType = Class.AmmoType
			Item.ClipSize = Class.ClipSize
			Item.ReloadTime = Class.ReloadTime
			Item.Accuracy = Class.Accuracy
			Item.ReloadSound = Class.ReloadSound
		end
		Item.Weight = Entry[6] or Weights[strClass]
		Item.SellPrice = GM:GetGearPrice(intLevel)
		Item.Crafted = true
		Register.Item(Item)
	end
end

local function Ammo(strName, strPrintName, strDesc, strAmmoType, intAmount, intPrice, clrTint)
	local Item = QuickCreateItemTable(BaseAmmo, strName, strPrintName, strDesc, "icons/item_rifleammo")
	Item.AmmoType = strAmmoType
	Item.AmmoAmount = intAmount
	Item.Model = {{Model = "models/items/crossbowrounds.mdl", Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0), Color = clrTint}}
	Item.Stackable = true
	Item.Weight = 0.2
	Item.SellPrice = intPrice
	Register.Item(Item)
end

Ammo("item_arrows", "Bundle of Arrows", "Twenty goose-fletched arrows with iron bodkin heads. Use it to fill your quiver.", "ud_arrow", 20, 4, Tint.rust)
Ammo("item_bolts", "Bundle of Bolts", "Fifteen short, heavy crossbow bolts. Use it to fill your bolt case.", "ud_bolt", 15, 5)
