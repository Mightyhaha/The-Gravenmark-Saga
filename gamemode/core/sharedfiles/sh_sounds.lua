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

function GM:IsArmedTarget(entTarget)
	if not IsValid(entTarget) then return false end
	if entTarget:IsPlayer() then return true end
	if not entTarget:IsNPC() then return false end
	local tblNPC = NPCTable(entTarget:GetNWString("npc", ""))
	return tblNPC ~= nil and istable(tblNPC.HeldItems) and #tblNPC.HeldItems > 0
end

function GM:PlayClashSound(tblWeapon, trcTrace)
	if not tblWeapon or not tblWeapon.Melee or not trcTrace or not self:IsArmedTarget(trcTrace.Entity) then return end
	local tblSounds = self.ClashSounds[self.ClashSoundGroups[tblWeapon.WeaponClass or ""] or "sword"]
	if not tblSounds or #tblSounds == 0 then return end
	sound.Play(tblSounds[math.random(#tblSounds)], trcTrace.HitPos, 75, math.random(94, 106), 1)
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
