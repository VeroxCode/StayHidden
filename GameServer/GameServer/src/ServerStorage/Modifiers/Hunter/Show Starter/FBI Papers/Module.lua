local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent

local this = {}

function this:apply()
	local Bonus = Config:GetAttribute("Bonus")
	local Standard = Power:GetAttribute("OrbLifetime")

	Power:SetAttribute("OrbLifetime", Standard + Bonus)

end

return this
