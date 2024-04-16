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

	local Duration = Config:GetAttribute("Duration")
	local SpeedBonus = Config:GetAttribute("SpeedBonus")
	local TriggerRange = Config:GetAttribute("TriggerRange")
	
	local Hunter = Modules.Game:getHunter()
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

	if (Player.Name ~= LoaderPlayer.Name) then
		local Root1 = workspace[Player.Name].HumanoidRootPart
		local Root2 = workspace[LoaderPlayer.Name].HumanoidRootPart
		local Distance = Modules.PlayerUtils:getDistanceXZ(Root1, Root2)

		if (Distance <= TriggerRange) then
			Modules.Game:setEffect(Hunter, "Swiftness", "Value", 0)
			Modules.Game:applyTimedEffect(Hunter, "Swiftness", Duration)
		end
	end
end

Events.Hunter.onTrip.Event:Connect(onTrip)

return this
