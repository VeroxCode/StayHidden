local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local this = {}

function this:execute(Player, message)
	
	local args = string.split(message, " ")
	
	if (args == nil) then
		ChatMessage:FireClient(Player, "Invalid Arguments!")
		return
	end
	
	args[2] = tonumber(args[2])
	
	if (args[2] == nil) then
		ChatMessage:FireClient(Player, "Invalid Amount!")
		return
	end
	
	Modules.Game:applyDamage(Player, args[2])
	ChatMessage:FireClient(Player, "Damaged by:  " .. args[2])
end

return this
