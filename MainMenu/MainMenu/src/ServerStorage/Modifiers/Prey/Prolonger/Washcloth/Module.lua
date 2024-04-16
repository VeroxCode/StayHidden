local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()
	local SpeedIncrease = Power:GetAttribute("SpeedIncrease")
	local Bonus = Config:GetAttribute("Bonus")
	local Limit = Config:GetAttribute("Limit")
	
	setMaxTokens(Limit)
	Power:SetAttribute("SpeedIncrease", SpeedIncrease + Bonus)
end

function setMaxTokens(Value)

	if (getMaxTokens() < Value) then
		return
	end

	Power:SetAttribute("MaxTokens", Value)
end

function getMaxTokens()
	return Power:GetAttribute("MaxTokens")
end

return this
