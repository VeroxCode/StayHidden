local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()

	local Base = Power:GetAttribute("PlacementTime")
	local Bonus = Config:GetAttribute("Bonus")

	Power:SetAttribute("PlacementTime", Base - Bonus)

end

return this
