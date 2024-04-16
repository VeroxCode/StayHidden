local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()

	local Radius = Power.Totem:GetAttribute("HealAmount")
	local Bonus = Config:GetAttribute("Bonus")

	Power.Totem:SetAttribute("HealAmount", Radius + Bonus)

end

return this
