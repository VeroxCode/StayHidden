local Power = script.Parent.Parent.Parent
local PowerTrap = Power.PowerTrap
local Config = script.Parent

local this = {}

function this:apply()
	local Bonus = Config:GetAttribute("Bonus")
	local Traps = Power:GetAttribute("MaxTraps")
	
	Power:SetAttribute("MaxTraps", Traps + Bonus)
	
end

return this
