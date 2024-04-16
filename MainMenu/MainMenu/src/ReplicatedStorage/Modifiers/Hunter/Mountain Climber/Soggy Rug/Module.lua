local Power = script.Parent.Parent.Parent
local PowerTrap = Power.PowerTrap
local Config = script.Parent

local this = {}

function this:apply()
	local Bonus = Config:GetAttribute("Bonus")
	local Standard = PowerTrap:GetAttribute("SlowdownLength")

	PowerTrap:SetAttribute("SlowdownLength", Standard - Bonus)

end

return this
