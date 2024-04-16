local Power = script.Parent.Parent.Parent
local PowerTrap = Power.PowerTrap
local Config = script.Parent

local this = {}

function this:apply()
	local Bonus = Config:GetAttribute("SlowdownBonus")
	local Standard = PowerTrap:GetAttribute("SlowdownValue")
	
	PowerTrap:SetAttribute("SlowdownValue", Standard - (Bonus / 100))
	
end

return this
