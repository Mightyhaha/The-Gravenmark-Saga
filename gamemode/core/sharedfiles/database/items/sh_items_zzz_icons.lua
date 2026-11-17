GM.GeneratedIconFolder = "gravenmark_icons"

function GM:ApplyGeneratedIcons()
	for strName, tblItem in pairs(self.DataBase.Items) do
		local strContent = "icons/gen/" .. strName .. ".png"
		local strData = self.GeneratedIconFolder .. "/" .. strName .. ".png"
		if file.Exists("materials/" .. strContent, "GAME") then
			tblItem.Icon = strContent
		elseif CLIENT and file.Exists(strData, "DATA") then
			tblItem.Icon = "../data/" .. strData
		end
	end
end

GM:ApplyGeneratedIcons()
