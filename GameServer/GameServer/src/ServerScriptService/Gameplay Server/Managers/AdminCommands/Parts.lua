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
	
	Modules.Game:setParts(Modules.Game:getMatchPlayer(Player.UserId), args[2])
	ChatMessage:FireClient(Player, "Parts set to:  " .. args[2])
end

return this
