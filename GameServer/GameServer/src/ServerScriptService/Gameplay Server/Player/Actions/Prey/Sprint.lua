local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Speed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("Speed"))
local Players = game:GetService("Players")
local Actions = Modules.Actions

local this = {}

local ActionData = {
	RequiredAction = Actions.List.IDLE,
	RequiresAction = true,
	Role = "Prey"
}

function this:performAction(PlayerID, bool)
	
	local Player = Players:GetPlayerByUserId(PlayerID)
	local MatchPlayer = Modules.Game:getMatchPlayer(PlayerID)
	
	if (Modules.Game:isCrouching(MatchPlayer)) then
		Modules.Speed:removeSpeed(MatchPlayer, "Sprint")
		return
	end
	
	Modules.Game:setSprinting(MatchPlayer, bool)
	Modules.Game:setAnimationAction(MatchPlayer, if (bool) then "Run" else "Walk")
	Player.Backpack.BasePlayer:SetAttribute("isSprinting", bool)
	
	if (bool) then
		Modules.Speed:addSpeed(MatchPlayer, "Sprint", Modules.Speed.Speeds.Prey.Sprint, 0)
	else
		Modules.Speed:removeSpeed(MatchPlayer, "Sprint")
	end
	
	return
end


function this:getRequiredActionID()
	return ActionData.RequiredAction
end

function this:getNeededRole()
	return ActionData.Role
end

function this:RequiresAction()
	return ActionData.RequiresAction
end

return this
