local InfoRangeSqr = 200 ^ 2

local function SetItemHidden(ent, Hidden)
	if ent.UD_Hidden == Hidden then return end
	ent.UD_Hidden = Hidden
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetColor(Color(255, 255, 255, Hidden and 0 or 255))
end

local function DrawItemInfo()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local PlyPos = ply:GetPos()

	for _, ent in ipairs(UD_EntCache.Items) do
		if IsValid(ent) and ent:GetPos():DistToSqr(PlyPos) < InfoRangeSqr then
			local Owner = ent:GetOwner()
			if Owner == ply or not IsValid(Owner) or ply:IsInSquad(Owner) then
				SetItemHidden(ent, false)
				local EntPos = (ent:GetPos() + Vector(0, 0, 10)):ToScreen()
				local Text = ent:GetNWString("PrintName")
				local Amount = ent:GetNWInt("Amount")
				if Amount > 1 then Text = Text .. " x" .. Amount end
				draw.SimpleTextOutlined(Text, "UiBold", EntPos.x, EntPos.y - 10, White, 1, 1, 1, DrakGray)
			else
				SetItemHidden(ent, true)
			end
		end
	end

	for _, ent in ipairs(UD_EntCache.Workbenches) do
		if IsValid(ent) and ent:GetPos():DistToSqr(PlyPos) < InfoRangeSqr then
			local EntPos = (ent:GetPos() + Vector(0, 0, 40)):ToScreen()
			draw.SimpleTextOutlined("Work Bench", "UiBold", EntPos.x, EntPos.y, White, 1, 1, 1, DrakGray)
		end
	end
end
hook.Add("HUDPaint", "UD_DrawItemInfo", DrawItemInfo)
