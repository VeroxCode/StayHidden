local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local Config = script.Parent

local Players = game:GetService("Players")
local Events = game.ServerStorage.Events

local this = {}

function this:apply()
	
	local Base = Power.Totem:GetAttribute("Lifetime")
	local Penalty = Config:GetAttribute("Penalty")

	Power.Totem:SetAttribute("Lifetime", Base - Penalty)
	
	local Base2 = Power.Totem:GetAttribute("HealAmount")
	local Bonus = Config:GetAttribute("Bonus")

	Power.Totem:SetAttribute("HealAmount", Base + Bonus)
	
end

return this
