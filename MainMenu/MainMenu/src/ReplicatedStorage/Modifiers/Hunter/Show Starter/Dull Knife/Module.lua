local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events.Hunter

local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent

local this = {}

function this:apply()
	
end

function onRadiusUpdate(Event, Players)
	if (Event ~= "Tick") then
		return
	end
	
	for i, Player in pairs(Players) do
		
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		local Duration = PowerObject:GetAttribute("ParalyzedDuration")
		local Role = Modules.Game:getRole(MatchPlayer)
		
		if (Role == "Prey") then
			Modules.Game:applyTimedEffect(MatchPlayer, "Vulnerable", Duration)
			PowerObject:setAttribute("applyParalyzed", false)
		end
	end
end

Events.RadiusUpdate.Event:Connect(onRadiusUpdate)

return this
