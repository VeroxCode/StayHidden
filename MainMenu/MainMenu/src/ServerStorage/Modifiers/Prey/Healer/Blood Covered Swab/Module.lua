local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local Config = script.Parent

local Players = game:GetService("Players")
local Events = game.ServerStorage.Events

local this = {}

function this:apply()
	
	local Base = Power:GetAttribute("PlacementTime")
	local Penalty = Config:GetAttribute("Penalty")

	Power:SetAttribute("PlacementTime", Base + Penalty)
end

function onTotemEvent(Player, Event, Times)
	
	if (Event == "Enter") then
		if (Times > 1) then
			return
		end
		
		local Duration = Config:GetAttribute("Duration")
		
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		Modules.Game:applyTimedEffect(MatchPlayer, "Protection", Duration)
	end
	
end

Events.Prey.onTotemEvent.Event:Connect(onTotemEvent)

return this
