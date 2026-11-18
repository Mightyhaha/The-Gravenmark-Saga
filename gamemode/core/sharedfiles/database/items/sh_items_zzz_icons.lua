GM.GeneratedIconFolder = "gravenmark_icons"

function GM:ApplyGeneratedIcons()
	for strName, tblItem in pairs(self.DataBase.Items) do
		for _, strIconName in ipairs({strName, tblItem.BaseItem}) do
			local strContent = "icons/gen/" .. strIconName .. ".png"
			local strData = self.GeneratedIconFolder .. "/" .. strIconName .. ".png"
			if file.Exists("materials/" .. strContent, "GAME") then
				tblItem.Icon = strContent
				break
			elseif CLIENT and file.Exists(strData, "DATA") then
				tblItem.Icon = "../data/" .. strData
				break
			end
		end
	end
end

GM:ApplyGeneratedIcons()
