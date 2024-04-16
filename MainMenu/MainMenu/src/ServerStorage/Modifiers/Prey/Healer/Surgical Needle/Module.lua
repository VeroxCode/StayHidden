local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()

	local Base = Power.Totem:GetAttribute("Lifetime")
	local Bonus = Config:GetAttribute("Bonus")

	Power.Totem:SetAttribute("Lifetime", Base + Bonus)

end

return this
