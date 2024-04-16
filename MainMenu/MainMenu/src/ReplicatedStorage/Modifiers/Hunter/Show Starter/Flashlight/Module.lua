local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events.Hunter

local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent


local this = {}

function this:apply()
	
	local Bonus = Config:GetAttribute("Bonus")
	local Standard = PowerObject:GetAttribute("ParalyzedDuration")

	PowerObject:SetAttribute("ParalyzedDuration", Standard + Bonus)
	
end

return this
