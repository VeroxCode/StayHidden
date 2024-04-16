local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local this = {}

function this:execute(Player, message)
	
	for i, v in pairs(workspace.Map.Interactables.Fuseboxes:GetChildren()) do
		if (tonumber(v.Name) ~= nil) then
			Modules.Fusebox:setActivated(v, false)
		end
	end
	
	ChatMessage:FireClient(Player, "Lights out!")
	
end

return this
