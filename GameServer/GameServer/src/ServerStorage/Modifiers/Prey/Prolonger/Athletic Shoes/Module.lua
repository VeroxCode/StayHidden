local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()
	local SpeedIncrease = Power:GetAttribute("SpeedIncrease")
	local Bonus = Config:GetAttribute("Bonus")

	Power:SetAttribute("SpeedIncrease", SpeedIncrease + Bonus)
end

return this
