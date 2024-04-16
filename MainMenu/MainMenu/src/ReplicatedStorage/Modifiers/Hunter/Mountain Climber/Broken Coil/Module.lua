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

function onTrip(Player, Role, Trap, delta)
	
	if (Role == "Hunter") then
		return
	end
	
	local Hunter = Modules.Game:getHunter()
	local HunterID = Modules.Game:getHunterID()
	local HunterPlayer = Players:GetPlayerByUserId(HunterID)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	
	local SlowdownLength = Trap:GetAttribute("SlowdownLength")
	local SlowdownValue = Trap:GetAttribute("SlowdownValue")
	local Damage = Config:GetAttribute("Value")
	
	local Health = Modules.Game:getHealth(MatchPlayer)
	
	if (Health >= 5) then
		Modules.Game:applyDamage(Player, (Damage * delta))
	end
	
end

Events.Hunter.onTrip.Event:Connect(onTrip)

return this
