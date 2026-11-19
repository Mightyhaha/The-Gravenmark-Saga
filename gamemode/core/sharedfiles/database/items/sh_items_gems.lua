local GemModel = "models/props_junk/rock001a.mdl"

local function UseGem(self, ply, tblItem)
	if CLIENT or not IsValid(ply) then return end
	for _, Target in ipairs(GAMEMODE:GetSocketTargets(ply)) do
		local tblTarget = ItemTable(Target.Item)
		if Target.Worn and tblTarget and tblTarget.Slot == "slot_primaryweapon" then return ply:SocketGem(tblItem.Name, Target.Item) end
	end
	for _, Target in ipairs(GAMEMODE:GetSocketTargets(ply)) do
		if Target.Worn then return ply:SocketGem(tblItem.Name, Target.Item) end
	end
	ply:ChatPrint("Nothing you are wearing has a free socket. Right-click the gem to pick an item from your pack.")
end

for intGrade, strGrade in ipairs(GM.GemGrades) do
	local intLevel = GM:GetGemLevel(intGrade)
	for _, Kind in ipairs(GM.GemKinds) do
		local intAmount = GM:GetAffixStat(Kind.Stat, intLevel, GM.Gems.Budget)
		local strDesc = "A " .. string.lower(strGrade) .. " " .. string.lower(Kind.PrintName) .. ". Set into a weapon or armor with a free socket for +" .. intAmount .. " " .. Kind.StatName .. ". Double-click to set it into your worn gear, or right-click to choose."
		local Item = QuickCreateItemTable(BaseItem, GM:GetGemName(Kind.Key, intGrade), strGrade .. " " .. Kind.PrintName, strDesc, "icons/junk_cog")
		Item.Model = {{Model = GemModel, Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0), Color = Kind.Color, Material = "models/shiny", Scale = Vector(0.35, 0.35, 0.35)}}
		Item.Stackable = true
		Item.Weight = 0.1
		Item.Level = intLevel
		Item.GemKind = Kind.Key
		Item.GemGrade = intGrade
		Item.GemBuffs = {[Kind.Stat] = intAmount}
		Item.SellPrice = math.max(math.Round(GM:GetGearPrice(intLevel) * 0.15), 5)
		Item.Use = UseGem
		Register.Item(Item)
	end
end
