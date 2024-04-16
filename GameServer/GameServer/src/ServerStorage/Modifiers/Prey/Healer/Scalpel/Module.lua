local Power = script.Parent.Parent.Parent
local Config = script.Parent

local this = {}

function this:apply()

	local Base = Power:GetAttribute("Cooldown")
	local Bonus = Config:GetAttribute("Bonus")

	Power:SetAttribute("Cooldown", Base - Bonus)

end

return this
