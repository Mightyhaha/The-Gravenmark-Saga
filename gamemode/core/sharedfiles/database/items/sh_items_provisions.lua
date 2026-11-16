GM.ProvisionDrops = {"food_ryebread", "food_trailrations", "food_trout", "food_porridge"}

local function PercentOfMaxHealth(flPercent)
	return function(ply)
		return {stat_maxhealth = math.Round(ply:GetMaximumHealth() * flPercent / 100)}
	end
end

local function DamageBonus(flPercent, strKind)
	return function(ply, Power, Damage)
		local boolMelee = ply:IsMelee()
		if strKind == "all" or (strKind == "melee" and boolMelee) or (strKind == "ranged" and not boolMelee) then
			Damage = Damage * (1 + flPercent / 100)
		end
		return Damage
	end
end

local function DamageTaken(flPercent)
	return function(ply, Power, Damage, entAttacker)
		if Damage then Damage = Damage * (1 + flPercent / 100) end
		return Damage, entAttacker
	end
end

local function ExpBonus(flPercent)
	return function(ply, Power, Amount)
		return Amount * (1 + flPercent / 100)
	end
end

RegisterBuff({Name = "food_buff_wellfed", PrintName = "Well Fed", Icon = "icon16/cake.png", Category = "food", Duration = 900, KeepOnDeath = true,
	Desc = function() return "8% more max health" end,
	Stats = PercentOfMaxHealth(8),
})

RegisterBuff({Name = "food_buff_porridge", PrintName = "Warm Porridge", Icon = "icons/junk_pan1", Category = "food", Duration = 900, KeepOnDeath = true,
	Desc = function() return "Recover 1% health every 4 seconds" end,
	Think = function(self, ply)
		if (ply.UD_NextPorridge or 0) > CurTime() then return end
		ply.UD_NextPorridge = CurTime() + 4
		ply:HealPercent(1)
	end,
})

RegisterBuff({Name = "food_buff_steadyhands", PrintName = "Steady Hands", Icon = "icon16/water.png", Category = "food", Duration = 1200, KeepOnDeath = true,
	Desc = function() return "6% more ranged damage" end,
	Hooks = {damage_mod = DamageBonus(6, "ranged")},
})

RegisterBuff({Name = "food_buff_hearty", PrintName = "Hearty", Icon = "icons/junk_pan2", Category = "food", Duration = 1200, KeepOnDeath = true,
	Desc = function() return "6% more melee damage and 5% more max health" end,
	Stats = PercentOfMaxHealth(5),
	Hooks = {damage_mod = DamageBonus(6, "melee")},
})

RegisterBuff({Name = "food_buff_sweetenergy", PrintName = "Sweet Energy", Icon = "icon16/ruby.png", Category = "food", Duration = 600, KeepOnDeath = true,
	Desc = function() return "+25 movement speed" end,
	MoveSpeed = 25,
})

RegisterBuff({Name = "food_buff_liquidcourage", PrintName = "Liquid Courage", Icon = "icons/item_beer", Category = "food", Duration = 600, KeepOnDeath = true,
	Desc = function() return "10% more melee damage, but 5% more damage taken" end,
	Hooks = {damage_mod = DamageBonus(10, "melee"), damage_taken_mod = DamageTaken(5)},
})

RegisterBuff({Name = "food_buff_goodspirits", PrintName = "Good Spirits", Icon = "icon16/drink.png", Category = "food", Duration = 900, KeepOnDeath = true,
	Desc = function() return "6% more experience" end,
	Hooks = {exp_mod = ExpBonus(6)},
})

RegisterBuff({Name = "food_buff_refreshed", PrintName = "Refreshed", Icon = "icons/food_orange", Category = "food", Duration = 600, KeepOnDeath = true,
	Desc = function() return "5% less damage taken" end,
	Hooks = {damage_taken_mod = DamageTaken(-5)},
})

RegisterBuff({Name = "food_buff_provisioned", PrintName = "Provisioned", Icon = "icon16/package.png", Category = "food", Duration = 1800, KeepOnDeath = true,
	Desc = function() return "4% more max health and +3 max weight" end,
	Stats = function(ply)
		return {stat_maxhealth = math.Round(ply:GetMaximumHealth() * 0.04), stat_maxweight = 3}
	end,
})

RegisterBuff({Name = "food_buff_feast", PrintName = "Captain's Feast", Icon = "icon16/cup.png", Category = "food", Duration = 1800, KeepOnDeath = true,
	Desc = function() return "5% more damage, 10% more max health and 5% more experience" end,
	Stats = PercentOfMaxHealth(10),
	Hooks = {damage_mod = DamageBonus(5, "all"), exp_mod = ExpBonus(5)},
})

BaseProvision = DeriveTable(BaseFood)
BaseProvision.HealPercent = 10
BaseProvision.AddTime = 6
BaseProvision.Stackable = true
BaseProvision.Weight = 1
BaseProvision.UseSound = "vo/SandwichEat09.wav"
function BaseProvision:Use(usr, itemtable)
	if not IsValid(usr) or not usr:Alive() or usr.UD_Resting then return end
	local intMax = usr:GetMaximumHealth()
	if usr:Health() >= intMax and not itemtable.FoodBuff then return end
	usr:AddItem(itemtable.Name, -1)
	if itemtable.Message then usr:CreateNotification(itemtable.Message) end
	if itemtable.UseSound then usr:EmitSound(itemtable.UseSound) end
	if itemtable.FoodBuff then usr:AddBuff(itemtable.FoodBuff) end
	local intHeal = math.Round(usr:CallSkillHook("food_mod", intMax * (itemtable.HealPercent or 0) / 100) or 0)
	if intHeal <= 0 then return end
	local intSteps = math.Clamp(intHeal, 1, 20)
	local intStep, intGiven = 0, 0
	timer.Create("UD_Eat_" .. usr:EntIndex() .. "_" .. itemtable.Name, (itemtable.AddTime or 6) / intSteps, intSteps, function()
		if not IsValid(usr) or not usr:Alive() then return end
		intStep = intStep + 1
		local intTarget = math.Round(intHeal * intStep / intSteps)
		local intAmount = intTarget - intGiven
		intGiven = intTarget
		usr:SetHealth(math.min(usr:Health() + intAmount, usr:GetMaximumHealth()))
	end)
