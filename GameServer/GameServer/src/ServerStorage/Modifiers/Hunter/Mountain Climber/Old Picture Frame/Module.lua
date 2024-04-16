local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local PowerTrap = Power.PowerTrap
local Config = script.Parent

local Players = game:GetService("Players")
local LoaderPlayer : Player = Power.Parent
local Events = game.ServerStorage.Events

local this = {}

function this:apply()
end

function onTrapSet(Player, Trap)
	
	local Duration = Config:GetAttribute("Duration")
	local SpeedBonus = Config:GetAttribute("SpeedBonus")
	local Hunter = Modules.Game:getHunter()
	local HunterID = Modules.Game:getHunterID()
	local HunterPlayer = Players:GetPlayerByUserId(HunterID)
	
	Modules.Game:setEffect(Hunter, "Swiftness", "Value", (SpeedBonus / 100))
	Modules.Game:applyTimedEffect(Hunter, "Swiftness", Duration)
	
end

Events.Hunter.onTrapSet.Event:Connect(onTrapSet)

return this
