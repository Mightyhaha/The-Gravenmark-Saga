for _, Item in pairs(GM.DataBase.Items) do
	local intUnlock = Item.Slot and GM.SlotUnlockLevel[Item.Slot]
	if intUnlock and (Item.Level or 1) < intUnlock then Item.Level = intUnlock end
end
