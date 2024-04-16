local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events.Hunter

local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent


local this = {}

function this:apply()
	
end

function onRadiusUpdate(Event, Players, Role)
	if (Event ~= "Tick") then
		return
	end
	
	for i, Player in pairs(Players) do

		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		local Duration = PowerObject:GetAttribute("ParalyzedDuration")
		local Percent = Config:GetAttribute("Percent") / 100
		local Role = Modules.Game:getRole(MatchPlayer)

		if (Role == "Prey") then
			Modules.Game:applyTimedEffect(MatchPlayer, "Slowdown", Duration)
			Modules.Game:setEffect(MatchPlayer, "Slowdown", "Value", Percent)
		end
	end
end

Events.RadiusUpdate.Event:Connect(onRadiusUpdate)

return this
