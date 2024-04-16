local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(Player)
	Player.Chatted:Connect(function(message, recipient)
		
		if (not (Modules.GlobalUtils:isStaff(Player) or workspace:GetAttribute("Debug")) and not Modules.Game:isRunning()) then
			return
		end
		
		for i, v in ipairs(script:GetChildren()) do
			
			local lowerMessage = string.lower(message)
			local lowerName = string.lower(v.Name)
			
			if (string.find(lowerMessage, "-" .. lowerName)) then
				local command = require(v)
				command:execute(Player, message)
			end
		end
	end)
end)