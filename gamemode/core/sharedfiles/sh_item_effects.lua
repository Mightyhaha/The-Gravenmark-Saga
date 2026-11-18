GM.ItemEffectTypes = {
	{Key = "glow", PrintName = "Glow", Desc = "A pulsing coloured sheen over the whole item"},
	{Key = "embers", PrintName = "Embers", Desc = "Glowing motes that drift up off the item"},
	{Key = "smoke", PrintName = "Smoke", Desc = "Thin smoke curling off the item"},
	{Key = "sparkle", PrintName = "Sparkles", Desc = "Short twinkles along the item"},
	{Key = "light", PrintName = "Light", Desc = "The item lights up its surroundings"},
}

GM.ItemEffectDefaults = {
	glow = Color(255, 90, 40),
	embers = Color(255, 140, 50),
	smoke = Color(70, 60, 60),
	sparkle = Color(200, 230, 255),
	light = Color(255, 120, 60),
}

function GM:NewItemEffect(strType)
	return {Type = strType, Color = Color(self.ItemEffectDefaults[strType].r, self.ItemEffectDefaults[strType].g, self.ItemEffectDefaults[strType].b), Size = 1, Amount = 1, Pulse = 1}
end

if SERVER then return end

local GlowMaterial = CreateMaterial("ud_item_fx_glow", "VertexLitGeneric", {
	["$basetexture"] = "models/debug/debugwhite",
	["$additive"] = "1",
	["$selfillum"] = "1",
	["$model"] = "1",
})

local Sprites = {
	embers = "sprites/light_glow02_add",
	smoke = "particle/particle_smokegrenade",
	sparkle = "sprites/glow04_noz",
}

local Tracked = {}
local Emitter
local LightIndex = 0

local function RootEffects(entRoot)
	local tblItem = IsValid(entRoot) and entRoot.Item and ItemTable(entRoot.Item)
	return tblItem and tblItem.Effects
end

local function PulseOf(Effect, intIndex)
	local flSpeed = Effect.Pulse or 1
	if flSpeed <= 0 then return 1 end
	return 0.75 + 0.25 * math.sin(CurTime() * 3 * flSpeed + intIndex)
end

local function PartTransform(entPart)
	if entPart.UD_BoneMerged or entPart:IsEffectActive(EF_BONEMERGE) then
		entPart:SetupBones()
		local matBone = entPart:GetBoneMatrix(0)
		if matBone then return matBone:GetTranslation(), matBone:GetAngles() end
	end
	return entPart:GetPos(), entPart:GetAngles()
end

