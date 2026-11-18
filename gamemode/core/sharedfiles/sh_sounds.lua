GM.ClashSoundFolder = "gravenmark/clash"
GM.ClashSoundGroups = {sword = "sword", axe = "axe", spear = "spear", hammer = "mace"}
GM.ClashSounds = {}

for _, strGroup in pairs(GM.ClashSoundGroups) do
	if not GM.ClashSounds[strGroup] then
		local tblFiles = {}
		for _, strFile in ipairs(file.Find("sound/" .. GM.ClashSoundFolder .. "/" .. strGroup .. "_*.wav", "GAME")) do
			table.insert(tblFiles, GM.ClashSoundFolder .. "/" .. strFile)
		end
		GM.ClashSounds[strGroup] = tblFiles
	end
end

GM.SwingSoundFolder = "gravenmark/swing"
GM.SwingFallback = {"npc/zombie/claw_miss1.wav", "npc/zombie/claw_miss2.wav", "npc/vort/claw_swing1.wav", "npc/vort/claw_swing2.wav"}
GM.SwingPitch = {sword = {100, 112}, axe = {88, 98}, spear = {104, 116}, hammer = {74, 84}}
GM.SwingSounds = {}

for strClass in pairs(GM.SwingPitch) do
	local tblFiles = {}
	for _, strFile in ipairs(file.Find("sound/" .. GM.SwingSoundFolder .. "/" .. strClass .. "_*.wav", "GAME")) do
		table.insert(tblFiles, GM.SwingSoundFolder .. "/" .. strFile)
	end
	for _, strFile in ipairs(file.Find("sound/" .. GM.SwingSoundFolder .. "/" .. strClass .. "_*.ogg", "GAME")) do
		table.insert(tblFiles, GM.SwingSoundFolder .. "/" .. strFile)
	end
	GM.SwingSounds[strClass] = tblFiles
end

function GM:PlaySwingSound(entWeapon, tblWeapon)
	if not IsValid(entWeapon) or not tblWeapon then return false end
	if not tblWeapon.Melee or not self.SwingPitch[tblWeapon.WeaponClass or ""] then return false end
	local strClass = tblWeapon.WeaponClass
	local tblOwn = self.SwingSounds[strClass]
	local tblPitch = self.SwingPitch[strClass]
	if tblOwn and #tblOwn > 0 then
		entWeapon:EmitSound(tblOwn[math.random(#tblOwn)], 70, math.random(96, 104), 1, CHAN_WEAPON)
	else
		entWeapon:EmitSound(self.SwingFallback[math.random(#self.SwingFallback)], 70, math.random(tblPitch[1], tblPitch[2]), 0.8, CHAN_WEAPON)
	end
	return true
end

function GM:IsArmedTarget(entTarget)
	if not IsValid(entTarget) then return false end
	if entTarget:IsPlayer() then return true end
	if not entTarget:IsNPC() then return false end
	if IsValid(entTarget:GetActiveWeapon()) then return true end
	local tblNPC = NPCTable(entTarget:GetNWString("npc", ""))
	if not tblNPC then return false end
	return (istable(tblNPC.HeldItems) and #tblNPC.HeldItems > 0) or (tblNPC.Weapon ~= nil and tblNPC.Weapon ~= "")
end

if SERVER then
	concommand.Add("UD_Dev_ClashTest", function(ply, cmd, args)
		for strGroup, tblFiles in SortedPairs(GAMEMODE.ClashSounds) do
			print("[Clash] " .. strGroup .. ": " .. #tblFiles .. " sounds" .. (tblFiles[1] and (", e.g. " .. tblFiles[1]) or ""))
		end
		local tblFiles = GAMEMODE.ClashSounds[args[1] or "sword"] or {}
		if IsValid(ply) and tblFiles[1] then
			sound.Play(tblFiles[math.random(#tblFiles)], ply:GetPos() + ply:GetForward() * 40, 75, 100, 1)
		end
	end)
end

GM.ClashShare = 0.4
GM.BodyHitSounds = {"physics/flesh/flesh_impact_hard1.wav", "physics/flesh/flesh_impact_hard2.wav", "physics/flesh/flesh_impact_hard3.wav", "physics/flesh/flesh_impact_hard4.wav", "physics/flesh/flesh_impact_hard5.wav", "physics/flesh/flesh_impact_hard6.wav"}
GM.BodyHitPitch = {sword = {100, 110}, axe = {88, 96}, spear = {104, 114}, hammer = {72, 82}}

function GM:PlayClashSound(tblWeapon, trcTrace)
	if not tblWeapon or not tblWeapon.Melee or not trcTrace then return end
	local entTarget = trcTrace.Entity
	if not IsValid(entTarget) or not (entTarget:IsPlayer() or entTarget:IsNPC()) then return end
	local tblSounds = self.ClashSounds[self.ClashSoundGroups[tblWeapon.WeaponClass or ""] or "sword"]
	if self:IsArmedTarget(entTarget) and tblSounds and #tblSounds > 0 and math.random() < self.ClashShare then
		sound.Play(tblSounds[math.random(#tblSounds)], trcTrace.HitPos, 75, math.random(94, 106), 1)
		return
	end
	local tblPitch = self.BodyHitPitch[tblWeapon.WeaponClass or ""] or self.BodyHitPitch.sword
	sound.Play(self.BodyHitSounds[math.random(#self.BodyHitSounds)], trcTrace.HitPos, 75, math.random(tblPitch[1], tblPitch[2]), 1)
end

GM.VoiceFolder = "gravenmark/voice"
GM.Voices = {"hero", "dwarf", "keeper_groan", "keeper_neutral"}
GM.VoiceLines = {"greeting", "objectivenew", "objectivemet", "objectivefailed", "victory", "defeat", "enemydefeated", "allydefeated", "underattack"}
GM.VoiceCooldown = 4
GM.VoiceSounds = {}

for _, strVoice in ipairs(GM.Voices) do
	GM.VoiceSounds[strVoice] = {}
	for _, strLine in ipairs(GM.VoiceLines) do
		local tblFiles = {}
		for _, strFile in ipairs(file.Find("sound/" .. GM.VoiceFolder .. "/" .. strVoice .. "/" .. strLine .. "_*.ogg", "GAME")) do
			table.insert(tblFiles, GM.VoiceFolder .. "/" .. strVoice .. "/" .. strFile)
		end
		GM.VoiceSounds[strVoice][strLine] = tblFiles
	end
end

function GM:GetNPCVoice(strNPC)
	local tblNPC = NPCTable(strNPC or "")
	if not tblNPC or tblNPC.Voice == false then return nil end
	if tblNPC.Voice then return tblNPC.Voice end
	if string.find(string.lower(tblNPC.Model or ""), "female", 1, true) then return nil end
	return self.Voices[tonumber(util.CRC(strNPC)) % #self.Voices + 1]
end

function GM:PlayNPCVoice(entNPC, strLine)
	if CLIENT or not IsValid(entNPC) then return end
	if (entNPC.UD_NextVoice or 0) > CurTime() then return end
	local strVoice = self:GetNPCVoice(entNPC:GetNWString("npc", ""))
	local tblLines = strVoice and self.VoiceSounds[strVoice] and self.VoiceSounds[strVoice][strLine]
	if not tblLines or #tblLines == 0 then return end
	entNPC.UD_NextVoice = CurTime() + self.VoiceCooldown
	entNPC:EmitSound(tblLines[math.random(#tblLines)], 72, 100, 1, CHAN_VOICE)
end
