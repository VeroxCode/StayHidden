local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local this = {}

function this:execute(Player, message)
	
	local args = string.split(message, " ")
	
	Modules.Game:setSerum(Modules.Game:getMatchPlayer(Player.UserId), true)
	ChatMessage:FireClient(Player, "Gave Serum")
end

return this