local function RandomPoint(tblParts)
	local entPart = tblParts[math.random(#tblParts)]
	local vecMin, vecMax = entPart:GetModelBounds()
	local vecScale = entPart.UD_Scale
	local vecLocal = Vector(math.Rand(vecMin.x, vecMax.x), math.Rand(vecMin.y, vecMax.y), math.Rand(vecMin.z, vecMax.z))
	if vecScale then vecLocal = Vector(vecLocal.x * vecScale.x, vecLocal.y * vecScale.y, vecLocal.z * vecScale.z) end
	local vecPos, angAng = PartTransform(entPart)
	return LocalToWorld(vecLocal, Angle(0, 0, 0), vecPos, angAng)
end

local function PartsOf(entRoot)
	local tblParts = {entRoot}
	for _, entKid in ipairs(entRoot.Children or {}) do
		if IsValid(entKid) then table.insert(tblParts, entKid) end
	end
	return tblParts
end

local function DrawGlow(tblParts, Effect, intIndex)
	local Col = Effect.Color or color_white
	local flStrength = math.Clamp(0.35 * (Effect.Size or 1) * PulseOf(Effect, intIndex), 0, 1)
	render.MaterialOverride(GlowMaterial)
	render.SetColorModulation(Col.r / 255 * flStrength, Col.g / 255 * flStrength, Col.b / 255 * flStrength)
	for _, entPart in ipairs(tblParts) do entPart:DrawModel() end
	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride(nil)
end

hook.Add("PostDrawOpaqueRenderables", "UD_ItemEffectsGlow", function(bDepth, bSkybox)
	if bDepth or bSkybox then return end
	for entRoot in pairs(Tracked) do
		if IsValid(entRoot) and not entRoot:GetNoDraw() then
			local tblEffects = RootEffects(entRoot)
			if tblEffects then
				local tblParts
				for intIndex, Effect in ipairs(tblEffects) do
					if Effect.Type == "glow" then
						tblParts = tblParts or PartsOf(entRoot)
						DrawGlow(tblParts, Effect, intIndex)
					end
				end
			end
		end
	end
end)

function GM:AttachItemEffects(entRoot)
	if not IsValid(entRoot) then return end
	if not entRoot.UD_FxLight then
		LightIndex = LightIndex % 400 + 1
		entRoot.UD_FxLight = 4000 + LightIndex * 8
	end
	Tracked[entRoot] = true
end

local function SpawnParticle(strType, vecPos, Effect)
	Emitter = Emitter or ParticleEmitter(vecPos)
	if not Emitter then return end
	Emitter:SetPos(vecPos)
	local Particle = Emitter:Add(Sprites[strType], vecPos)
	if not Particle then return end
	local Col = Effect.Color or color_white
	local flSize = Effect.Size or 1
	Particle:SetColor(Col.r, Col.g, Col.b)
	Particle:SetRoll(math.Rand(0, 360))
	if strType == "embers" then
		Particle:SetVelocity(VectorRand() * 3 + Vector(0, 0, math.Rand(8, 18) * flSize))
		Particle:SetDieTime(math.Rand(0.6, 1.3))
		Particle:SetStartSize(math.Rand(1, 2) * flSize)
		Particle:SetEndSize(0)
		Particle:SetStartAlpha(255)
		Particle:SetEndAlpha(0)
		Particle:SetAirResistance(30)
		Particle:SetGravity(Vector(0, 0, 10))
	elseif strType == "smoke" then
		Particle:SetVelocity(VectorRand() * 2 + Vector(0, 0, math.Rand(6, 12)))
		Particle:SetDieTime(math.Rand(1.2, 2.2))
		Particle:SetStartSize(math.Rand(1.5, 3) * flSize)
		Particle:SetEndSize(math.Rand(5, 8) * flSize)
		Particle:SetStartAlpha(70)
		Particle:SetEndAlpha(0)
		Particle:SetRollDelta(math.Rand(-1, 1))
		Particle:SetAirResistance(40)
	else
		Particle:SetVelocity(Vector(0, 0, 0))
		Particle:SetDieTime(math.Rand(0.2, 0.45))
		Particle:SetStartSize(0)
		Particle:SetEndSize(math.Rand(2, 4) * flSize)
		Particle:SetStartAlpha(255)
		Particle:SetEndAlpha(0)
	end
end

local Rates = {embers = 14, smoke = 6, sparkle = 8}

hook.Add("Think", "UD_ItemEffects", function()
	local flDelta = FrameTime()
	for entRoot in pairs(Tracked) do
		if not IsValid(entRoot) then
			Tracked[entRoot] = nil
		elseif not entRoot:GetNoDraw() then
			local tblEffects = RootEffects(entRoot)
			if tblEffects and #tblEffects > 0 then
				local tblParts = PartsOf(entRoot)
				entRoot.UD_FxAcc = entRoot.UD_FxAcc or {}
				for intIndex, Effect in ipairs(tblEffects) do
					if Rates[Effect.Type] then
						local flAcc = (entRoot.UD_FxAcc[intIndex] or 0) + flDelta * Rates[Effect.Type] * (Effect.Amount or 1)
						local intSpawn = math.min(math.floor(flAcc), 10)
						entRoot.UD_FxAcc[intIndex] = flAcc - math.floor(flAcc)
						for _ = 1, intSpawn do SpawnParticle(Effect.Type, RandomPoint(tblParts), Effect) end
					elseif Effect.Type == "light" then
						local Light = DynamicLight(entRoot.UD_FxLight + intIndex)
						if Light then
							local Col = Effect.Color or color_white
							local vecPos = PartTransform(entRoot)
							Light.pos = vecPos
							Light.r, Light.g, Light.b = Col.r, Col.g, Col.b
							Light.brightness = 1.5 * (Effect.Amount or 1) * PulseOf(Effect, intIndex)
							Light.size = 90 * (Effect.Size or 1)
							Light.decay = 1000
							Light.dietime = CurTime() + 0.1
						end
					end
				end
			end
		end
	end
end)
