local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local Config = script.Parent

local Players = game:GetService("Players")
local Events = game.ServerStorage.Events

local this = {}

function this:apply()
end

function onTotemEvent(Player, Event)
	
	if (Event == "Enter") then
		for i, v in pairs(Players:GetPlayers()) do
			if (v.Name ~= Player.Name) then
				Modules.AuraManager:createAura(v, "Player", Player.Name, false, -1, Color3.new(1, 1, 1), Color3.new(0.584314, 0.584314, 0.584314), "Totem")
			end
		end
	end
	
	if (Event == "Leave") then
		for i, v in pairs(Players:GetPlayers()) do
			if (v.Name ~= Player.Name) then
				Modules.AuraManager:removeAura(v, "Player", Player.Name, "Totem")
			end
		end
	end
	
	if (Event == "Destroy") then
		for i, v in pairs(Players:GetPlayers()) do
			for i2, v2 in pairs(Players:GetPlayers()) do
				Modules.AuraManager:removeAura(v, "Player", v2.Name, "Totem")
			end
		end
	end
	
end

Events.Prey.onTotemEvent.Event:Connect(onTotemEvent)

return this
