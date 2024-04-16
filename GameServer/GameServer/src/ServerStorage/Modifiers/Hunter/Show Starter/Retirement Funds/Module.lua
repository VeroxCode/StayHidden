local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events.Hunter

local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent


local this = {}

function this:apply()
	
end

function onRadiusUpdate(Event, Player, Role)
	if (Event ~= "Tick" or Role == "Hunter") then
		return
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	Modules.Game:applyTimedEffect(MatchPlayer, "Vulnerable", 0.5)
	
end

Events.RadiusUpdate.Event:Connect(onRadiusUpdate)

return this
