local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()
	local MaxCooldown = Power:GetAttribute("MaxCooldown")
	local Bonus = Config:GetAttribute("Bonus")

	Power:SetAttribute("MaxCooldown", math.clamp(MaxCooldown - Bonus, 20, math.huge))
end

return this
