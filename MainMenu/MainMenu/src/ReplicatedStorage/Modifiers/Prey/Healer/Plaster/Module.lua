local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()

	local Radius = Power.Totem:GetAttribute("Radius")
	local Bonus = Config:GetAttribute("Bonus")

	Power.Totem:SetAttribute("Radius", Radius + Bonus)

end

return this
