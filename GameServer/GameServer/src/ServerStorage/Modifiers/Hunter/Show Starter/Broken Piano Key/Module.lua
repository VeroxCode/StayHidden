local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent

local this = {}

function this:apply()
	local Bonus = Config:GetAttribute("Bonus")
	local Standard = PowerObject:GetAttribute("SwiftnessValue")

	PowerObject:SetAttribute("SwiftnessValue", (Standard + Bonus) / 100)

end

return this
