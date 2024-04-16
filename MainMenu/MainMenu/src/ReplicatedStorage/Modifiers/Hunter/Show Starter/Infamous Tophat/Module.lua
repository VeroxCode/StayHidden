local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent

local this = {}

function this:apply()
	local Bonus = Config:GetAttribute("Bonus")
	local Standard = PowerObject:GetAttribute("ParalyzedDuration")

	local Bonus2 = Config:GetAttribute("BonusLifetime")
	local Standard2 = Power:GetAttribute("OrbLifetime")

	PowerObject:SetAttribute("ParalyzedDuration", Standard + Bonus)
	Power:SetAttribute("OrbLifetime", Standard2 + Bonus2)

end

return this
