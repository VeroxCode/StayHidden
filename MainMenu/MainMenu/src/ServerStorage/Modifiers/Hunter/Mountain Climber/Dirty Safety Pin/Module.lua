local Power = script.Parent.Parent.Parent
local PowerTrap = Power.PowerTrap
local Config = script.Parent

local this = {}

function this:apply()
	local Bonus = Config:GetAttribute("Bonus")
	local Standard = PowerTrap:GetAttribute("Radius")
	
	PowerTrap:SetAttribute("Radius", Standard + Bonus)
	
end

return this
