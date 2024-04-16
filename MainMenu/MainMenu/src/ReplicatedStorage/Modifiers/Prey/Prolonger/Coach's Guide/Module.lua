local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local LoaderPlayer = Power.Parent
local Config = script.Parent

local this = {}

function this:apply()
	local MaxCooldown = Power:GetAttribute("MaxCooldown")
	local Penalty = Config:GetAttribute("Penalty")
	local Bonus = Config:GetAttribute("Bonus")
	
	local ID = LoaderPlayer:GetAttribute("ID")
	local MatchPlayer = Modules.Game:getMatchPlayer(ID)
	
	Modules.Speed:addMultiplier(MatchPlayer, "Coach's Guide", -(Penalty / 100), 0)
	Power:SetAttribute("MaxCooldown", math.clamp(MaxCooldown - Bonus, 20, math.huge))
end

return this
