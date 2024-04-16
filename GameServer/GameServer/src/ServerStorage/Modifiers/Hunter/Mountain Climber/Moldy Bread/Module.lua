local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local PowerTrap = Power.PowerTrap
local Config = script.Parent

local LoaderPlayer : Player = Power.Parent
local Events = game.ServerStorage.Events

local this = {}

function this:apply()
end

function onTrip(Player)
	
	local SlowdownLength = PowerTrap:GetAttribute("SlowdownLength")
	local SlowdownValue = PowerTrap:GetAttribute("SlowdownValue")
	local SlowdownBonus = Config:GetAttribute("SlowdownBonus")
	local TriggerRange = Config:GetAttribute("TriggerRange")
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Slowdown = SlowdownValue - (SlowdownBonus / 10)
	
	if (Player.Name ~= LoaderPlayer.Name) then
		local Root1 = workspace[Player.Name].HumanoidRootPart
		local Root2 = workspace[LoaderPlayer.Name].HumanoidRootPart
		local Distance = Modules.PlayerUtils:getDistanceXZ(Root1, Root2)

		if (Distance <= TriggerRange) then
			Modules.Game:setEffect(MatchPlayer, "Slowdown", "Value", (SlowdownBonus / 100))
			Modules.Game:applyTimedEffect(MatchPlayer, "Slowdown", SlowdownLength)
		end
	end
end

Events.Hunter.onTrip.Event:Connect(onTrip)

return this
