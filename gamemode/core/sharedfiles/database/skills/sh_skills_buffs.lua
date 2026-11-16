RegisterBuff({
	Name = "buff_bloodrush",
	PrintName = "Bloodrush",
	Icon = "icon16/fire.png",
	Category = "combat",
	Duration = 8,
	Desc = function(Power) return Power .. "% more melee damage" end,
	Hooks = {
		damage_mod = function(ply, Power, Damage)
			if ply:IsMelee() then Damage = Damage * (1 + Power / 100) end
			return Damage
		end,
	},
})

RegisterBuff({
	Name = "buff_huntersfocus",
	PrintName = "Hunter's Focus",
	Icon = "icon16/star.png",
	Category = "combat",
	Duration = 8,
	Desc = function(Power) return Power .. "% more ranged damage" end,
	Hooks = {
		damage_mod = function(ply, Power, Damage)
			if not ply:IsMelee() then Damage = Damage * (1 + Power / 100) end
			return Damage
		end,
	},
})

RegisterBuff({
	Name = "buff_skirmisher",
	PrintName = "Skirmisher",
	Icon = "icon16/weather_lightning.png",
	Category = "combat",
	Duration = 4,
	MoveSpeed = 1,
	Desc = function(Power) return "+" .. Power .. " movement speed" end,
})

RegisterBuff({
	Name = "buff_riposte",
	PrintName = "Riposte",
	Icon = "icon16/cut.png",
	Category = "combat",
	Duration = 3,
	Desc = function(Power) return "Next melee hit deals " .. Power .. "% more damage" end,
})

RegisterBuff({
	Name = "buff_secondwind",
	PrintName = "Second Wind",
	Icon = "icon16/heart_add.png",
	Category = "combat",
	Duration = 6,
	Desc = function(Power) return "Recovering " .. Power .. "% health every second" end,
	Think = function(self, ply, Power)
		ply:HealPercent(Power)
	end,
})

RegisterBuff({
	Name = "buff_laststand",
	PrintName = "Last Stand",
	Icon = "icon16/exclamation.png",
	Category = "combat",
	Duration = 5,
	Desc = function() return "Taking half damage" end,
	Hooks = {
		damage_taken_mod = function(ply, Power, Damage, entAttacker)
			if Damage then Damage = Damage * 0.5 end
			return Damage, entAttacker
		end,
	},
})

RegisterBuff({
	Name = "buff_rallied",
	PrintName = "Rallied",
	Icon = "icon16/bell.png",
	Category = "aura",
	Duration = 4,
	Stats = {stat_strength = 1, stat_dexterity = 1},
	Desc = function(Power) return "+" .. Power .. " Strength and Dexterity" end,
})

RegisterBuff({
	Name = "buff_shieldbrothers",
	PrintName = "Shield-Brothers",
	Icon = "icon16/group.png",
	Category = "aura",
	Duration = 4,
	Desc = function(Power) return Power .. "% less damage taken" end,
	Hooks = {
		damage_taken_mod = function(ply, Power, Damage, entAttacker)
			if Damage then Damage = Damage * (1 - Power / 100) end
			return Damage, entAttacker
		end,
	},
})

RegisterBuff({
	Name = "buff_warbanner",
	PrintName = "War Banner",
	Icon = "icon16/transmit.png",
	Category = "combat",
	Duration = 6,
	Desc = function(Power) return Power .. "% more damage" end,
	Hooks = {
		damage_mod = function(ply, Power, Damage)
			return Damage * (1 + Power / 100)
		end,
	},
})
