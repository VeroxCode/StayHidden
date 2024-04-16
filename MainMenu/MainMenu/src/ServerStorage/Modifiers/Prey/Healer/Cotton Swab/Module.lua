local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local Config = script.Parent

local Players = game:GetService("Players")
local Events = game.ServerStorage.Events

local this = {}

function this:apply()
end

function onTotemEvent(Player, Event, Times)
	
	if (Event == "Leave") then
		if (Times > 1) then
			return
		end
		
		local Bonus = Config:GetAttribute("Bonus")
		local Duration = Config:GetAttribute("Duration")
		
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		Modules.Game:applyTimedEffect(MatchPlayer, "Swiftness", Duration)
		Modules.Game:setEffect(MatchPlayer, "Swiftness", "Amount", Bonus / 100)
	end
	
end

Events.Prey.onTotemEvent.Event:Connect(onTotemEvent)

return this