end

local function Provision(strName, strPrintName, strDesc, strIcon, strModel, intHealPercent, intAddTime, strBuff, intSellPrice, strMessage, strSound)
	local Item = QuickCreateItemTable(BaseProvision, strName, strPrintName, strDesc, strIcon)
	Item.Model = strModel
	Item.HealPercent = intHealPercent
	Item.AddTime = intAddTime
	Item.FoodBuff = strBuff
	Item.SellPrice = intSellPrice
	Item.Message = strMessage
	if strSound then Item.UseSound = strSound end
	Register.Item(Item)
	return Item
end

Provision("food_ryebread", "Rye Bread", "Dense Dunmarrow bread. Heals 15% over 6 seconds. Well Fed: 8% more max health for 15 minutes.", "icon16/cake.png", "models/props_phx/misc/potato.mdl", 15, 6, "food_buff_wellfed", 4, "You eat the rye bread")
Provision("food_porridge", "Barley Porridge", "Still warm in its clay pot. Heals 10% over 6 seconds. Warm Porridge: recover 1% health every 4 seconds for 15 minutes.", "icons/junk_pan1", "models/props_junk/terracotta01.mdl", 10, 6, "food_buff_porridge", 5, "You eat the porridge")
Provision("food_trailrations", "Trail Rations", "Dried meat, hard cheese and oat cakes. Heals 10% over 8 seconds. Provisioned: 4% more max health and +3 max weight for 30 minutes.", "icon16/package.png", "models/props_junk/garbage_bag001a.mdl", 10, 8, "food_buff_provisioned", 6, "You chew through the rations")
Provision("food_trout", "Smoked River Trout", "Caught in the streams below Bremergard. Heals 20% over 6 seconds. Steady Hands: 6% more ranged damage for 20 minutes.", "icon16/water.png", "models/props/de_inferno/goldfish.mdl", 20, 6, "food_buff_steadyhands", 8, "You eat the smoked trout")
Provision("food_melon", "Summer Melon", "Sweet and cold. Heals 25% over 8 seconds. Refreshed: 5% less damage taken for 10 minutes.", "icons/food_orange", "models/props_junk/watermelon01.mdl", 25, 8, "food_buff_refreshed", 8, "You eat the melon")
Provision("food_honey", "Jar of Forest Honey", "Wild honey from the Bremergard hives. Heals 10% over 4 seconds. Sweet Energy: +25 movement speed for 10 minutes.", "icon16/ruby.png", "models/props_lab/jar01a.mdl", 10, 4, "food_buff_sweetenergy", 10, "You eat the honey")
Provision("food_ale", "Dunmarrow Ale", "Brewed for rebels, by rebels. Heals 5% over 4 seconds. Liquid Courage: 10% more melee damage but 5% more damage taken for 10 minutes.", "icons/item_beer", "models/props_junk/garbage_glassbottle001a.mdl", 5, 4, "food_buff_liquidcourage", 6, "You drink the ale", "npc/barnacle/barnacle_gulp1.wav")
Provision("food_stew", "Hunter's Stew", "Venison, roots and barley, cooked all day. Heals 30% over 8 seconds. Hearty: 6% more melee damage and 5% more max health for 20 minutes.", "icons/junk_pan2", "models/props_interiors/pot01a.mdl", 30, 8, "food_buff_hearty", 14, "You eat the stew")
Provision("food_wine", "Kaelmoor Red", "Smuggled across the border in false-bottomed carts. Heals 5% over 4 seconds. Good Spirits: 6% more experience for 15 minutes.", "icon16/drink.png", "models/props_junk/glassbottle01a.mdl", 5, 4, "food_buff_goodspirits", 25, "You drink the wine", "npc/barnacle/barnacle_gulp2.wav")
Provision("food_feast", "Captain's Feast", "A whole platter from an officer's table. Heals 50% over 10 seconds. Captain's Feast: 5% more damage, 10% more max health and 5% more experience for 30 minutes.", "icon16/cup.png", "models/props_c17/metalpot002a.mdl", 50, 10, "food_buff_feast", 60, "You eat like a captain")
Provision("food_herbaldraught", "Herbal Draught", "Bitter, but it closes wounds. Heals 35% over 4 seconds.", "icons/item_antivirus", "models/pickups/healthpotion/healthpotion.mdl", 35, 4, nil, 12, "You drink the draught", "items/smallmedkit1.wav")

local Item = QuickCreateItemTable(BaseItem, "item_bedroll", "Wayfarer's Bedroll", "Roll it out somewhere safe and sleep for a while. Grants Rested: 25% more experience for 30 minutes. Sleeping in a real bed lasts longer. Cannot be used near enemies.", "icon16/house.png")
Item.Model = "models/skyrimznalecc/bedroll01.mdl"
Item.Weight = 3
Item.SellPrice = 40
function Item:Use(usr, itemtable)
	if IsValid(usr) then usr:StartRest(1) end
end
Register.Item(Item)
