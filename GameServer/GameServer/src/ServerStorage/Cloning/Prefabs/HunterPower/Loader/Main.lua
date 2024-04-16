local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local LoaderPlayer : Player = script.Parent.Parent.Parent
local Power = script.Parent.Parent

local this = {}

local Data = {
}

function this:initialize()
	print("initialize " .. LoaderPlayer.Name)
	
	local Player = game.Players:WaitForChild(LoaderPlayer.Name)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	local SaveState = Modules.SaveStorage:get(Player.UserId)
	local Selected = SaveState[Role].Selected 
	local Perks = SaveState[Role][Selected].LoadOut.Modifiers

	for i, v in pairs(Perks) do
		if (v ~= "") then
			local Modifiers = game.ServerStorage.Modifiers[Role][Selected]
			local Modifier = Modifiers[v]:Clone()
			Modifier.Name = v
			Modifier.Parent = Power.Loader

			local Module = require(Modifier.Module)
			Module:apply()
		end
	end
end

function this:performAbility(Player)
	print("Performing Ability")
end

function this:cancelAbility(Player)
	print("Cancelling Ability")
end

function this:performSecondary(Player)
	print("Performing Secondary")
end

function this:cancelSecondary(Player)
	print("Cancelling Secondary")
end

return this
